package juniojsv.minimum

import android.app.Activity
import android.content.Intent
import android.content.Intent.ACTION_DELETE
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import juniojsv.minimum.utils.toByteArray
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.launch
import kotlin.coroutines.CoroutineContext

class ApplicationsManagerPlugin : FlutterPlugin, ActivityAware, CoroutineScope {
    private lateinit var channel: MethodChannel
    private lateinit var pm: PackageManager
    private lateinit var activity: Activity
    override val coroutineContext: CoroutineContext
        get() = Dispatchers.Default + Job()

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
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME).apply {
            setMethodCallHandler(::onMethodCall)
        }
        pm = binding.applicationContext.packageManager
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
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

    private fun getInstalledApplications(result: MethodChannel.Result) = launch {
        val flags = PackageManager.GET_META_DATA
        val infos = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.getInstalledApplications(PackageManager.ApplicationInfoFlags.of(flags.toLong()))
        } else {
            pm.getInstalledApplications(flags)
        }

        val applications = infos.map { app ->
            async {
                val packageName = app.packageName
                val isMinimumAppPackage = packageName == BuildConfig.APPLICATION_ID
                val isLaunchable = pm.getLaunchIntentForPackage(packageName) != null
                if (!isMinimumAppPackage && isLaunchable) {
                    return@async getApplicationJson(app, flags)
                }
                return@async null
            }
        }.awaitAll().filterNotNull()

        result.success(applications)
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
        try {
            val packageName = call.argument<String>("package_name")!!
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

    private fun launchApplication(call: MethodCall, result: MethodChannel.Result) {
        try {
            val packageName = call.argument<String>("package_name")!!
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

    private fun getApplicationIcon(call: MethodCall, result: MethodChannel.Result) = launch {
        try {
            val packageName = call.argument<String>("package_name")
            val size = call.argument<Int>("size")
            val icon = if (packageName != null)
                pm.getApplicationIcon(packageName)
            else activity.getDrawable(android.R.drawable.sym_def_app_icon)!!
            result.success(icon.toByteArray(size, size))
        } catch (e: Exception) {
            result.error(GET_APPLICATION_ICON, e.message, null)
        }
    }

    private fun openApplicationDetails(call: MethodCall, result: MethodChannel.Result) {
        try {
            val packageName = call.argument<String>("package_name")!!
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
        try {
            val packageName = call.argument<String>("package_name")!!
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