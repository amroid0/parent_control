package com.amroid.parent_control

import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.PixelFormat
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.location.Location
import android.location.LocationManager
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.common.api.GoogleApiClient
import com.google.android.gms.location.LocationRequest
import com.google.firebase.firestore.FieldPath
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.ListenerRegistration
import com.google.firebase.storage.FirebaseStorage
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream
import java.util.concurrent.ConcurrentHashMap

class AppUsageService : Service() {

  private val CHANNEL_ID = "AppUsageServiceChannel"
  private val NOTIFICATION_ID = 1
  private val appUsageMap = ConcurrentHashMap<String, App>()
  private val coroutineScope = CoroutineScope(Dispatchers.Default)
  private var overlayView: View? = null
  private var childId: String = ""
  private var firestoreListener: ListenerRegistration? = null
  private var wakelock: PowerManager.WakeLock? = null
  internal var requestID = 10001
  private var thread: ContinousThread? = null
  @Volatile
  private var isRunning = false
  private var locationManager: LocationManager? = null
  internal inner class ContinousThread : Thread() {
    var i: Long = 0
    override fun run() {
      while (isRunning) {
        try {
          sleep(20000)
          getLastKnownLocation()?.let {
            updateLocationInFirestore(it)
          }
          i++


          if (i % 4 == 0L) {
            //locationCheck()
          }

          if (i % 20 == 0L) {
            //connectivityCheck()
          }

        } catch (e: InterruptedException) {
          isRunning = false
        }

      }
    }
  }

    private fun getLastKnownLocation(): Location? {
      if (ContextCompat.checkSelfPermission(
          this,
          android.Manifest.permission.ACCESS_FINE_LOCATION
        ) != PackageManager.PERMISSION_GRANTED || ContextCompat.checkSelfPermission(
          this,
          android.Manifest.permission.ACCESS_COARSE_LOCATION
        ) != PackageManager.PERMISSION_GRANTED
      )
        return null
      val providers = locationManager!!.getProviders(true)
      var bestLocation: Location? = null
      for (provider in providers) {
        val location = locationManager!!.getLastKnownLocation(provider) ?: continue

        if (bestLocation == null || location.accuracy < bestLocation.accuracy) {
          bestLocation = location
        }
      }
      return bestLocation
    }

  override fun onCreate() {
    super.onCreate()

    val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
    wakelock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "medium:wakelock")

    thread = ContinousThread()

    init()
  }


  private fun init() {
    wakelock!!.acquire()
    if (!isRunning) {
      isRunning = true
      thread!!.start()
      locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
    }
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

  override fun onBind(p0: Intent?): IBinder? {
    return null
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
        delay(1 * 60 * 1000)
      }
    }
    coroutineScope.launch(Dispatchers.Main) {
      while (isActive) {
        checkForegroundApps()
        delay(5000)
      }
    }
  }


  private suspend fun fetchAppUsageInfo() {
    withContext(Dispatchers.IO) {
      val packageManager = packageManager
      val installedApps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
        .filter { (it.flags and ApplicationInfo.FLAG_SYSTEM) == 0 }

      val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
      val currentTime = System.currentTimeMillis()
      val startTime = currentTime - 24 * 60 * 60 * 1000 // 24 hours ago
      val usageStatsList =
        usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, startTime, currentTime)

      val firestore = FirebaseFirestore.getInstance()
      val documentSnapshot = firestore.collection("children")
        .document(childId)
        .collection("settings")
        .document("apps")
        .get()
        .await()

      val appUsageMap = mutableMapOf<String, App>()


        val appsMap = documentSnapshot.data?.mapValues { entry ->
          val appData = entry.value as Map<String, Any>
          App(
            packageName = appData["packageName"] as? String ?: "",
            appName = appData["appName"] as? String ?: "",
            iconUrl = appData["iconUrl"] as? String ?: "",
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
            val appIcon = getAppIconFromPackage(packageName, appInfo)
            val usage = ((usageStats.totalTimeInForeground / (1000 * 60))).toInt() // in minutes

            val remoteApp = appsMap[packageName]
            if (remoteApp != null) {
              val usageLimitMillis = remoteApp.usageLimit * 60 * 1000
              val remainingTimeMillis =
                remoteApp.currentTimeInMilli + usageLimitMillis - currentTime
              val isLocked =
                remoteApp.isLocked || (usageLimitMillis != 0L && remainingTimeMillis <= 0)

              val updatedApp = App(
                packageName = packageName,
                appName = appName,
                iconUrl = remoteApp.iconUrl,
                isLocked = isLocked,
                usage = usage,
                usageLimit = if (isLocked) 0 else remoteApp.usageLimit,
                currentTimeInMilli = if (isLocked) 0 else remoteApp.currentTimeInMilli
              )
              appUsageMap[packageName] = updatedApp
            } else {
              val defaultApp = App(
                packageName = packageName,
                appName = appName,
                iconUrl = null,
                isLocked = false,
                usage = usage,
                usageLimit = 0,
                currentTimeInMilli = 0
              )
              appUsageMap[packageName] = defaultApp
            }
          }
        }

        // Push all data to Firestore first
        firestore.collection("children")
          .document(childId)
          .collection("settings")
          .document("apps")
          .set(appUsageMap)
          .await()

        // Upload icons and update Firestore with icon URLs concurrently
        for (appInfo in installedApps) {
          val packageName = appInfo.packageName
          val remoteApp = appsMap[packageName]

          // Check if the remote app's icon URL already exists
          if (remoteApp?.iconUrl == null) {
            launch {
              val appIcon = getAppIconFromPackage(packageName, appInfo)

              if (appIcon != null) {
                val bitmap = drawableToBitmap(appIcon)
                val iconByteArray = bitmapToByteArray(bitmap)
                val downloadUrl = uploadIconToFirebaseStorage(packageName, iconByteArray)

                val app = appUsageMap[packageName]
                if (app != null) {
                  app.iconUrl = downloadUrl
                  appUsageMap[packageName] = app

                  val field = FieldPath.of(packageName)
                  firestore.collection("children")
                    .document(childId)
                    .collection("settings")
                    .document("apps")
                    .update(field, app)
                    .await()
                }
              }
            }
          }
        }
      }
  }





  private fun drawableToBitmap(drawable: Drawable): Bitmap {
    if (drawable is BitmapDrawable) {
      return drawable.bitmap
    }

    val width = drawable.intrinsicWidth
    val height = drawable.intrinsicHeight

    val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(bitmap)
    drawable.setBounds(0, 0, canvas.width, canvas.height)
    drawable.draw(canvas)

    return bitmap
  }

  private fun bitmapToByteArray(bitmap: Bitmap): ByteArray {
    val stream = ByteArrayOutputStream()
    bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
    return stream.toByteArray()
  }

  private suspend fun uploadIconToFirebaseStorage(packageName: String, iconByteArray: ByteArray): String {
    val storage = FirebaseStorage.getInstance().reference
    val iconRef = storage.child("app_icons/$packageName.png")
    val uploadTask = iconRef.putBytes(iconByteArray).await()
    val downloadUrl = iconRef.downloadUrl.await().toString()
    return downloadUrl
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

  private fun getAppIconFromPackage(packageName: String, appInfo: ApplicationInfo): Drawable? {
    val packageManager = packageManager
    return try {
      val applicationInfo = packageManager.getApplicationInfo(packageName, 0)
      packageManager.getApplicationIcon(applicationInfo)
    } catch (e: PackageManager.NameNotFoundException) {
      appInfo.loadIcon(packageManager)
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

          checkForegroundApps()
        }
      }
  }




  private fun updateLocationInFirestore(location: Location?) {
    if (location == null) return

    val firestore = FirebaseFirestore.getInstance()
    firestore.collection("children")
      .document(childId)
      .collection("locations")
      .document("latest").set(
        mapOf(
          "latitude" to location.latitude,
          "longitude" to location.longitude,
          "timestamp" to System.currentTimeMillis()
        )
      )
      .addOnSuccessListener {
        Log.d("AppUsageService", "Location updated in Firestore")
      }
      .addOnFailureListener { exception ->
        Log.e("AppUsageService", "Error updating location in Firestore", exception)
      }
  }
}