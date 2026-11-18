package lk.transfer.multiservice

import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "lk.transfer.multiservice/device_id")
            .setMethodCallHandler { call, result ->
                if (call.method == "getAndroidId") {
                    val androidId = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
                    if (androidId.isNullOrBlank()) {
                        result.error("DEVICE_ID_UNAVAILABLE", "Android device ID is unavailable", null)
                    } else {
                        result.success(androidId)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
