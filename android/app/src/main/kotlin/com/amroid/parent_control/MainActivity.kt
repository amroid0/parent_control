package com.amroid.parent_control

import android.app.AlertDialog
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
  private var childId: String? = ""

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "startAppUsageService" -> {
          childId = call.argument<String>("childId")
          requestPermissionsSequentially()
          result.success(null) // Permission request is asynchronous, so we return success here
        }
        else -> result.notImplemented()
      }
    }
  }

  private fun requestPermissionsSequentially() {
    if (!hasUsageAccessPermission()) {
      showUsageAccessPermissionDialog()
    } else if (!hasSystemAlertWindowPermission()) {
      showSystemAlertWindowPermissionDialog()
    } else {
      startAppUsageService(childId!!)
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

  private fun showUsageAccessPermissionDialog() {
    AlertDialog.Builder(this, R.style.CustomDialogTheme)
      .setTitle("Usage Access Permission")
      .setMessage("This app needs usage access permission to monitor app usage.")
      .setPositiveButton("Grant") { _, _ ->
        requestUsageAccessPermission()
      }
      .setNegativeButton("Cancel") { dialog, _ ->
        dialog.dismiss()
        // Handle the case where the user did not grant permission
      }
      .show()
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

  private fun showSystemAlertWindowPermissionDialog() {
    AlertDialog.Builder(this, R.style.CustomDialogTheme)
      .setTitle("System Alert Window Permission")
      .setMessage("This app needs system alert window permission to display overlays.")
      .setPositiveButton("Grant") { _, _ ->
        requestSystemAlertWindowPermission()
      }
      .setNegativeButton("Cancel") { dialog, _ ->
        dialog.dismiss()
        // Handle the case where the user did not grant permission
      }
      .show()
  }

  private fun requestSystemAlertWindowPermission() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName"))
      startActivityForResult(intent, REQUEST_CODE_SYSTEM_ALERT_WINDOW)
    }
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    super.onActivityResult(requestCode, resultCode, data)
    when (requestCode) {
      REQUEST_CODE_USAGE_ACCESS -> {
        if (hasUsageAccessPermission()) {
          requestPermissionsSequentially()
        } else {
          // Permission not granted
          // Handle the case where the user did not grant permission
        }
      }
      REQUEST_CODE_SYSTEM_ALERT_WINDOW -> {
        if (hasSystemAlertWindowPermission()) {
          requestPermissionsSequentially()
        } else {
          // Permission not granted
          // Handle the case where the user did not grant permission
        }
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