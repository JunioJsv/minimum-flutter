package juniojsv.minimum

import android.app.Activity
import android.content.Intent
import android.content.Intent.ACTION_DELETE
import android.content.pm.LauncherApps
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.os.UserHandle
import android.provider.Settings
import android.util.Log
import androidx.core.content.getSystemService
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import juniojsv.minimum.models.Application
import juniojsv.minimum.models.IconPack
import juniojsv.minimum.utils.IconPackManager
import juniojsv.minimum.utils.toByteArray
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlin.coroutines.CoroutineContext

class ApplicationsManagerPlugin : FlutterPlugin, ActivityAware, CoroutineScope {
    private lateinit var channel: MethodChannel
    private lateinit var activity: Activity
    private lateinit var user: UserHandle
    private lateinit var packageManager: PackageManager
    private lateinit var launcherManager: LauncherApps
    private lateinit var launcherManagerListener: ApplicationsEvents
    private lateinit var iconPackManager: IconPackManager
    private var iconPackPackageName: String? = null
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
        const val GET_ICON_PACKS = "get_icon_packs"
        const val SET_ICON_PACK = "set_icon_pack"
        const val IS_APPLICATION_ENABLED = "is_application_enabled"
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME).apply {
            setMethodCallHandler(::onMethodCall)
        }
        user = android.os.Process.myUserHandle()
        packageManager = binding.applicationContext.packageManager
        launcherManagerListener = ApplicationsEvents(binding)
        launcherManager = binding
            .applicationContext
            .getSystemService<LauncherApps>()!!.apply {
                registerCallback(launcherManagerListener)
            }
        iconPackManager = IconPackManager().apply {
            setContext(binding.applicationContext)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        launcherManager.unregisterCallback(launcherManagerListener.apply { dispose() })
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
            GET_ICON_PACKS -> getIconPacks(result)
            SET_ICON_PACK -> setIconPack(call, result)
            IS_APPLICATION_ENABLED -> isApplicationEnabled(call, result)
            else -> result.notImplemented()
        }
    }

    private fun getPackageInfo(packageName: String): PackageInfo {
        val flags = PackageManager.GET_META_DATA
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.getPackageInfo(
                packageName,
                PackageManager.PackageInfoFlags.of(flags.toLong())
            )
        } else {
            packageManager.getPackageInfo(packageName, flags)
        }
    }

    private fun isApplicationEnabled(call: MethodCall, result: MethodChannel.Result) {
        try {
            val packageName = call.argument<String>("package_name")!!
            result.success(getPackageInfo(packageName).applicationInfo.enabled)
        } catch (e: Exception) {
            result.error(IS_APPLICATION_ENABLED, e.message, null)
        }
    }


    private fun getInstalledApplications(result: MethodChannel.Result) = launch {
        try {
            val activities = launcherManager.getActivityList(null, user)
            val applications = activities.mapNotNull {
                val label = it.label as String
                val packageName = it.applicationInfo.packageName
                val versionName = getPackageInfo(packageName).versionName
                if (packageName == BuildConfig.APPLICATION_ID) return@mapNotNull null
                Application(label, packageName, versionName).serialize()
            }
            result.success(applications)
        } catch (e: Exception) {
            result.error(GET_INSTALLED_APPLICATIONS, e.message, null)
        }
    }

    private fun getApplication(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        try {
            val packageName = call.argument<String>("package_name")!!
            val application = launcherManager.getActivityList(packageName, user).first().let {
                val label = it.label as String
                val versionName = getPackageInfo(packageName).versionName
                Application(label, packageName, versionName).serialize()
            }
            result.success(application)
        } catch (e: Exception) {
            result.error(GET_APPLICATION, e.message, null)
        }
    }

    private fun setIconPack(call: MethodCall, result: MethodChannel.Result) = launch {
        try {
            val packageName = call.argument<String>("package_name")
            if (packageName == null) {
                iconPackPackageName = null
                result.success(true)
            } else {
                val iconPacks = iconPackManager.getAvailableIconPacks(false)
                val iconPack = iconPacks[packageName]?.let {
                    it.load()
                    it
                }
                if (iconPack != null) {
                    iconPackPackageName = packageName
                }
                result.success(iconPack != null)
            }
        } catch (e: Exception) {
            result.error(GET_ICON_PACKS, e.message, null)
        }
    }

    private fun getIconPacks(result: MethodChannel.Result) {
        try {
            val iconPacks = iconPackManager.getAvailableIconPacks(true).values

            result.success(iconPacks.map {
                IconPack(it.name, it.packageName).serialize()
            })
        } catch (e: Exception) {
            result.error(GET_ICON_PACKS, e.message, null)
        }
    }

    private fun launchApplication(call: MethodCall, result: MethodChannel.Result) {
        try {
            val packageName = call.argument<String>("package_name")!!
            val info = launcherManager.getActivityList(packageName, user).first()
            launcherManager.startMainActivity(info.componentName, user, null, null)
            result.success(null)
        } catch (e: Exception) {
            result.error(LAUNCH_APPLICATION, e.message, null)
        }
    }

    private fun getApplicationIcon(call: MethodCall, result: MethodChannel.Result) = launch {
        try {
            var icon: Drawable? = null
            val packageName = call.argument<String>("package_name")
            val size = call.argument<Int>("size")

            if (packageName != null && iconPackPackageName != null) {
                try {
                    val iconPacks = iconPackManager.getAvailableIconPacks(false)
                    icon = iconPacks[iconPackPackageName]
                        ?.getDrawableIconForPackage(packageName, null)
                } catch (e: Exception) {
                    Log.e(GET_APPLICATION_ICON, e.message, null)
                }
            }

            if (icon == null) {
                icon = if (packageName != null)
                    packageManager.getApplicationIcon(packageName)
                else activity.getDrawable(android.R.drawable.sym_def_app_icon)!!
            }
            result.success(icon.toByteArray(size, size))
        } catch (e: Exception) {
            result.error(GET_APPLICATION_ICON, e.message, null)
        }
    }

    private fun openApplicationDetails(call: MethodCall, result: MethodChannel.Result) {
        try {
            val packageName = call.argument<String>("package_name")!!
            val info = launcherManager.getActivityList(packageName, user).first()
            launcherManager
                .startAppDetailsActivity(info.componentName, user, null, null)
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
        return packageManager.resolveActivity(Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            addCategory(Intent.CATEGORY_DEFAULT)
        }, PackageManager.MATCH_DEFAULT_ONLY)?.activityInfo?.name
    }
}