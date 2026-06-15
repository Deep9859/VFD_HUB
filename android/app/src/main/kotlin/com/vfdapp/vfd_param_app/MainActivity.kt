package com.vfdapp.vfd_param_app

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.SharedPreferences
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.vfdapp.vfd_param_app/widget"
    private val PREFS_NAME = "VFDWidgetPrefs"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidget" -> {
                    val prefs: SharedPreferences = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                    val editor = prefs.edit()
                    editor.putString("vendorName", call.argument("vendorName") ?: "")
                    editor.putString("modelName", call.argument("modelName") ?: "")
                    editor.putString("powerRating", call.argument("powerRating") ?: "")
                    editor.putString("configName", call.argument("configName") ?: "")

                    val recent = call.argument<List<Map<String, Any?>>>("recentConfigs")
                    if (recent != null) {
                        val array = JSONArray()
                        for (item in recent) {
                            val obj = JSONObject()
                            obj.put("vendorName", item["vendorName"] ?: "")
                            obj.put("modelName", item["modelName"] ?: "")
                            obj.put("powerRating", item["powerRating"] ?: "")
                            obj.put("lastAccessed", item["lastAccessed"] ?: "")
                            obj.put("configName", item["configName"] ?: "")
                            array.put(obj)
                        }
                        editor.putString("recentConfigs", array.toString())
                    }
                    editor.apply()

                    val manager = AppWidgetManager.getInstance(this)
                    val ids = manager.getAppWidgetIds(ComponentName(this, VFDWidgetProvider::class.java))
                    for (id in ids) VFDWidgetProvider.updateWidget(this, manager, id)
                    result.success(null)
                }
                "clearWidget" -> {
                    val prefs: SharedPreferences = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                    prefs.edit().clear().apply()
                    val manager = AppWidgetManager.getInstance(this)
                    val ids = manager.getAppWidgetIds(ComponentName(this, VFDWidgetProvider::class.java))
                    for (id in ids) VFDWidgetProvider.updateWidget(this, manager, id)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
