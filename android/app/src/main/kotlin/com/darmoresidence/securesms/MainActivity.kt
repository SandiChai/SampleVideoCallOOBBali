package com.dip.darmoresidence

import android.annotation.SuppressLint
import android.app.Activity
import android.app.KeyguardManager
import android.app.PictureInPictureParams
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.CountDownTimer
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import android.util.Rational
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {
    private val pipChannel = "PIP_CHANNEL"
    private var pipAllowed: Boolean = false
    private var pipWidth: Int = 3
    private var pipHeight: Int = 4


    private val CHANNEL = "flutter.native/powerOff"
    val RESULT_ENABLE = 1
    var deviceManger: DevicePolicyManager? = null
    var compName: ComponentName? = null
    private var wake: PowerManager.WakeLock? = null

    @SuppressLint("ServiceCast", "InvalidWakeLockTag")
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        compName = ComponentName(this, DeviceAdmin::class.java)
        deviceManger = getSystemService(DEVICE_POLICY_SERVICE) as DevicePolicyManager
        super.configureFlutterEngine(flutterEngine)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            activity.setShowWhenLocked(true)
            activity.setTurnScreenOn(true)
        }
//                        val lock =
//                            (activity.getSystemService(Activity.KEYGUARD_SERVICE) as KeyguardManager).newKeyguardLock(Context.KEYGUARD_SERVICE)
        val powerManager = activity.getSystemService(Context.POWER_SERVICE) as PowerManager
        val wake = powerManager.newWakeLock(
            PowerManager.FULL_WAKE_LOCK or
                    PowerManager.ACQUIRE_CAUSES_WAKEUP or
                    PowerManager.ON_AFTER_RELEASE,
            "SomeAppName:BusSnoozeAlarm"
        )
//
//                        lock.disableKeyguard()
        // This timeout doesn't seem to do anything
        wake.acquire(6 * 1000L)

        activity.window.addFlags(
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                    or WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                    or WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                    or WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        )
        val keyguardManager = getSystemService(KEYGUARD_SERVICE) as KeyguardManager
        val lock: KeyguardManager.KeyguardLock = keyguardManager.newKeyguardLock(KEYGUARD_SERVICE)
        lock.disableKeyguard()

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "powerOff") {
                Log.e("TAG", "Masuk MainAcitivity.kt")
                object : CountDownTimer(5000, 1000) {
                    override fun onTick(millisUntilFinished: Long) {
                        Log.e("TAG", "seconds remaining: " + millisUntilFinished / 1000)
                    }

                    override fun onFinish() {
//                        val powerManager = context.getSystemService(POWER_SERVICE) as PowerManager
//
//                        if (!powerManager.isInteractive) { // if screen is not already on, turn it on (get wake_lock for 10 seconds)
//                            val wl = powerManager.newWakeLock(
//                                PowerManager.FULL_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP or PowerManager.ON_AFTER_RELEASE,
//                                "MH24_SCREENLOCK"
//                            )
//                            wl.acquire(10000)
//                            val wl_cpu = powerManager.newWakeLock(
//                                PowerManager.PARTIAL_WAKE_LOCK,
//                                "MH24_SCREENLOCK"
//                            )
//
//                            wl_cpu.acquire(10000)
//                        }
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                            activity.setShowWhenLocked(true)
                            activity.setTurnScreenOn(true)
                        }
//                        val lock =
//                            (activity.getSystemService(Activity.KEYGUARD_SERVICE) as KeyguardManager).newKeyguardLock(Context.KEYGUARD_SERVICE)
                        val powerManager = activity.getSystemService(Context.POWER_SERVICE) as PowerManager
                        val wake = powerManager.newWakeLock(
                            PowerManager.FULL_WAKE_LOCK or
                                    PowerManager.ACQUIRE_CAUSES_WAKEUP or
                                    PowerManager.ON_AFTER_RELEASE,
                            "SomeAppName:BusSnoozeAlarm"
                        )
//
//                        lock.disableKeyguard()
                        // This timeout doesn't seem to do anything
                        wake.acquire(6 * 1000L)

                        activity.window.addFlags(
                            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                                    or WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                                    or WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                                    or WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
                                    or WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON
                        )
                        val keyguardManager = getSystemService(KEYGUARD_SERVICE) as KeyguardManager
                        val lock: KeyguardManager.KeyguardLock = keyguardManager.newKeyguardLock(KEYGUARD_SERVICE)
                        lock.disableKeyguard()

                        android.provider.Settings.Secure.getInt(
                            context.contentResolver,
                            "lock_screen_show_notifications", 1
                        )

                        val intent: Intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse(
                                "package:$packageName"
                            )
                        )
                        startActivityForResult(intent, 0)
                    }
                }.start()


            }
        }
    }

    @Suppress("DEPRECATION")
    private fun disableLockScreen(activity: Activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            activity.setShowWhenLocked(true)
            activity.setTurnScreenOn(true)
        }
        val lock =
            (activity.getSystemService(Activity.KEYGUARD_SERVICE) as KeyguardManager).newKeyguardLock(Context.KEYGUARD_SERVICE)
        val powerManager = activity.getSystemService(Context.POWER_SERVICE) as PowerManager
        val wake = powerManager.newWakeLock(
            PowerManager.FULL_WAKE_LOCK or
                    PowerManager.ACQUIRE_CAUSES_WAKEUP or
                    PowerManager.ON_AFTER_RELEASE,
            "SomeAppName:BusSnoozeAlarm"
        )

//        lock.disableKeyguard()
        // This timeout doesn't seem to do anything
        wake.acquire(6 * 1000L)

        activity.window.addFlags(
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                    or WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                    or WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                    or WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
                    or WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON
        )
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            RESULT_ENABLE -> {
                if (resultCode == RESULT_OK) {
                    deviceManger!!.lockNow()
                }
                return
            }
        }
    }

    private fun allowPip(width: Int?, height: Int?) {
        pipAllowed = true
        if(width != null && height != null) {
            pipWidth = width
            pipHeight = height
        }
    }

    private fun blockPip() {
        pipAllowed = false
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if(pipAllowed && android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            val pipParamsBuilder = PictureInPictureParams.Builder();
            pipParamsBuilder.setAspectRatio(Rational(pipWidth, pipHeight))
            enterPictureInPictureMode(pipParamsBuilder.build())
        }
    }

//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, pipChannel).setMethodCallHandler {
//            call, result ->
//            when (call.method) {
//                "allowPip" -> {
//                    val width = call.argument<Int?>("width")
//                    val height = call.argument<Int?>("height")
//                    allowPip(width, height)
//                    result.success(null)
//                }
//                "blockPip" -> {
//                    blockPip()
//                    result.success(null)
//                }
//                else -> {
//                    result.notImplemented()
//                }
//            }
//        }
//    }


}
