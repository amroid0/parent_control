package com.amroid.parent_control

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import androidx.core.app.NotificationCompat
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.ListenerRegistration
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.concurrent.ConcurrentHashMap

class AppUsageService : Service() {

    private val CHANNEL_ID = "AppUsageServiceChannel"
    private val NOTIFICATION_ID = 1
    private val appUsageMap = ConcurrentHashMap<String, App>()
    private val coroutineScope = CoroutineScope(Dispatchers.Default)
    private var overlayView: View? = null
    private var childId: String = ""
    private var firestoreListener: ListenerRegistration? = null

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        intent?.let {
            childId = it.getStringExtra("childId") ?: ""
        }
        createNotificationChannel()
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Kids Safe")
            .setContentText("Monitoring app usage...")
            .setSmallIcon(R.mipmap.ic_launcher)
            .build()
        startForeground(NOTIFICATION_ID, notification)

        startFetchingAppUsageInfo()
        setupFirestoreListener()
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        coroutineScope.cancel()
        removeOverlay()
        firestoreListener?.remove()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Foreground Service Channel",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    private fun startFetchingAppUsageInfo() {
        coroutineScope.launch {
            while (isActive) {
                fetchAppUsageInfo()
                delay(1 * 60 * 1000) // 1 minute
            }
        }
        coroutineScope.launch(Dispatchers.Main) {
            while (isActive) {
                checkForegroundApps()
                delay(5000) // 5 seconds
            }
        }
    }

    private suspend fun fetchAppUsageInfo() {
        withContext(Dispatchers.IO) {
            // Fetch the list of installed apps, excluding system apps
            val packageManager = packageManager
            val installedApps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
                .filter { (it.flags and ApplicationInfo.FLAG_SYSTEM) == 0 }

            // Fetch app package info and usage name
            val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val currentTime = System.currentTimeMillis()
            val startTime = currentTime - 24 * 60 * 60 * 1000 // 24 hours ago
            val usageStatsList = usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, startTime, currentTime)

            // Fetch the list of apps from Firestore
            val firestore = FirebaseFirestore.getInstance()
            firestore.collection("children")
                .document(childId)
                .collection("settings")
                .document("apps")
                .get()
                .addOnSuccessListener { documentSnapshot ->
                    if (documentSnapshot.exists()) {
                        val appsMap = documentSnapshot.data?.mapValues { entry ->
                            val appData = entry.value as Map<String, Any>
                            App(
                                packageName = appData["packageName"] as? String ?: "",
                                appName = appData["appName"] as? String ?: "",
                                isLocked = appData["locked"] as? Boolean ?: false,
                                usage = appData["usage"] as? Int ?: 0,
                                usageLimit = appData["usageLimit"] as? Long ?: 0,
                                currentTimeInMilli = appData["currentTimeInMilli"] as? Long ?: 0
                            )
                        } ?: mapOf()

                        for (appInfo in installedApps) {
                            val packageName = appInfo.packageName
                            val usageStats = usageStatsList.find { it.packageName == packageName }

                            if (usageStats != null) {
                                val appName = getAppNameFromPackage(packageName)
                                val usage = ((usageStats.totalTimeInForeground / (1000 * 60))).toInt() // in minutes

                                // Check if the app exists in Firestore
                                val remoteApp = appsMap.entries.find { it.value.packageName == packageName }
                                if (remoteApp != null) {
                                    val usageLimitMillis = remoteApp.value.usageLimit * 60 * 1000
                                    val remainingTimeMillis = remoteApp.value.currentTimeInMilli + usageLimitMillis - currentTime
                                    val isLocked = remoteApp.value.isLocked || (usageLimitMillis != 0L && remainingTimeMillis <= 0)

                                    val updatedApp = App(
                                        packageName = packageName,
                                        appName = appName,
                                        isLocked = isLocked,
                                        usage = usage,
                                        usageLimit = if (isLocked) 0 else remoteApp.value.usageLimit,
                                        currentTimeInMilli = if (isLocked) 0 else remoteApp.value.currentTimeInMilli
                                    )
                                    appUsageMap[packageName] = updatedApp
                                } else {
                                    // If the app does not exist in Firestore, add it with default values
                                    val defaultApp = App(
                                        packageName = packageName,
                                        appName = appName,
                                        isLocked = false,
                                        usage = usage,
                                        usageLimit = 0,
                                        currentTimeInMilli = 0
                                    )
                                    appUsageMap[packageName] = defaultApp
                                }
                            }
                        }

                        // Update Firestore with the new or updated apps list
                        firestore.collection("children")
                            .document(childId)
                            .collection("settings")
                            .document("apps")
                            .set(appUsageMap)
                    }
                }
                .addOnFailureListener { exception ->
                    Log.e("AppUsageService", "Error fetching remote data", exception)
                }
        }
    }

    private fun getAppNameFromPackage(packageName: String): String {
        val packageManager = packageManager
        return try {
            val applicationInfo = packageManager.getApplicationInfo(packageName, 0)
            packageManager.getApplicationLabel(applicationInfo).toString()
        } catch (e: PackageManager.NameNotFoundException) {
            packageName
        }
    }

    private fun checkForegroundApps() {
        val foregroundPackageName = getForegroundAppPackageName()
        val app = appUsageMap[foregroundPackageName]
        if (app != null && app.isLocked) {
            showOverlay(foregroundPackageName)
        } else {
            removeOverlay()
        }
    }

    private fun getForegroundAppPackageName(): String {
        var foregroundApp = ""

        val time = System.currentTimeMillis()

        val usageEvents = (getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager)
            .queryEvents(time - 1000 * 3600, time)
        val event = UsageEvents.Event()
        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                foregroundApp = event.packageName
            }
        }

        return foregroundApp
    }

    private fun showOverlay(packageName: String) {
        if (overlayView == null) {
            overlayView = LayoutInflater.from(this).inflate(R.layout.overlay_layout, null)
            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
                PixelFormat.OPAQUE
            )
            val windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
            windowManager.addView(overlayView, params)
        }
    }

    private fun removeOverlay() {
        if (overlayView != null) {
            val windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
            windowManager.removeView(overlayView)
            overlayView = null
        }
    }

    private fun setupFirestoreListener() {
        val firestore = FirebaseFirestore.getInstance()
        firestoreListener = firestore.collection("children")
            .document(childId)
            .collection("settings")
            .document("apps")
            .addSnapshotListener { snapshot, exception ->
                if (exception != null) {
                    Log.e("AppUsageService", "Error listening to Firestore", exception)
                    return@addSnapshotListener
                }

                if (snapshot != null && snapshot.exists()) {
                    val appsMap = snapshot.data?.mapValues { entry ->
                        val appData = entry.value as Map<String, Any>
                        App(
                            packageName = appData["packageName"] as? String ?: "",
                            appName = appData["appName"] as? String ?: "",
                            isLocked = appData["locked"] as? Boolean ?: false,
                            usage = appData["usage"] as? Int ?: 0,
                            usageLimit = appData["usageLimit"] as? Long ?: 0,
                            currentTimeInMilli = appData["currentTimeInMilli"] as? Long ?: 0
                        )
                    } ?: mapOf()

                    appUsageMap.clear()
                    appUsageMap.putAll(appsMap)

                    // Check the foreground app and update the overlay
                    checkForegroundApps()
                }
            }
    }
}