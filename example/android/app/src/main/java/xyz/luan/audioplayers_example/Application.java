package xyz.luan.audioplayers_example;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import io.flutter.plugins.GeneratedPluginRegistrant;
import xyz.luan.audioplayers.AudioplayersPlugin;

public class Application extends FlutterApplication implements PluginRegistrantCallback{
  @Override 
  public void onCreate() {
    super.onCreate();
    AudioplayersPlugin.setPluginRegistrant(this);
  }

  @Override
  public void registerWith(PluginRegistry registry){
    GeneratedPluginRegistrant.registerWith(registry);
  }
}