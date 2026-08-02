package com.example.cashstack

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import org.json.JSONObject
import java.util.UUID

/**
 * Manifest-registered twin of what `notification_listener_service`'s own event forwarding does.
 *
 * That plugin's `NotificationListener` service (declared in AndroidManifest.xml, permission
 * already granted by the user via Settings > Smart Transaction Detection) broadcasts every
 * notification as an explicit-package `Intent` — see its `NotificationConstants.INTENT` /
 * `handleNotification`. The plugin only *receives* that broadcast with a receiver it registers
 * dynamically in `onListen`, which exists solely while a Dart isolate is actively subscribed to
 * its EventChannel — i.e. only while the app process is alive. If Android kills the process in
 * the background, that dynamic receiver is gone and the broadcast is dropped on the floor.
 *
 * A manifest-declared receiver for the same (explicit, same-package) broadcast doesn't have that
 * problem: Android will spin the app process back up to deliver it even if nothing else is
 * running. So this class parses+queues candidates completely independently of Flutter, and the
 * Dart side just drains the queue (`NativeCaptureChannel.drainPendingCaptures`) next time it's
 * actually running — see `notificationDetectionListenerProvider`.
 *
 * No new permission grant is required: this reuses the exact same already-granted
 * BIND_NOTIFICATION_LISTENER_SERVICE listener, just a second listener for its broadcast.
 */
class NativeNotificationCaptureReceiver : BroadcastReceiver() {
    companion object {
        // Mirrors notification.listener.service.NotificationConstants — not imported directly
        // since these are just the broadcast's public wire contract, not an internal API.
        private const val ACTION = "slayer.notification.listener.service.intent"
        private const val EXTRA_PACKAGE_NAME = "package_name"
        private const val EXTRA_TITLE = "title"
        private const val EXTRA_CONTENT = "message"
        private const val EXTRA_IS_REMOVED = "is_removed"
        private const val EXTRA_NOTIFICATION_TIME = "notification_time"

        private const val OWN_PACKAGE_NAME = "com.example.cashstack"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION) return
        if (intent.getBooleanExtra(EXTRA_IS_REMOVED, false)) return

        val packageName = intent.getStringExtra(EXTRA_PACKAGE_NAME) ?: return
        if (packageName == OWN_PACKAGE_NAME) return

        val title = intent.getStringExtra(EXTRA_TITLE) ?: ""
        val content = intent.getStringExtra(EXTRA_CONTENT) ?: ""
        val text = "$title $content".trim()
        if (text.isEmpty()) return

        val candidate = BankNotificationParser.parse(text) ?: return
        val detectedAtMillis = intent.getLongExtra(EXTRA_NOTIFICATION_TIME, System.currentTimeMillis())

        val json = JSONObject().apply {
            put("id", "native-${UUID.randomUUID()}")
            put("amount", candidate.amount)
            put("type", if (candidate.isExpense) "EXPENSE" else "INCOME")
            put("sourceApp", packageName)
            put("rawText", text)
            put("detectedAt", java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", java.util.Locale.US)
                .apply { timeZone = java.util.TimeZone.getTimeZone("UTC") }
                .format(java.util.Date(detectedAtMillis)) + "Z")
        }

        NativeCaptureStore.add(context, json.toString())
    }
}
