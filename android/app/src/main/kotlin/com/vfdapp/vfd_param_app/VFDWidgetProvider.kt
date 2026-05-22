package com.vfdapp.vfd_param_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class VFDWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (widgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, widgetId)
        }
    }

    companion object {
        fun updateWidget(context: Context, appWidgetManager: AppWidgetManager, widgetId: Int) {
            val prefs = context.getSharedPreferences("VFDWidgetPrefs", Context.MODE_PRIVATE)
            val vendor = prefs.getString("vendorName", "") ?: ""
            val model = prefs.getString("modelName", "") ?: ""
            val power = prefs.getString("powerRating", "") ?: ""

            val views = RemoteViews(context.packageName, R.layout.vfd_widget_layout)

            if (vendor.isNotEmpty() && model.isNotEmpty()) {
                views.setTextViewText(R.id.widget_vendor, vendor)
                views.setTextViewText(R.id.widget_model, model)
                views.setTextViewText(R.id.widget_power, if (power.isNotEmpty()) "$power kW" else "")
            } else {
                views.setTextViewText(R.id.widget_vendor, "No VFD selected")
                views.setTextViewText(R.id.widget_model, "Open app to configure")
                views.setTextViewText(R.id.widget_power, "")
            }

            // Tap to open app
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_model, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
