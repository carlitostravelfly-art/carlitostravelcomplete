package com.carlitostravel.mi_app

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "carlitostravel/deeplink"
    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )

        // Cuando Flutter pide el link inicial
        channel!!.setMethodCallHandler { call, result ->
            if (call.method == "getInitialLink") {
                result.success(intent?.data?.toString())
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)

        val uri = intent.data
        if (uri != null) {
            channel?.invokeMethod("onDeepLink", uri.toString())
        }
    }
}
