package com.habitstimer.habits_timer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED || intent.action == "android.intent.action.QUICKBOOT_POWERON") {
            try {
                // Écrit un flag dans les SharedPreferences utilisées par Flutter (shared_preferences)
                // Fichier: FlutterSharedPreferences, clé: flutter.needs_reschedule = true
                val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                prefs.edit().putBoolean("flutter.needs_reschedule", true).apply()
                Log.d("BootReceiver", "Flag flutter.needs_reschedule posé")
            } catch (e: Exception) {
                Log.e("BootReceiver", "Erreur BootReceiver", e)
            }
        }
    }
}
