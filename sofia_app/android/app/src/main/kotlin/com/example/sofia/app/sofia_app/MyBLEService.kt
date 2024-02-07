package com.example.sofia.app.sofia_app

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.bluetooth.le.BluetoothLeScanner
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.IBinder
import android.util.Log
import androidx.core.app.ActivityCompat
import com.example.sofia.app.sofia_app.MainActivity
import com.example.sofia.app.sofia_app.R


class MyBLEService : Service() {

    private lateinit var bluetoothAdapter: BluetoothAdapter
    private lateinit var bluetoothLeScanner: BluetoothLeScanner

    // Flag to prevent showing notifications too frequently
    private var lastNotificationTime: Long = 0
    private val notificationCoolDown = 60 * 1000 // 1 minute cooldown
    private val notificationExitSeconds = 90 * 1000 // 1:30 minute cooldown
    private val selectBeacon = "2D7A9F0CE0E84CC9A71BA21DB2D034A1"

    override fun onBind(intent: Intent): IBinder? {
        return null
    }

    override fun onCreate() {
        super.onCreate()
        val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        bluetoothAdapter = bluetoothManager.adapter
        bluetoothLeScanner = bluetoothAdapter.bluetoothLeScanner
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {

        createNotificationChannel()
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        val notification: Notification = Notification.Builder(this, CHANNEL_ID)
            .setContentTitle("Beacon Monitoring")
            .setContentText("Scanning for iBeacons")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pendingIntent)
            .build()

        startForeground(1, notification)

        startScanning()
        return START_STICKY
    }

    private fun createNotificationChannel() {
        val serviceChannel = NotificationChannel(
            CHANNEL_ID,
            "BLE Service Channel",
            NotificationManager.IMPORTANCE_DEFAULT
        )
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(serviceChannel)
    }

    private fun startScanning() {
        val scanSettings = ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_LOW_POWER)
            .build()

        if (ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.BLUETOOTH_SCAN
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }
        bluetoothLeScanner.startScan(null, scanSettings, scanCallback)
        Log.d(TAG, "Scanning started")
    }

    private fun stopScanning() {
        if (ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.BLUETOOTH_SCAN
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }
        bluetoothLeScanner.stopScan(scanCallback)
        Log.d(TAG, "Scanning stopped")
    }

    override fun onDestroy() {
        super.onDestroy()
        stopScanning()
    }

    private val scanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult?) {
            super.onScanResult(callbackType, result)
            Log.d(TAG, "Scan Result: $result")

            val scanRecord = result?.scanRecord
            val iBeaconManufactureData = scanRecord?.getManufacturerSpecificData(0X004c)
            if (iBeaconManufactureData != null && iBeaconManufactureData.size >= 23) {
                val iBeaconUUID =
                    Utils.toHexString(iBeaconManufactureData.copyOfRange(2, 18))

                if (iBeaconUUID == selectBeacon) {
                    val major = Integer.parseInt(
                        Utils.toHexString(
                            iBeaconManufactureData.copyOfRange(
                                18,
                                20
                            )
                        ), 16
                    )
                    val minor = Integer.parseInt(
                        Utils.toHexString(
                            iBeaconManufactureData.copyOfRange(
                                20,
                                22
                            )
                        ), 16
                    )

                    Log.e(TAG, "iBeaconUUID:$iBeaconUUID major:$major minor:$minor")

                    // Check if the notification cooldown has passed
                    val currentTime = System.currentTimeMillis()
                    if (currentTime - lastNotificationTime >= notificationCoolDown) {
                        // Show notification
                        showNotification("Entered iBeacon Region")
                        lastNotificationTime = currentTime
                    }
                } else {
                    beaconExit()
                }
            } else {
                beaconExit()
            }
        }

        private fun beaconExit() {
            if (lastNotificationTime == 0L) return
            val currentTime = System.currentTimeMillis()
            if (currentTime - lastNotificationTime >= notificationExitSeconds) {
                // Show notification
                showNotification("Exit iBeacon Region")
                lastNotificationTime = 0
            }
        }
    }

    private fun showNotification(message: String) {
        // Create notification
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        val notification: Notification = Notification.Builder(this, CHANNEL_ID)
            .setContentTitle("iBeacon Notification")
            .setContentText(message)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pendingIntent)
            .build()

        // Show notification
        val notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(NOTIFICATION_ID, notification)
    }

    companion object {
        private const val TAG = "MyBLEService"
        const val CHANNEL_ID = "BLEServiceChannel"
        const val NOTIFICATION_ID = 1
    }
}