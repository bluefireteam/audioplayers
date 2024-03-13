# Feature Parity Table

Not every feature is available on every platform yet. Use this table to keep track of our work and progress, and please help out if you want to. :)

If you would like to assist us implement a missing feature, please browse the [issue tracker](https://github.com/bluefireteam/audioplayers/issues) and reach out to us on our [Discord](https://discord.gg/pxrBmy4) server so we can coordinate efforts.

## Note on Android Support

Giving support to old Android devices is very hard, on this plugin we set the minSdk as 16, but we only ensure support >= 23 as that is the minimum version that the team has devices available to test changes and new features.

This mean that, audioplayers should work on older devices, but we can't give any guarantees, we will not be able to look after issues regarding API < 23. But we would gladly take any pull requests from the community that fixes or improve support on those old versions.


## Main Features

Note: LLM means Low Latency Mode.

<table width="70%">
    <thead style="font-size: 1.5em">
        <th>Feature/Platform</th>
        <th>Android</th>
        <th>iOS</th>
        <th>macOS</th>
        <th>web</th>
        <th>Windows</th>
        <th>Linux</th>
    </thead>
    <tbody>
        <tr><td colspan="7"><strong>Audio Source</strong></td></tr>
        <tr><td>local file on device</td><td>yes</td><td>yes</td><td>yes</td><td>no</td><td>yes</td><td>yes</td></tr>
        <tr><td>local asset</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td></tr>
        <tr><td>external URL file</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td></tr>
        <tr><td>external URL stream</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td></tr>
        <tr><td>byte array</td><td>SDK >=23</td><td>via conversion</td><td>via conversion</td><td>via conversion</td><td>yes</td><td>via conversion</td></tr>
        <tr><td colspan="7"><strong>Audio Config</strong></td></tr>
        <tr><td>set url</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td></tr>
        <tr><td>audio cache (pre-load)</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td></tr>
        <tr><td>low latency mode</td><td>SDK >=21</td><td>no</td><td>no</td><td>no</td><td>no</td><td>no</td></tr>
        <tr><td colspan="7"><strong>Audio Control Commands</strong></td></tr>
        <tr><td>resume / pause / stop</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td></tr>
        <tr><td>release</td><td>yes</td><td>yes (no mode)</td><td>yes (no mode)</td><td>yes (no mode)</td><td>yes (no mode)</td><td>yes (no mode)</td></tr>
        <tr><td>loop</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td></tr>
        <tr><td>volume</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td></tr>
        <tr><td>seek</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td></tr>
        <tr><td colspan="7"><strong>Advanced Audio Control Commands</strong></td></tr>
        <tr><td>playback rate</td><td>SDK >= 23</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td></tr>
        <tr><td>duck audio</td><td>yes (except LLM)</td><td>no</td><td>no</td><td>no</td><td>no</td><td>no</td></tr>
        <tr><td>respect silence</td><td>yes (except LLM)</td><td>yes</td><td>no</td><td>no</td><td>no</td><td>no</td></tr>
        <tr><td>stay awake</td><td>yes (except LLM)</td><td>yes</td><td>no</td><td>no</td><td>no</td><td>no</td></tr>
        <tr><td>recording active</td><td>not yet</td><td>yes</td><td>no</td><td>no</td><td>no</td><td>no</td></tr>
        <tr><td>playing route</td><td>yes (except LLM)</td><td>yes</td><td>no</td><td>no</td><td>no</td><td>no</td></tr>
        <tr><td>balance</td><td>yes</td><td>not yet</td><td>not yet</td><td>yes</td><td>yes</td><td>yes</td></tr>
        <tr><td colspan="7"><strong>Streams</strong></td></tr>
        <tr><td>duration event</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td></tr>
        <tr><td>position event</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td></tr>
        <tr><td>state event</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td></tr>
        <tr><td>completion event</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td></tr>
        <tr><td>log event</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td></tr>
    </tbody>
</table>

<br />

## Lock Screen Controls

To control playback from lock screen on iOS and Android, you can use @ryanheise's excellent [audio_service](https://pub.dev/packages/audio_service) package. [This article](https://denis-korovitskii.medium.com/flutter-demo-audioplayers-on-background-via-audio-service-c95d65c90ae1) showcases how to integrate audioplayers features with and audio_service.

Do not send any PRs or additions regarding notifications/lock screen support, unless it is a generic change on our infrastructure/wiring to support better integrating with `audio_service`.

## Other Out-of-Scope Features

Some features are also out of scope for the `audioplayers` package. The goal  of this library is to provide a unified place to play audio media, be it songs, background musics, sound effects, etc, from different sources, and providing an array of advanced controls and listeners to control it via code.

Non-goals: if the existing solutions proposed below are not good or do not work well with audioplayers, I am happy to collaborate to create an `audioplayers_x` separated package (eg `audioplayers_recorder`).

 * interfaces: nothing related to interface building concerns audioplayers; you can use Flutter to build your interfaces;
 * audio recording: recording audio from the microphone into audio files and streams; there is already a package for this called [audio_recorder](https://github.com/ZaraclaJ/audio_recorder).
 * playlist: you can implement playlists as you wish by playing multiple audios or songs in sequence. Doesn't make sense for this package to have any builtin playlist mechanism.
 * music metadata: some file formats include music metadata, like MP3 files that have author, track. This is a library dedicated for playing audio. It is a non-goal to provide this functionality.
