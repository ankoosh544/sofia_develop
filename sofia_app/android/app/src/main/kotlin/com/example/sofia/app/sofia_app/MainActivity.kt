package com.example.sofia.app.sofia_app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        startForegroundService(Intent(this@MainActivity, BeaconMonitoringService::class.java))
    }
}
