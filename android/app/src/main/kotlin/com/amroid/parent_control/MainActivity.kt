package com.amroid.parent_control

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.AdaptiveIconDrawable
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.graphics.drawable.VectorDrawable
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.HashMap

class MainActivity : FlutterActivity() {
  private val CHANNEL = "com.amroid.parent_control/app_usage"

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      if (call.method == "getAppUsageData") {
        val appUsageData = getAppUsageData()
        if (appUsageData != null) {
          result.success(appUsageData)
        } else {
          result.error("UNAVAILABLE", "App usage data not available.", null)
        }
      } else {
        result.notImplemented()
      }
    }
  }

  private fun getAppUsageData(): Map<String, Any>? {
    val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
    val endTime = System.currentTimeMillis()
    val startTime = endTime - 1000 * 60 * 60 * 24 // Last 24 hours
    val usageStatsList = usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, startTime, endTime)

    val appUsageData = HashMap<String, Any>()
    for (usageStats in usageStatsList) {
      val appData = HashMap<String, Any>()
      appData["packageName"] = usageStats.packageName as String
      appData["totalTimeInForeground"] = usageStats.totalTimeInForeground / 60000
      appUsageData[usageStats.packageName] = appData
    }

    return appUsageData
  }
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    requestUsageStatsPermission(this)
  }

  private fun requestUsageStatsPermission(context: Context) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
      val mode = appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, android.os.Process.myUid(), context.packageName)
      if (mode != AppOpsManager.MODE_ALLOWED) {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        context.startActivity(intent)
      }
    }
  }
}
