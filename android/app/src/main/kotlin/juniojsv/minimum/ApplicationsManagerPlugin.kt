package juniojsv.minimum

import android.app.Activity
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ApplicationsManagerPlugin : FlutterPlugin, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var pm: PackageManager
    private lateinit var activity: Activity

    companion object {
        const val CHANNEL_NAME = "juniojsv.minimum/applications_manager_plugin"
        const val GET_INSTALLED_APPLICATIONS = "get_installed_applications"
        const val LAUNCH_APPLICATION = "launch_application"
        const val TAG = "Plugin"
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onAttachedToEngine")
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME).apply {
            setMethodCallHandler(::onMethodCall)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onDetachedFromEngine")
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.d(TAG, "onAttachedToActivity")
        activity = binding.activity
        pm = binding.activity.packageManager
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Log.d(TAG, "onDetachedFromActivityForConfigChanges")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Log.d(TAG, "onReattachedToActivityForConfigChanges")
    }

    override fun onDetachedFromActivity() {
        Log.d(TAG, "onDetachedFromActivity")
    }

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            GET_INSTALLED_APPLICATIONS -> getInstalledApplications(result)
            LAUNCH_APPLICATION -> launchApplication(call, result)
            else -> result.notImplemented()
        }
    }

    private fun getInstalledApplications(result: MethodChannel.Result) {
        val flags = PackageManager.GET_META_DATA
        val apps = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.getInstalledApplications(PackageManager.ApplicationInfoFlags.of(flags.toLong()))
        } else {
            pm.getInstalledApplications(flags)
        }

        val json = mutableListOf<Map<String, String>>()

        for (app in apps) {
            val packageName = app.packageName
            val isMinimumAppPackage = packageName == BuildConfig.APPLICATION_ID
            val isLaunchable = pm.getLaunchIntentForPackage(packageName) != null
            if (!isMinimumAppPackage && isLaunchable) {
                json.add(
                    mapOf(
                        "label" to app.loadLabel(pm) as String,
                        "package" to packageName
                    )
                )
            }
        }

        result.success(json)
    }

    private fun launchApplication(call: MethodCall, result: MethodChannel.Result) {
        val packageName = call.argument<String>("package_name")
        if (packageName == null) {
            result.error("package_name_is_null", null, null)
            return
        }
        try {
            val intent = pm.getLaunchIntentForPackage(packageName)
            if (intent == null) {
                result.error("cant_launch_$packageName", null, null)
            }
            activity.startActivity(intent)
            result.success(null)
        } catch (e: Exception) {
            result.error("launch_application", e.message, null)
        }
    }
}