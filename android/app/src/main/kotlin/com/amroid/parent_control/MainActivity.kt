package com.amroid.parent_control

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
class MainActivity : FlutterActivity() {
  private val CHANNEL = "com.amroid.parent_control/app_usage"
  private val REQUEST_CODE_USAGE_ACCESS = 123
  private val REQUEST_CODE_SYSTEM_ALERT_WINDOW = 124

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "startAppUsageService" -> {
          val childId = call.argument<String>("childId")
          if (childId != null) {
            if (hasUsageAccessPermission() && hasSystemAlertWindowPermission()) {
              startAppUsageService(childId)
              result.success(null)
            } else {
              if (!hasUsageAccessPermission()) {
                requestUsageAccessPermission()
              }
              if (!hasSystemAlertWindowPermission()) {
                requestSystemAlertWindowPermission()
              }
              result.success(null) // Permission request is asynchronous, so we return success here
            }
          } else {
            result.error("INVALID_ARGUMENT", "Child ID is null", null)
          }
        }
        else -> result.notImplemented()
      }
    }
  }

  private fun hasUsageAccessPermission(): Boolean {
    val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
    val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      appOps.unsafeCheckOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
    } else {
      appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
    }
    return mode == AppOpsManager.MODE_ALLOWED
  }

  private fun requestUsageAccessPermission() {
    val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
    startActivityForResult(intent, REQUEST_CODE_USAGE_ACCESS)
  }

  private fun hasSystemAlertWindowPermission(): Boolean {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      Settings.canDrawOverlays(this)
    } else {
      true
    }
  }

  private fun requestSystemAlertWindowPermission() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName"))
      startActivityForResult(intent, REQUEST_CODE_SYSTEM_ALERT_WINDOW)
    }
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    super.onActivityResult(requestCode, resultCode, data)
    if (requestCode == REQUEST_CODE_USAGE_ACCESS) {
      if (hasUsageAccessPermission()) {
        // Permission granted, start the service
        val childId = intent.getStringExtra("childId") ?: ""
        startAppUsageService(childId)
      } else {
        // Permission not granted
        // Handle the case where the user did not grant permission
      }
    } else if (requestCode == REQUEST_CODE_SYSTEM_ALERT_WINDOW) {
      if (hasSystemAlertWindowPermission()) {
        // Permission granted, start the service
        val childId = intent.getStringExtra("childId") ?: ""
        startAppUsageService(childId)
      } else {
        // Permission not granted
        // Handle the case where the user did not grant permission
      }
    }
  }

  private fun startAppUsageService(childId: String) {
    val intent = Intent(this, AppUsageService::class.java).apply {
      putExtra("childId", childId)
    }
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      startForegroundService(intent)
    } else {
      startService(intent)
    }
  }
}