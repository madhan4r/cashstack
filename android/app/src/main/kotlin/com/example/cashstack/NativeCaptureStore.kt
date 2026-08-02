package com.example.cashstack

import android.content.Context
import org.json.JSONArray

/**
 * Handoff queue between [NativeNotificationCaptureReceiver] (which can run without a live
 * Flutter engine — see that class's doc) and the Dart side.
 *
 * Deliberately its own SharedPreferences file rather than the one the `shared_preferences`
 * plugin uses — matching that plugin's on-disk format is an internal implementation detail
 * that could change between versions, whereas this file's format only has to agree with
 * itself.
 */
object NativeCaptureStore {
    private const val PREFS_NAME = "cashstack_native_capture"
    private const val KEY_QUEUE = "pending_captures"
    private const val MAX_QUEUED = 50

    fun add(context: Context, captureJson: String) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val existing = JSONArray(prefs.getString(KEY_QUEUE, "[]"))
        val updated = JSONArray()
        val start = if (existing.length() >= MAX_QUEUED) existing.length() - MAX_QUEUED + 1 else 0
        for (i in start until existing.length()) {
            updated.put(existing.getString(i))
        }
        updated.put(captureJson)
        prefs.edit().putString(KEY_QUEUE, updated.toString()).apply()
    }

    /** Returns and clears everything queued so far. */
    fun drain(context: Context): List<String> {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val existing = JSONArray(prefs.getString(KEY_QUEUE, "[]"))
        prefs.edit().remove(KEY_QUEUE).apply()
        return (0 until existing.length()).map { existing.getString(it) }
    }
}
