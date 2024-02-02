package com.example.sofia.app.sofia_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.IBinder
import org.altbeacon.beacon.*
import org.altbeacon.beacon.startup.BootstrapNotifier
import org.altbeacon.beacon.startup.RegionBootstrap

class BeaconMonitoringService : Service(), BootstrapNotifier {

    private lateinit var beaconManager: BeaconManager
    private lateinit var regionBootstrap: RegionBootstrap

    override fun onCreate() {
        super.onCreate()
        beaconManager = BeaconManager.getInstanceForApplication(this)

        // Specify the layout of your beacon to match the manufacturer's specification
        beaconManager.beaconParsers.clear()
        beaconManager.beaconParsers.add(BeaconParser().setBeaconLayout(BeaconParser.ALTBEACON_LAYOUT))

        val region = Region("myBeaconRegion", null, null, null)
        regionBootstrap = RegionBootstrap(this, region)

        // Create a notification channel and start foreground service with a notification
        startForegroundServiceWithNotification()
    }

    private fun startForegroundServiceWithNotification() {

        val channel = NotificationChannel(
            "MyForegroundServiceChannel", "Foreground Service Channel",
            NotificationManager.IMPORTANCE_LOW
        )
        (getSystemService(NOTIFICATION_SERVICE) as NotificationManager).createNotificationChannel(
            channel
        )


        val notification: Notification = Notification.Builder(this, channel.id)
            .setContentTitle("Beacon Monitoring")
            .setContentText("Scanning for Beacons")
            .setSmallIcon(R.drawable.ic_launcher)
            .build()

        startForeground(1, notification)
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun didEnterRegion(region: Region?) {
        // Called when a beacon in the region is detected
        // Implement your logic here for when entering a region
    }

    override fun didExitRegion(region: Region?) {
        // Called when no beacons in the region are visible
        // Implement your logic here for when exiting a region
    }

    override fun didDetermineStateForRegion(state: Int, region: Region?) {
        // Called when a region's state is determined
    }
}
