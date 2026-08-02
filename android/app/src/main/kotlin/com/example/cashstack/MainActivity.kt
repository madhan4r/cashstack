package com.example.cashstack

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// local_auth requires a FragmentActivity (not the plain FlutterActivity) to
// host its biometric prompt.
class MainActivity : FlutterFragmentActivity() {
    private val nativeCaptureChannel = "cashstack/native_capture"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, nativeCaptureChannel)
            .setMethodCallHandler { call, result ->
                if (call.method == "drainPendingCaptures") {
                    result.success(NativeCaptureStore.drain(applicationContext))
                } else {
                    result.notImplemented()
                }
            }
    }
}
