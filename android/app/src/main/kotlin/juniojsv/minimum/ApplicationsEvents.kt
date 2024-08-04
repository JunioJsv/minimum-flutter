package juniojsv.minimum

import android.content.pm.LauncherApps
import android.os.UserHandle
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import juniojsv.minimum.models.ApplicationEvent
import juniojsv.minimum.models.ApplicationEventType

class ApplicationsEvents(binding: FlutterPlugin.FlutterPluginBinding) :
    LauncherApps.Callback(), EventChannel.StreamHandler {
    companion object {
        const val CHANNEL_NAME = "juniojsv.minimum/applications_events"
    }

    private var channel: EventChannel = EventChannel(
        binding.binaryMessenger,
        CHANNEL_NAME
    )
    private var events: EventChannel.EventSink? = null

    init {
        channel.setStreamHandler(this)
    }

    override fun onPackageRemoved(packageName: String, user: UserHandle) {
        if (packageName == BuildConfig.APPLICATION_ID) return
        events?.success(
            ApplicationEvent(
                ApplicationEventType.ON_PACKAGE_REMOVED,
                listOf(packageName)
            ).serialize()
        )
    }

    override fun onPackageAdded(packageName: String, user: UserHandle) {
        if (packageName == BuildConfig.APPLICATION_ID) return
        events?.success(
            ApplicationEvent(
                ApplicationEventType.ON_PACKAGE_ADDED,
                listOf(packageName)
            ).serialize()
        )
    }

    override fun onPackageChanged(packageName: String, user: UserHandle) {
        if (packageName == BuildConfig.APPLICATION_ID) return
        events?.success(
            ApplicationEvent(
                ApplicationEventType.ON_PACKAGE_CHANGED,
                listOf(packageName)
            ).serialize()
        )
    }

    override fun onPackagesAvailable(
        packageNames: Array<out String>,
        user: UserHandle,
        replacing: Boolean
    ) {
        events?.success(
            ApplicationEvent(
                ApplicationEventType.ON_PACKAGES_AVAILABLE,
                packageNames.filter { it != BuildConfig.APPLICATION_ID }
            ).serialize()
        )
    }

    override fun onPackagesUnavailable(
        packageNames: Array<out String>,
        user: UserHandle,
        replacing: Boolean
    ) {
        events?.success(
            ApplicationEvent(
                ApplicationEventType.ON_PACKAGES_UNAVAILABLE,
                packageNames.filter { it != BuildConfig.APPLICATION_ID }
            ).serialize()
        )
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this.events = events
    }

    override fun onCancel(arguments: Any?) {
        events = null
    }

    fun dispose() {
        events?.endOfStream()
        events = null
    }
}