package com.example.go_to_venezia

import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import okhttp3.Cache
import okhttp3.CacheControl
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.concurrent.TimeUnit
import kotlin.system.measureTimeMillis
import kotlin.time.TimeSource

class MainActivity: FlutterActivity() {
  private val CHANNEL = "sample.flutter.dev/tide"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // This method is invoked on the main thread.
            call, result ->
            if (call.method == "getTideLevel") {
                val date = LocalDate.now().plusDays(1)
                var tideLevel : Int =-1
                runBlocking(Dispatchers.IO) {
                    launch {
                        tideLevel = getTidesForecast(date)
                    }
                }
                /*okHttpClient.dispatcher.executorService.shutdown()
                okHttpClient.connectionPool.evictAll()
                okHttpClient.cache?.close()*/
        
                if (tideLevel != -1) {
                    result.success(tideLevel)
                } else {
                    result.error("UNAVAILABLE", "tide level not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    val okHttpClient: OkHttpClient = OkHttpClient.Builder()
        .cache(Cache(directory = File("./http_cache"), maxSize = 50L * 1024L * 1024L /*5 MiB*/))
        .build()

    fun doHttpRequest(url: String): String {
        val request = Request.Builder()
            .url(url)
            .cacheControl(CacheControl.Builder().maxStale(10, TimeUnit.DAYS).build())
            .build()
        val response = okHttpClient.newCall(request).execute()
        val ret = response.body?.string() ?: ""
        //println("***************")
        //println(response.cacheResponse)
        //println("***************")
        return ret
    }

    fun doHttpRequest(request: Request): String {
        println("Errore0")

        val response = okHttpClient.newCall(request).execute()
        //return response.body?.string() ?: ""
        println("Errore1")

        val ret = response.body?.string() ?: ""
        println("Errore2")

        //println("***************")
        //println(response.cacheResponse)
        //println("***************")
        return ret
    }

    data class TidePeak(val timestamp: LocalDateTime, val value: Int)

    fun getTidesForecast(day: LocalDate): Int {


        // Parsing HTTP Response to JSON
        val data = JSONArray(
            doHttpRequest(
                Request.Builder()
                    .url("https://dati.venezia.it/sites/default/files/dataset/opendata/previsione.json")
                    .cacheControl(CacheControl.Builder().maxStale(6, TimeUnit.HOURS).build())
                    .build()
            )
        )

        val peakList = mutableListOf<TidePeak>()
        // Going through forecasts, trying to find a match for the given date
        
        for (i in 0 until data.length()) {
            //obj as JSONObject
            val obj: JSONObject = data.getJSONObject(i)
            // Parsing timestamp
            val pDate = LocalDateTime.parse(
                obj.getString("DATA_ESTREMALE"),
                DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")
            )

            // If for the given date AND it's a MAX peak
            if (pDate.toLocalDate().isEqual(day) && obj.getString("TIPO_ESTREMALE").equals("max")) {
                // Add to result list
                return obj.getString("VALORE").toInt();
            }
        }

        // Return forecasts, if any, usually 0 or 2 (two MAX peak every day)
        return 1200;
    }




    /*
    fun main() {
        val date = LocalDate.now().plusDays(0)
        runBlocking(Dispatchers.IO) {
            launch { println("DONE in " + measureTimeMillis { println(getTidesForecast(date)) } + "ms") }
            launch { println("DONE in " + measureTimeMillis { println(getWeatherForecast(date)) } + "ms") }
            launch {
                println("DONE in " + measureTimeMillis { println(checkStrikes(LocalDate.parse("2023-12-15"))) } + "ms")
            }
        }
        okHttpClient.dispatcher.executorService.shutdown()
        okHttpClient.connectionPool.evictAll()
        okHttpClient.cache?.close()
    }
    */

}
