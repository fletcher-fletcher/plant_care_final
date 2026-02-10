// android/app/src/main/kotlin/com/example/plant_care_final/AlarmReceiver.kt
package com.example.plant_care_final

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        try {
            val title = intent.getStringExtra("title") ?: "Напоминание о растении"
            val body = intent.getStringExtra("body") ?: "Пора полить ваше растение"
            val id = intent.getIntExtra("id", 0)
            
            showNotification(context, id, title, body)
            android.util.Log.d("AlarmReceiver", "Уведомление $id показано")
        } catch (e: Exception) {
            android.util.Log.e("AlarmReceiver", "Ошибка: ${e.message}")
        }
    }
    
    private fun showNotification(context: Context, id: Int, title: String, body: String) {
        try {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            
            // Создаем канал для Android 8+
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    "plant_care_channel",
                    "Напоминания о растениях",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Напоминания о поливе и уходе за растениями"
                    enableLights(true)
                    enableVibration(true)
                    vibrationPattern = longArrayOf(0, 500, 200, 500)
                }
                notificationManager.createNotificationChannel(channel)
            }
            
            // Intent для открытия приложения
            val packageName = context.packageName
            val launchIntent = context.packageManager.getLaunchIntentForPackage(packageName)
            val pendingIntent = PendingIntent.getActivity(
                context, 
                id, 
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or 
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    PendingIntent.FLAG_IMMUTABLE
                } else {
                    0
                }
            )
            
            // Иконка
            val iconId = context.resources.getIdentifier("ic_launcher", "mipmap", packageName)
            val notificationIcon = if (iconId != 0) iconId else android.R.drawable.ic_dialog_info
            
            // Создаем уведомление
            val notificationBuilder = NotificationCompat.Builder(context, "plant_care_channel")
                .setContentTitle(title)
                .setContentText(body)
                .setSmallIcon(notificationIcon)
                .setContentIntent(pendingIntent)
                .setAutoCancel(true)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setDefaults(NotificationCompat.DEFAULT_SOUND or NotificationCompat.DEFAULT_VIBRATE)
                .setVibrate(longArrayOf(0, 500, 200, 500))
            
            // Для Android 7.1+ делаем расширенное уведомление
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                notificationBuilder.setStyle(NotificationCompat.BigTextStyle().bigText(body))
            }
            
            val notification = notificationBuilder.build()
            notificationManager.notify(id, notification)
        } catch (e: Exception) {
            android.util.Log.e("AlarmReceiver", "Ошибка создания уведомления: ${e.message}")
        }
    }
}