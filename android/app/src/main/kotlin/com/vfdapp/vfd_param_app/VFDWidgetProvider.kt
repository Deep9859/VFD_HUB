package com.vfdapp.vfd_param_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.app.PendingIntent
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject

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
            val recentJson = prefs.getString("recentConfigs", "[]") ?: "[]"

            val views = RemoteViews(context.packageName, R.layout.vfd_widget_layout)

            try {
                val array = JSONArray(recentJson)
                if (array.length() > 0) {
                    val first = array.getJSONObject(0)
                    val vendor = first.optString("vendorName", "")
                    val model = first.optString("modelName", "")
                    val power = first.optString("powerRating", "")

                    views.setTextViewText(R.id.widget_vendor, vendor)
                    views.setTextViewText(
                        R.id.widget_model,
                        if (power.isNotEmpty()) "$model • ${power}kW" else model
                    )
                    views.setTextViewText(
                        R.id.widget_power,
                        if (array.length() > 1) "+${array.length() - 1} more" else ""
                    )

                    if (array.length() > 1) {
                        val second = array.getJSONObject(1)
                        views.setTextViewText(
                            R.id.widget_recent2,
                            formatLine(second)
                        )
                    } else {
                        views.setTextViewText(R.id.widget_recent2, "")
                    }

                    if (array.length() > 2) {
                        val third = array.getJSONObject(2)
                        views.setTextViewText(
                            R.id.widget_recent3,
                            formatLine(third)
                        )
                    } else {
                        views.setTextViewText(R.id.widget_recent3, "")
                    }
                } else {
                    val vendor = prefs.getString("vendorName", "") ?: ""
                    val model = prefs.getString("modelName", "") ?: ""
                    val power = prefs.getString("powerRating", "") ?: ""

                    if (vendor.isNotEmpty() && model.isNotEmpty()) {
                        views.setTextViewText(R.id.widget_vendor, vendor)
                        views.setTextViewText(R.id.widget_model, model)
                        views.setTextViewText(
                            R.id.widget_power,
                            if (power.isNotEmpty()) "$power kW" else ""
                        )
                    } else {
                        views.setTextViewText(R.id.widget_vendor, "Recent VFDs")
                        views.setTextViewText(R.id.widget_model, "Open app to configure")
                        views.setTextViewText(R.id.widget_power, "")
                    }
                    views.setTextViewText(R.id.widget_recent2, "")
                    views.setTextViewText(R.id.widget_recent3, "")
                }
            } catch (_: Exception) {
                views.setTextViewText(R.id.widget_vendor, "VFD Hub")
                views.setTextViewText(R.id.widget_model, "Open app to configure")
            }

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

        private fun formatLine(obj: JSONObject): String {
            val vendor = obj.optString("vendorName", "")
            val model = obj.optString("modelName", "")
            val power = obj.optString("powerRating", "")
            return if (power.isNotEmpty()) "$vendor $model • ${power}kW" else "$vendor $model"
        }
    }
}
