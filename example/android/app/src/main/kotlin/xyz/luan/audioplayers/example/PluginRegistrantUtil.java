package xyz.luan.audioplayers.example;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;
import xyz.luan.audioplayers.AudioplayersPlugin;

public class PluginRegistrantUtil {

    public static void registerWith(@NonNull FlutterEngine flutterEngine) {
        ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(flutterEngine);
        xyz.luan.audioplayers.AudioplayersPlugin.registerWith(shimPluginRegistry.registrarFor("xyz.luan.audioplayers.AudioplayersPlugin"));
        flutterEngine.getPlugins().add(new io.flutter.plugins.pathprovider.PathProviderPlugin());
    }
}
