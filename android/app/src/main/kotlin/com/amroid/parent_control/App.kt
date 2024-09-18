package com.amroid.parent_control
import com.google.firebase.firestore.IgnoreExtraProperties
@IgnoreExtraProperties

data class App(
    val packageName: String="",
    val appName: String="",
    var isLocked: Boolean=false,
    var usage: Int= 0,
    val usageLimit: Int=0,
    var currentTimeInMilli: Long = 0
){

}
data class UsageInfo(
    val packageName: String,
    val totalTimeInForeground: Long
)

data class InstalledApp(
    val packageName: String,
    val name: String
)
@IgnoreExtraProperties
data class FirestoreSettings(
    val apps: Map<String,App>? =null
)