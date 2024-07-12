package juniojsv.minimum

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel

class ApplicationsEventsBroadcastReceiver : BroadcastReceiver(), FlutterPlugin,
    EventChannel.StreamHandler {
    private lateinit var pm: PackageManager
    private lateinit var channel: EventChannel
    private var events: EventChannel.EventSink? = null

    companion object {
        const val CHANNEL_NAME = "juniojsv.minimum/applications_events"
    }


    private fun getIntentJson(intent: Intent): Map<String, Any?> {
        val packageName = intent.data!!.schemeSpecificPart
        val canLaunch = pm.getLaunchIntentForPackage(packageName) != null
        val isReplacingPackage = intent
            .getBooleanExtra(Intent.EXTRA_REPLACING, false)
        return mapOf(
            "action" to intent.action,
            "package" to packageName,
            "can_launch" to canLaunch,
            "is_replacing" to isReplacingPackage,
        )
    }

    override fun onReceive(context: Context, intent: Intent) {
        events?.success(getIntentJson(intent))
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this.events = events
    }

    override fun onCancel(arguments: Any?) {
        events = null
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        pm = binding.applicationContext.packageManager
        channel = EventChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setStreamHandler(this)
        binding.applicationContext.registerReceiver(this, IntentFilter().apply {
            addDataScheme("package")
            addAction(Intent.ACTION_PACKAGE_ADDED)
            addAction(Intent.ACTION_PACKAGE_REMOVED)
            addAction(Intent.ACTION_PACKAGE_CHANGED)
        })
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        binding.applicationContext.unregisterReceiver(this)
        events?.endOfStream()
    }
}