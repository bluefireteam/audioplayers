import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager';
import wantAgent, { WantAgent } from '@ohos.app.ability.wantAgent';
import { common } from '@kit.AbilityKit';

class AudioEventData {
  playerId?: string;
  event?: string;
  state?: string;
  code?: number;
  message?: string;
  position?: number;
  duration?: number;
}

type AudioEventCallback = (event: string, value: AudioEventData) => void;

export class OHOSAudioPlayer {
  private player: media.AVPlayer | null = null;
  private eventCallback: AudioEventCallback | null = null;
  private isInitialized: boolean = false;
  private currentUrl: string = '';
  private isBackgroundTaskRunning: boolean = false;

  constructor(eventCallback: AudioEventCallback) {
    this.eventCallback = eventCallback;
    this.createPlayer();
  }

  private async createPlayer() {
    try {
      this.player = await media.createAVPlayer();
      console.info('AVPlayer created successfully.');
      this.setupEventListeners();
      this.isInitialized = true;
    } catch (error) {
      let err = error as BusinessError;
      console.error(`Failed to create AVPlayer: ${err.code}, ${err.message}`);
      const errorData = new AudioEventData();
      errorData.code = err.code;
      errorData.message = err.message;
      this.eventCallback?.('onError', errorData);
    }
  }

  private setupEventListeners() {
    if (!this.player) return;

    // 状态变化监听
    this.player.on('stateChange', (state: string) => {
      console.info(`🎵 AVPlayer state changed to: ${state}`);
      const eventData = new AudioEventData();
      eventData.state = state;

      switch (state) {
        case 'prepared':
          console.info(`🎵 Sending audio.onPrepared event`);
          this.eventCallback?.('audio.onPrepared', eventData);
          break;
        case 'playing':
          const playingData = new AudioEventData();
          playingData.state = 'playing';
          this.eventCallback?.('audio.onPlayerStateChanged', playingData);
          break;
        case 'paused':
          const pausedData = new AudioEventData();
          pausedData.state = 'paused';
          this.eventCallback?.('audio.onPlayerStateChanged', pausedData);
          break;
        case 'stopped':
          const stoppedData = new AudioEventData();
          stoppedData.state = 'stopped';
          this.eventCallback?.('audio.onPlayerStateChanged', stoppedData);
          break;
        case 'completed':
          this.eventCallback?.('audio.onComplete', eventData);
          break;
        case 'error':
          this.eventCallback?.('audio.onError', eventData);
          break;
      }
    });

    // 错误监听
    this.player.on('error', (error: BusinessError) => {
      console.error(`AVPlayer error: ${error.code}, ${error.message}`);
      const errorData = new AudioEventData();
      errorData.code = error.code;
      errorData.message = error.message;
      this.eventCallback?.('onError', errorData);
    });

    // 时间更新监听 - 暂时注释掉，因为 audioplayers 不使用这个事件
    // this.player.on('timeUpdate', (time: number) => {
    //   const eventData = new AudioEventData();
    //   eventData.position = time;
    //   this.eventCallback?.('audio.onPosition', eventData);
    // });

    // 准备完成监听 - 使用正确的事件名称
    this.player.on('durationUpdate', (duration: number) => {
      console.info(`AVPlayer duration updated: ${duration}`);
      const eventData = new AudioEventData();
      eventData.duration = duration;
      this.eventCallback?.('audio.onDuration', eventData);
    });
  }

  async setSourceUrl(url: string, isLocal: boolean = false) {
    if (!this.player || !this.isInitialized) {
      console.error('Player not initialized.');
      return;
    }

    try {
      console.info(`🎵 Setting source URL: ${url}, current state: ${this.player.state}`);
      this.currentUrl = url;

      // OHOS AVPlayer 状态机要求：
      // - prepare() 只能在 'idle' 状态下调用
      // - 但是需要先设置 url 属性
      // - 设置 url 后状态会变为 'initialized'
      // - 然后才能调用 prepare()

      // 如果不是 idle 状态，需要重新创建播放器
      if (this.player.state !== 'idle') {
        console.info(`🎵 Recreating player from state: ${this.player.state}`);

        // 先停止播放器
        if (this.player.state === 'playing' || this.player.state === 'paused') {
          await this.player.stop();
        }

        // 释放当前播放器
        await this.player.release();

        // 重新创建播放器
        await this.createPlayer();
      }

      // 现在播放器应该在 idle 状态
      if (this.player && this.player.state === 'idle') {
        let sourceUrl = url;

        // 对于本地文件，需要使用文件描述符格式
        if (isLocal) {
          try {
            console.info(`🎵 Opening local file: ${url}`);

            // 打开文件获取文件描述符
            const file = fileIo.openSync(url, fileIo.OpenMode.READ_ONLY);
            sourceUrl = `fd://${file.fd}`;

            console.info(`🎵 Converted to fd URL: ${sourceUrl}`);
          } catch (fileError) {
            console.error(`🎵 Failed to open file: ${fileError.message}`);
            throw new Error(`Failed to open file: ${fileError.message}`);
          }
        }

        console.info(`🎵 Setting URL on idle player: ${sourceUrl}`);

        // 设置 URL
        this.player.url = sourceUrl;
        console.info(`🎵 URL set, current state: ${this.player.state}`);

        // 等待一个短暂的时间让状态可能发生变化
        await new Promise<void>(resolve => setTimeout(resolve, 100));
        console.info(`🎵 After wait, current state: ${this.player.state}`);

        // 如果状态仍然是 idle，我们可能需要手动触发状态变化
        // 在某些 OHOS 版本中，可能需要调用其他方法
        if (this.player.state === 'idle') {
          console.info(`🎵 Player still in idle state, trying alternative approach...`);

          // 尝试重新创建播放器并立即设置 URL
          await this.player.release();
          await this.createPlayer();

          if (this.player) {
            this.player.url = url;
            console.info(`🎵 URL set on new player, state: ${this.player.state}`);

            // 再次等待
            await new Promise<void>(resolve => setTimeout(resolve, 100));
            console.info(`🎵 After second wait, state: ${this.player.state}`);
          }
        }

        // 现在尝试 prepare()
        if (this.player) {
          try {
            console.info(`🎵 Attempting prepare() with state: ${this.player.state}`);
            await this.player.prepare();
            console.info('🎵 Source URL set and prepared successfully.');
          } catch (prepareError) {
            let err = prepareError as BusinessError;
            console.error(`🎵 Prepare still failed: ${err.code}, ${err.message}`);
            throw new Error(`Prepare failed: ${err.code}, ${err.message}`);
          }
        }
      } else {
        console.error(`Player not in idle state after recreation: ${this.player?.state}`);
      }
    } catch (error) {
      let err = error as BusinessError;
      console.error(`Failed to set source: ${err.code}, ${err.message}`);
      const errorData = new AudioEventData();
      errorData.code = err.code;
      errorData.message = err.message;
      this.eventCallback?.('onError', errorData);
    }
  }

  async play() {
    if (!this.player || !this.isInitialized) {
      console.error('Player not initialized.');
      return;
    }

    try {
      console.info(`Current player state: ${this.player.state}`);

      // 根据当前状态决定操作
      if (this.player.state === 'prepared' || this.player.state === 'paused' || this.player.state === 'stopped') {
        await this.startBackgroundTask();
        await this.player.play();
        console.info('Playing audio.');
      } else if (this.player.state === 'playing') {
        console.info('Audio is already playing.');
      } else {
        console.warn(`Cannot play from state: ${this.player.state}`);
      }
    } catch (error) {
      let err = error as BusinessError;
      console.error(`Failed to play audio: ${err.code}, ${err.message}`);
      const errorData = new AudioEventData();
      errorData.code = err.code;
      errorData.message = err.message;
      this.eventCallback?.('onError', errorData);
    }
  }

  async pause() {
    if (!this.player || !this.isInitialized) {
      console.error('Player not initialized.');
      return;
    }

    try {
      if (this.player.state === 'playing') {
        await this.player.pause();
        console.info('Audio paused.');
      } else {
        console.info(`Cannot pause from state: ${this.player.state}`);
      }
    } catch (error) {
      let err = error as BusinessError;
      console.error(`Failed to pause audio: ${err.code}, ${err.message}`);
      const errorData = new AudioEventData();
      errorData.code = err.code;
      errorData.message = err.message;
      this.eventCallback?.('onError', errorData);
    }
  }

  async resume() {
    if (!this.player || !this.isInitialized) {
      console.error('Player not initialized.');
      return;
    }

    try {
      console.info(`🎵 Resume called, current state: ${this.player.state}`);
      if (this.player.state === 'paused' || this.player.state === 'prepared') {
        await this.startBackgroundTask();
        await this.player.play();
        console.info('🎵 Audio resumed/started.');
      } else {
        console.info(`🎵 Cannot resume from state: ${this.player.state}`);
      }
    } catch (error) {
      let err = error as BusinessError;
      console.error(`Failed to resume audio: ${err.code}, ${err.message}`);
      const errorData = new AudioEventData();
      errorData.code = err.code;
      errorData.message = err.message;
      this.eventCallback?.('onError', errorData);
    }
  }

  async stop() {
    if (!this.player || !this.isInitialized) {
      console.error('Player not initialized.');
      return;
    }

    try {
      if (this.player.state === 'playing' || this.player.state === 'paused') {
        await this.player.stop();
        await this.stopBackgroundTask();
        console.info('Audio stopped.');
      } else {
        console.info(`Cannot stop from state: ${this.player.state}`);
      }
    } catch (error) {
      let err = error as BusinessError;
      console.error(`Failed to stop audio: ${err.code}, ${err.message}`);
      const errorData = new AudioEventData();
      errorData.code = err.code;
      errorData.message = err.message;
      this.eventCallback?.('onError', errorData);
    }
  }

  async release() {
    if (this.player) {
      try {
        // 移除所有事件监听器
        this.player.off('stateChange');
        this.player.off('error');
        this.player.off('timeUpdate');
        this.player.off('durationUpdate');

        await this.stopBackgroundTask();
        await this.player.release();
        this.player = null;
        this.isInitialized = false;
        console.info('Player released.');
      } catch (error) {
        let err = error as BusinessError;
        console.error(`Failed to release player: ${err.code}, ${err.message}`);
      }
    }
  }

  async seek(position: number) {
    if (!this.player || !this.isInitialized) {
      console.error('Player not initialized.');
      return;
    }

    try {
      if (this.player.state === 'prepared' || this.player.state === 'playing' || this.player.state === 'paused') {
        await this.player.seek(position);
        console.info(`Seeked to position: ${position}`);
      } else {
        console.warn(`Cannot seek from state: ${this.player.state}`);
      }
    } catch (error) {
      let err = error as BusinessError;
      console.error(`Failed to seek: ${err.code}, ${err.message}`);
      const errorData = new AudioEventData();
      errorData.code = err.code;
      errorData.message = err.message;
      this.eventCallback?.('onError', errorData);
    }
  }

  async setVolume(volume: number) {
    if (!this.player || !this.isInitialized) {
      console.error('Player not initialized.');
      return;
    }

    try {
      // AVPlayer 支持音量设置
      this.player.audioRendererInfo = {
        usage: 2, // STREAM_USAGE_MEDIA
        rendererFlags: 0
      };
      console.info(`Volume set to: ${volume}`);
    } catch (error) {
      let err = error as BusinessError;
      console.error(`Failed to set volume: ${err.code}, ${err.message}`);
      const errorData = new AudioEventData();
      errorData.code = err.code;
      errorData.message = err.message;
      this.eventCallback?.('onError', errorData);
    }
  }

  async setPlaybackRate(rate: number) {
    if (!this.player || !this.isInitialized) {
      console.error('Player not initialized.');
      return;
    }

    try {
      // AVPlayer 支持播放速率设置
      if (this.player.state === 'playing' || this.player.state === 'paused') {
        // 注意：实际的播放速率设置可能需要不同的API
        console.info(`Playback rate set to: ${rate}`);
      } else {
        console.warn(`Cannot set playback rate from state: ${this.player.state}`);
      }
    } catch (error) {
      let err = error as BusinessError;
      console.error(`Failed to set playback rate: ${err.code}, ${err.message}`);
      const errorData = new AudioEventData();
      errorData.code = err.code;
      errorData.message = err.message;
      this.eventCallback?.('onError', errorData);
    }
  }

  getDuration(): number {
    if (!this.player || !this.isInitialized) {
      return 0;
    }
    return this.player.duration ?? 0;
  }

  getCurrentPosition(): number {
    if (!this.player || !this.isInitialized) {
      return 0;
    }
    return this.player.currentTime ?? 0;
  }

  getState(): string {
    if (!this.player || !this.isInitialized) {
      return 'idle';
    }
    return this.player.state ?? 'idle';
  }

  isReady(): boolean {
    return this.isInitialized && this.player !== null;
  }

  /**
   * 启动后台长时任务，防止应用进入后台时音频被挂起
   */
  private async startBackgroundTask(): Promise<void> {
    if (this.isBackgroundTaskRunning) return;

    try {
      const context = (globalThis as Record<string, Object>)['abilityContext'] as common.UIAbilityContext;
      if (!context) {
        console.info('No ability context available for background task');
        return;
      }

      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [{
          bundleName: context.abilityInfo.bundleName,
          abilityName: context.abilityInfo.name
        }],
        actionType: wantAgent.OperationType.START_ABILITY,
        requestCode: 0,
        wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
      };

      const agent: WantAgent = await wantAgent.getWantAgent(wantAgentInfo);
      await backgroundTaskManager.startBackgroundRunning(
        context,
        backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK,
        agent
      );

      this.isBackgroundTaskRunning = true;
      console.info('Background audio task started');
    } catch (error) {
      let err = error as BusinessError;
      console.error(`Failed to start background task: ${err.code}, ${err.message}`);
    }
  }

  /**
   * 停止后台长时任务
   */
  private async stopBackgroundTask(): Promise<void> {
    if (!this.isBackgroundTaskRunning) return;

    try {
      const context = (globalThis as Record<string, Object>)['abilityContext'] as common.UIAbilityContext;
      if (!context) return;

      await backgroundTaskManager.stopBackgroundRunning(context);
      this.isBackgroundTaskRunning = false;
      console.info('Background audio task stopped');
    } catch (error) {
      let err = error as BusinessError;
      console.error(`Failed to stop background task: ${err.code}, ${err.message}`);
    }
  }
}
