package juniojsv.minimum

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(setOf(
            ApplicationsManagerPlugin(),
            LocalAuthenticationPlugin(),
        ))
    }
}
