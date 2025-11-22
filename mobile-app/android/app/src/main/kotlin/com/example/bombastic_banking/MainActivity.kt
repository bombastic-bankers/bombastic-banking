package com.example.bombastic_banking

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.Ndef
import android.util.Log
import android.os.Bundle

class MainActivity : FlutterActivity(), NfcAdapter.ReaderCallback {

    // Define the channel name, matching what is used in Flutter's AuthService
    private val CHANNEL = "com.bombasticbanking/nfc"

    // Platform channel instance
    private lateinit var channel: MethodChannel
    
    // NFC adapter instance
    private var nfcAdapter: NfcAdapter? = null

    // Constants for reader mode
    private val READER_FLAGS = NfcAdapter.FLAG_READER_NFC_A or 
                               NfcAdapter.FLAG_READER_NFC_B or
                               NfcAdapter.FLAG_READER_NFC_F or
                               NfcAdapter.FLAG_READER_NFC_V or
                               NfcAdapter.FLAG_READER_NFC_BARCODE or
                               NfcAdapter.FLAG_READER_NO_PLATFORM_SOUNDS

    // --- Activity Lifecycle Overrides for NFC Management ---

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Get the NFC adapter instance
        nfcAdapter = NfcAdapter.getDefaultAdapter(this)
    }

    override fun onResume() {
        super.onResume()
        // Ensure continuous reader mode is active if the channel logic wants it on
        // We defer activation to the MethodChannel call, but keep this here for robustness
        // if the app returns to foreground.
    }

    override fun onPause() {
        super.onPause()
        // Best practice to disable reader mode when the app is paused
        nfcAdapter?.disableReaderMode(this)
    }

    // --- Platform Channel Configuration ---

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startContinuousNfcScan" -> {
                    startNfcReaderMode()
                    result.success(true)
                }
                "stopContinuousNfcScan" -> {
                    stopNfcReaderMode()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    // --- NFC Reader Mode Implementation ---

    private fun startNfcReaderMode() {
        // Activate reader mode, enabling tag discovery
        nfcAdapter?.enableReaderMode(
            this,
            this, // The callback is implemented by this activity
            READER_FLAGS,
            null // Bundle of optional parameters
        )
        Log.d("NFC", "NFC Reader Mode Enabled.")
    }

    private fun stopNfcReaderMode() {
        // Deactivate reader mode
        nfcAdapter?.disableReaderMode(this)
        Log.d("NFC", "NFC Reader Mode Disabled.")
    }

    /**
     * Called when a tag is detected. This is the core NFC reading logic.
     */
    override fun onTagDiscovered(tag: Tag?) {
        Log.d("NFC", "Tag discovered.")
        
        // 1. Attempt to read the NDEF data from the tag
        val ndef = Ndef.get(tag)
        val atmId: String? = if (ndef != null) {
            ndef.connect()
            val ndefMessage = ndef.ndefMessage
            ndef.close()

            // Assume the ATM ID is stored in the first NDEF record's payload
            ndefMessage?.records?.firstOrNull()?.payload?.let { payload ->
                // Assuming text/string data, strip language code if present (e.g., first byte)
                String(payload, 1, payload.size - 1, Charsets.UTF_8).trim()
            }
        } else {
            // Fallback: If not an NDEF tag, use the unique tag ID (UID) as the ATM ID
            tag?.id?.toHexString()
        }

        // 2. Send the read ID back to Flutter
        if (atmId != null) {
            Log.d("NFC", "ATM ID Read: $atmId")
            // Use post to ensure the result is sent on the main thread (although not always necessary for streams)
            channel.invokeMethod("onNfcTagRead", atmId)
        } else {
            Log.e("NFC", "Could not read ATM ID from tag.")
        }
    }
}

/**
 * Helper extension function to convert byte array to Hex String for Tag ID
 */
fun ByteArray.toHexString(): String = joinToString("") { "%02x".format(it) }