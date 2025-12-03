package com.example.bombastic_banking

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.Ndef
import android.util.Log
import android.os.Bundle
import android.nfc.NdefRecord
import java.util.Arrays

class MainActivity : FlutterActivity(), NfcAdapter.ReaderCallback {

    // Define the channel name, matching what is used in Flutter's AuthService
    private val CHANNEL = "com.ocbc.nfc_service/methods"

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
        
        // This handler listens for commands from Flutter (e.g., startContinuousNfcScan)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startContinuousNfcScan" -> {
                    // Check if the NFC adapter is available before attempting to start the scan
                    if (nfcAdapter == null) {
                        result.error("NFC_UNAVAILABLE", "NFC adapter is not available on this device.", null)
                    } else {
                        startNfcReaderMode()
                        result.success(true)
                    }
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
            this, // The callback is implemented by this activity (onTagDiscovered)
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
        
        var atmId: String? = null
        
        // 1. Attempt to read the NDEF data from the tag
        val ndef = Ndef.get(tag)
        if (ndef != null) {
            try {
                ndef.connect()
                val ndefMessage = ndef.ndefMessage
                
                // Process the first NDEF record
                ndefMessage?.records?.firstOrNull()?.let { record ->
                    val payload = record.payload
                    
                    atmId = if (payload != null && payload.isNotEmpty()) {
                        // Check if it's an NDEF Text Record (RTD_TEXT)
                        if (Arrays.equals(record.type, NdefRecord.RTD_TEXT)) {
                            // For RTD_TEXT, the first byte is the status byte (language code length),
                            // which must be stripped.
                            String(payload, 1, payload.size - 1, Charsets.UTF_8).trim()
                        } else {
                            // For other record types (e.g., custom MIME or URI), assume the entire 
                            // payload should be read as a UTF-8 string.
                            String(payload, Charsets.UTF_8).trim()
                        }
                    } else {
                        null
                    }
                }
            } catch (e: Exception) {
                Log.e("NFC", "Error reading NDEF tag: ${e.message}")
            } finally {
                try {
                    ndef.close()
                } catch (e: Exception) {
                    Log.e("NFC", "Error closing NDEF connection: ${e.message}")
                }
            }
        }

        // 2. Fallback: If no NDEF data or NDEF connection failed, use the unique tag ID (UID)
        if (atmId.isNullOrEmpty()) {
            atmId = tag?.id?.toHexString()
        }

        // 3. Send the read ID back to Flutter
        if (!atmId.isNullOrEmpty()) {
            Log.d("NFC", "ATM ID Read: $atmId")
            // Crucial: Use runOnUiThread since onTagDiscovered is NOT on the main thread, 
            // ensuring the MethodChannel invocation is thread-safe for Flutter.
            runOnUiThread {
                // Invoking Flutter method 'TagRead'
                channel.invokeMethod("TagRead", atmId)
            }
        } else {
            Log.e("NFC", "Could not read ATM ID from tag via NDEF or UID.")
        }
    }
}

/**
 * Helper extension function to convert byte array to Hex String for Tag ID
 */
fun ByteArray.toHexString(): String = joinToString("") { "%02x".format(it) }