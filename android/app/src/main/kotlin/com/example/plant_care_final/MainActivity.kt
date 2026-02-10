// android/app/src/main/kotlin/com/example/plant_care_final/MainActivity.kt
package com.example.plant_care_final

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

class MainActivity : FlutterActivity() {
    private val CHANNEL = "plant_care/notifications"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAvailable" -> {
                    result.success(true)
                }
                
                "hasNotificationPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                        result.success(notificationManager.areNotificationsEnabled())
                    } else {
                        result.success(true)
                    }
                }
                
                "scheduleNotification" -> {
                    try {
                        val id = call.argument<Int>("id") ?: 0
                        val title = call.argument<String>("title") ?: "Напоминание"
                        val body = call.argument<String>("body") ?: "Пора полить растение"
                        val timeInMillis = call.argument<Long>("timeInMillis") ?: System.currentTimeMillis() + 5000
                        
                        scheduleNotification(id, title, body, timeInMillis)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SCHEDULE_ERROR", e.message, null)
                    }
                }
                
                "cancelNotification" -> {
                    try {
                        val id = call.argument<Int>("id") ?: 0
                        cancelNotification(id)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("CANCEL_ERROR", e.message, null)
                    }
                }
                
                "showNotificationNow" -> {
                    try {
                        val id = call.argument<Int>("id") ?: 0
                        val title = call.argument<String>("title") ?: "Тестовое уведомление"
                        val body = call.argument<String>("body") ?: "Это тестовое уведомление"
                        
                        showNotificationNow(id, title, body)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SHOW_NOW_ERROR", e.message, null)
                    }
                }
                
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun scheduleNotification(id: Int, title: String, body: String, timeInMillis: Long) {
        try {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as android.app.AlarmManager
            val intent = Intent(this, AlarmReceiver::class.java).apply {
                putExtra("id", id)
                putExtra("title", title)
                putExtra("body", body)
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                this, 
                id, 
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or 
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    PendingIntent.FLAG_IMMUTABLE
                } else {
                    0
                }
            )
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    android.app.AlarmManager.RTC_WAKEUP,
                    timeInMillis,
                    pendingIntent
                )
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                alarmManager.setExact(
                    android.app.AlarmManager.RTC_WAKEUP,
                    timeInMillis,
                    pendingIntent
                )
            } else {
                alarmManager.set(
                    android.app.AlarmManager.RTC_WAKEUP,
                    timeInMillis,
                    pendingIntent
                )
            }
            
            android.util.Log.d("MainActivity", "Уведомление $id запланировано")
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Ошибка планирования: ${e.message}")
            throw e
        }
    }
    
    private fun cancelNotification(id: Int) {
        try {
            val intent = Intent(this, AlarmReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                this, 
                id, 
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or 
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    PendingIntent.FLAG_IMMUTABLE
                } else {
                    0
                }
            )
            
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as android.app.AlarmManager
            alarmManager.cancel(pendingIntent)
            pendingIntent.cancel()
            
            android.util.Log.d("MainActivity", "Уведомление $id отменено")
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Ошибка отмены: ${e.message}")
        }
    }
    
    private fun showNotificationNow(id: Int, title: String, body: String) {
        try {
            val intent = Intent(this, AlarmReceiver::class.java).apply {
                putExtra("id", id)
                putExtra("title", title)
                putExtra("body", body)
            }
            sendBroadcast(intent)
            android.util.Log.d("MainActivity", "Немедленное уведомление $id отправлено")
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Ошибка отправки: ${e.message}")
        }
    }
}