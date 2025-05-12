package com.example.myapp

import androidx.multidex.MultiDexApplication
import io.flutter.app.FlutterApplication

/**
 * Extension of MultiDexApplication to support loading over 64K methods.
 * This allows the app to overcome the 64K method limit in Android applications.
 */
class MainApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        // Any additional application-level initialization can be done here
    }
}
