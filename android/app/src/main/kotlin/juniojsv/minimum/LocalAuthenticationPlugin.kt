package juniojsv.minimum

import android.app.Activity
import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry


class LocalAuthenticationPlugin : FlutterPlugin, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var activity: Activity
    private lateinit var kgm: KeyguardManager

    companion object {
        const val CHANNEL_NAME = "juniojsv.minimum/local_authentication_plugin"
        const val AUTHENTICATE = "authenticate"
        const val IS_DEVICE_SECURE = "is_device_secure"
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel =
            MethodChannel(binding.binaryMessenger, CHANNEL_NAME).apply {
                setMethodCallHandler(::onMethodCall)
            }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        kgm = activity.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
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
            AUTHENTICATE -> onAuthenticate(call, result)
            IS_DEVICE_SECURE -> {
                try {
                    result.success(isDeviceSecure())
                } catch (e: Exception) {
                    result.error(IS_DEVICE_SECURE, e.message, null)
                }
            }
        }
    }

    private fun isDeviceSecure(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return kgm.isDeviceSecure
        }

        return true
    }

    private fun onAuthenticate(call: MethodCall, result: MethodChannel.Result) {
        val title = call.argument<String>("title")
        val subtitle = call.argument<String>("subtitle")
        val executor = ContextCompat.getMainExecutor(activity)
        val prompt = BiometricPrompt(activity as FlutterFragmentActivity, executor,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationError(
                    errorCode: Int,
                    errString: CharSequence
                ) {
                    super.onAuthenticationError(errorCode, errString)
                    result.error(AUTHENTICATE, errString.toString(), null)
                }

                override fun onAuthenticationSucceeded(
                    authentication: BiometricPrompt.AuthenticationResult
                ) {
                    super.onAuthenticationSucceeded(authentication)
                    result.success(null)
                }

            })

        val info = BiometricPrompt.PromptInfo.Builder()
            .setTitle(title!!)
            .setAllowedAuthenticators(
                BiometricManager.Authenticators.BIOMETRIC_WEAK or
                        BiometricManager.Authenticators.DEVICE_CREDENTIAL
            )

        if (subtitle != null) {
            info.setSubtitle(subtitle)
        }

        prompt.authenticate(info.build())
    }
}