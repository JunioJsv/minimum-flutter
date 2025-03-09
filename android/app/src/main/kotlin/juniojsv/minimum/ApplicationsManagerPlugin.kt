package juniojsv.minimum

import android.app.Activity
import android.content.ComponentName
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
        const val GET_PACKAGE_ICON = "get_package_icon"
        const val IS_ALREADY_CURRENT_LAUNCHER = "is_already_current_launcher"
        const val OPEN_CURRENT_LAUNCHER_SYSTEM_SETTINGS = "open_current_launcher_system_settings"
        const val OPEN_APPLICATION_DETAILS = "open_application_details"
        const val UNINSTALL_PACKAGE = "uninstall_package"
        const val GET_APPLICATION = "get_application"
        const val GET_PACKAGE_APPLICATIONS = "get_package_applications"
        const val GET_ICON_PACKS = "get_icon_packs"
        const val SET_ICON_PACK = "set_icon_pack"
        const val IS_PACKAGE_ENABLED = "is_package_enabled"
        const val GET_ICON_PACK_DRAWABLES = "get_icon_pack_drawables"
        const val GET_ICON_FROM_ICON_PACK = "get_icon_from_icon_pack"
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
            GET_PACKAGE_ICON -> getPackageIcon(call, result)
            IS_ALREADY_CURRENT_LAUNCHER -> result.success(isAlreadyCurrentLauncher())
            OPEN_CURRENT_LAUNCHER_SYSTEM_SETTINGS -> {
                val intent = Intent(Settings.ACTION_HOME_SETTINGS)
                activity.startActivity(intent)
            }

            OPEN_APPLICATION_DETAILS -> openApplicationDetails(call, result)
            UNINSTALL_PACKAGE -> uninstallPackage(call, result)
            GET_APPLICATION -> getApplication(call, result)
            GET_PACKAGE_APPLICATIONS -> getPackageApplications(call, result)
            GET_ICON_PACKS -> getIconPacks(result)
            SET_ICON_PACK -> setIconPack(call, result)
            IS_PACKAGE_ENABLED -> isPackageEnabled(call, result)
            GET_ICON_PACK_DRAWABLES -> getIconPackDrawables(call, result)
            GET_ICON_FROM_ICON_PACK -> getIconFromIconPack(call, result)
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

    private fun isPackageEnabled(call: MethodCall, result: MethodChannel.Result) {
        try {
            val packageName = call.argument<String>("package_name")!!
            val isEnabled = getPackageInfo(packageName).applicationInfo?.enabled ?: false
            result.success(isEnabled)
        } catch (e: Exception) {
            result.error(IS_PACKAGE_ENABLED, e.message, null)
        }
    }


    private fun getInstalledApplications(result: MethodChannel.Result) = launch {
        try {
            val activities = launcherManager.getActivityList(null, user)
            val applications = activities.mapNotNull {
                val label = it.label as String
                val componentName = it.componentName
                val packageName = componentName.packageName
                val versionName = getPackageInfo(packageName).versionName ?: ""
                if (packageName == BuildConfig.APPLICATION_ID) return@mapNotNull null
                Application(
                    label,
                    packageName,
                    componentName.flattenToString(),
                    versionName
                ).serialize()
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
            val componentName = call.argument<String>("component_name")!!
                .let { ComponentName.unflattenFromString(it)!! }
            val packageName = componentName.packageName;
            val application = launcherManager.getActivityList(packageName, user).first {
                it.componentName == componentName
            }.let {
                val label = it.label as String
                val versionName = getPackageInfo(packageName).versionName ?: ""
                Application(
                    label,
                    packageName,
                    componentName.flattenToString(),
                    versionName
                ).serialize()
            }
            result.success(application)
        } catch (e: Exception) {
            result.error(GET_APPLICATION, e.message, null)
        }
    }

    private fun getPackageApplications(call: MethodCall, result: MethodChannel.Result) {
        try {
            val packageName = call.argument<String>("package_name")!!
            val applications = launcherManager.getActivityList(packageName, user).map {
                val label = it.label as String
                val componentName = it.componentName
                val versionName = getPackageInfo(packageName).versionName ?: ""
                Application(
                    label,
                    packageName,
                    componentName.flattenToString(),
                    versionName
                ).serialize()
            }
            result.success(applications)
        } catch (e: Exception) {
            result.error(GET_PACKAGE_APPLICATIONS, e.message, null)
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
            val componentName = call.argument<String>("component_name")!!
                .let { ComponentName.unflattenFromString(it) }
            launcherManager.startMainActivity(
                componentName,
                user,
                null,
                null
            )
            result.success(null)
        } catch (e: Exception) {
            result.error(LAUNCH_APPLICATION, e.message, null)
        }
    }

    private fun getIconPackDrawables(call: MethodCall, result: MethodChannel.Result) {
        try {
            val packageName = call.argument<String>("package_name")!!
            val iconPacks = iconPackManager.getAvailableIconPacks(false);
            val iconPack = iconPacks[packageName]!!
            result.success(iconPack.packagesDrawables)
        } catch (e: Exception) {
            result.error(GET_ICON_PACK_DRAWABLES, e.message, null)
        }
    }

    private fun getIconFromIconPack(call: MethodCall, result: MethodChannel.Result) {
        try {
            val packageName = call.argument<String>("package_name")!!
            val drawableName = call.argument<String>("drawable_name")!!
            val size = call.argument<Int>("size")
            val iconPacks = iconPackManager.getAvailableIconPacks(false);
            val iconPack = iconPacks[packageName]!!.apply {
                if (!isLoaded) load()
            }
            val icon = iconPack.loadDrawable(drawableName)
            result.success(icon.toByteArray(size, size))
        } catch (e: Exception) {
            result.error(GET_ICON_FROM_ICON_PACK, e.message, null)
        }
    }

    private fun getApplicationIcon(call: MethodCall, result: MethodChannel.Result) = launch {
        try {
            var icon: Drawable? = null
            val componentName = call.argument<String>("component_name")?.let {
                ComponentName.unflattenFromString(it)
            }
            val packageName = componentName?.packageName;
            val size = call.argument<Int>("size")

            if (componentName != null && iconPackPackageName != null) {
                try {
                    val iconPacks = iconPackManager.getAvailableIconPacks(false)
                    val iconPack = iconPacks[iconPackPackageName]
                    icon = iconPack?.getDrawableIconForComponentName(
                        componentName,
                        null,
                    )
                } catch (e: Exception) {
                    Log.e(GET_APPLICATION_ICON, e.message, null)
                }
            }

            if (icon == null && componentName != null && packageName != null) {
                icon = launcherManager.getActivityList(packageName, user)?.first {
                    it.componentName == componentName
                }?.getIcon(0)

            }

            if (icon == null) {
                icon = activity.getDrawable(android.R.drawable.sym_def_app_icon)!!
            }

            result.success(icon.toByteArray(size, size))
        } catch (e: Exception) {
            result.error(GET_APPLICATION_ICON, e.message, null)
        }
    }

    private fun getPackageIcon(call: MethodCall, result: MethodChannel.Result) {
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

            if (packageName != null && icon == null) {
                icon = packageManager.getApplicationIcon(packageName)
            }

            if (icon == null) {
                icon = activity.getDrawable(android.R.drawable.sym_def_app_icon)!!
            }

            result.success(icon.toByteArray(size, size))
        } catch (e: Exception) {
            result.error(GET_APPLICATION_ICON, e.message, null)
        }
    }

    private fun openApplicationDetails(call: MethodCall, result: MethodChannel.Result) {
        try {
            val componentName = call.argument<String>("component_name")!!
                .let { ComponentName.unflattenFromString(it) }
            launcherManager.startAppDetailsActivity(
                componentName,
                user,
                null, null
            )
            result.success(null)
        } catch (e: Exception) {
            result.error(OPEN_APPLICATION_DETAILS, e.message, null)
        }
    }

    private fun uninstallPackage(call: MethodCall, result: MethodChannel.Result) {
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
            result.error(UNINSTALL_PACKAGE, e.message, null)
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