package juniojsv.minimum

import android.app.Activity
import android.content.Intent
import android.content.Intent.ACTION_DELETE
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class ApplicationsManagerPlugin : FlutterPlugin, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var pm: PackageManager
    private lateinit var activity: Activity

    companion object {
        const val CHANNEL_NAME = "juniojsv.minimum/applications_manager_plugin"
        const val GET_INSTALLED_APPLICATIONS = "get_installed_applications"
        const val LAUNCH_APPLICATION = "launch_application"
        const val GET_APPLICATION_ICON = "get_application_icon"
        const val IS_ALREADY_CURRENT_LAUNCHER = "is_already_current_launcher"
        const val OPEN_CURRENT_LAUNCHER_SYSTEM_SETTINGS = "open_current_launcher_system_settings"
        const val OPEN_APPLICATION_DETAILS = "open_application_details"
        const val UNINSTALL_APPLICATION = "uninstall_application"
        const val GET_APPLICATION = "get_application"
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
            GET_APPLICATION_ICON -> getApplicationIcon(call, result)
            IS_ALREADY_CURRENT_LAUNCHER -> result.success(isAlreadyCurrentLauncher())
            OPEN_CURRENT_LAUNCHER_SYSTEM_SETTINGS -> {
                val intent = Intent(Settings.ACTION_HOME_SETTINGS)
                activity.startActivity(intent)
            }

            OPEN_APPLICATION_DETAILS -> openApplicationDetails(call, result)
            UNINSTALL_APPLICATION -> uninstallApplication(call, result)
            GET_APPLICATION -> getApplication(call, result)
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

        val json = mutableListOf<Map<String, Any>>()

        for (app in apps) {
            val packageName = app.packageName
            val isMinimumAppPackage = packageName == BuildConfig.APPLICATION_ID
            val isLaunchable = pm.getLaunchIntentForPackage(packageName) != null
            if (!isMinimumAppPackage && isLaunchable) {
                json.add(getApplicationJson(app, flags))
            }
        }

        result.success(json)
    }

    private fun getApplicationJson(app: ApplicationInfo, flags: Int): Map<String, Any> {
        val packageName = app.packageName
        val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.getPackageInfo(
                packageName,
                PackageManager.PackageInfoFlags.of(flags.toLong())
            )
        } else {
            pm.getPackageInfo(packageName, flags)
        }

        return mapOf(
            "label" to app.loadLabel(pm) as String,
            "package" to packageName,
            "version" to packageInfo.versionName
        );
    }

    private fun getApplication(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        val flags = PackageManager.GET_META_DATA
        val packageName = getPackageNameFromMethodCall(call, result) ?: return
        try {
            val app = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm.getApplicationInfo(
                    packageName,
                    PackageManager.ApplicationInfoFlags.of(flags.toLong())
                )
            } else {
                pm.getApplicationInfo(packageName, flags)
            }
            result.success(getApplicationJson(app, flags))
        } catch (e: Exception) {
            result.error(GET_APPLICATION, e.message, null)
        }
    }

    private fun getPackageNameFromMethodCall(
        call: MethodCall,
        result: MethodChannel.Result
    ): String? {
        val packageName = call.argument<String>("package_name")
        if (packageName == null) {
            result.error("package_name_is_null", null, null)
        }

        return packageName;
    }

    private fun launchApplication(call: MethodCall, result: MethodChannel.Result) {
        val packageName = getPackageNameFromMethodCall(call, result) ?: return
        try {
            val intent = pm.getLaunchIntentForPackage(packageName)
            if (intent == null) {
                result.error("cant_launch_$packageName", null, null)
            }
            activity.startActivity(intent)
            result.success(null)
        } catch (e: Exception) {
            result.error(LAUNCH_APPLICATION, e.message, null)
        }
    }

    private fun getApplicationIcon(call: MethodCall, result: MethodChannel.Result) {
        val packageName = getPackageNameFromMethodCall(call, result) ?: return
        try {
            val icon = pm.getApplicationIcon(packageName)
            val bitmap = Bitmap.createBitmap(
                icon.intrinsicWidth,
                icon.intrinsicHeight,
                Bitmap.Config.ARGB_8888
            )
            val canvas = Canvas(bitmap)
            icon.setBounds(0, 0, canvas.width, canvas.height)
            icon.draw(canvas)
            val bytes = ByteArrayOutputStream().use {
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, it)
                it.toByteArray()
            }
            result.success(bytes)
        } catch (e: Exception) {
            result.error(GET_APPLICATION_ICON, e.message, null)
        }
    }

    private fun openApplicationDetails(call: MethodCall, result: MethodChannel.Result) {
        val packageName = getPackageNameFromMethodCall(call, result) ?: return
        try {
            activity.startActivity(
                Intent(
                    Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                    Uri.parse("package:${packageName}")
                )
            )
            result.success(null)
        } catch (e: Exception) {
            result.error(OPEN_APPLICATION_DETAILS, e.message, null)
        }
    }

    private fun uninstallApplication(call: MethodCall, result: MethodChannel.Result) {
        val packageName = getPackageNameFromMethodCall(call, result) ?: return
        try {
            activity.startActivity(
                Intent(
                    ACTION_DELETE,
                    Uri.parse("package:${packageName}")
                )
            )
            result.success(null)
        } catch (e: Exception) {
            result.error(UNINSTALL_APPLICATION, e.message, null)
        }
    }

    private fun isAlreadyCurrentLauncher(): Boolean {
        return getCurrentLauncherClassName() == activity.componentName.className
    }

    private fun getCurrentLauncherClassName(): String? {
        return pm.resolveActivity(Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            addCategory(Intent.CATEGORY_DEFAULT)
        }, PackageManager.MATCH_DEFAULT_ONLY)?.activityInfo?.name
    }
}