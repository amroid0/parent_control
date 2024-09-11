package com.amroid.parent_control

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.app.admin.DevicePolicyManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class AppUsageMonitorService : Service() {

    private lateinit var usageStatsManager: UsageStatsManager
    private val appUsageLimits = mutableMapOf<String, Long>()

    override fun onCreate() {
        super.onCreate()
        usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        createNotificationChannel()
        startForeground(1, createNotification())
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        monitorAppUsage()
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    private fun monitorAppUsage() {
        Thread {
            while (true) {
                val endTime = System.currentTimeMillis()
                val startTime = endTime - 1000 * 60 * 60 * 24 // Last 24 hours
                val usageStatsList = usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, startTime, endTime)

                for (usageStats in usageStatsList) {
                    val packageName = usageStats.packageName
                    val totalTimeInForeground = usageStats.totalTimeInForeground

                    if (appUsageLimits.containsKey(packageName) && totalTimeInForeground > appUsageLimits[packageName]!!) {
                        lockApp(packageName)
                    }
                }

                Thread.sleep(1000 * 60) // Check every minute
            }
        }.start()
    }

    private fun lockApp(packageName: String) {
        val devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val componentName = ComponentName(this, AppDeviceAdminReceiver::class.java)

        if (devicePolicyManager.isAdminActive(componentName)) {
            devicePolicyManager.lockNow()
        } else {
            // Request device admin activation
            val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN)
            intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, componentName)
            intent.putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION, "Enable device admin to lock apps.")
            startActivity(intent)
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "app_usage_monitor_channel",
                "App Usage Monitor",
                NotificationManager.IMPORTANCE_LOW
            )
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE)

        return NotificationCompat.Builder(this, "app_usage_monitor_channel")
            .setContentTitle("App Usage Monitor")
            .setContentText("Monitoring app usage...")
            .setSmallIcon(R.drawable.launch_background)
            .setContentIntent(pendingIntent)
            .build()
    }
}