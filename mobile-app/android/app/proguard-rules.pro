# ------------------------------------------------------------
# Fix for missing Tink dependency annotations used by
# flutter_secure_storage (AES-GCM uses Tink).
# ------------------------------------------------------------

# --- ERRORPRONE ANNOTATIONS ---------------------------------
# Fix for: com.google.errorprone.annotations.*
-keep class com.google.errorprone.annotations.** { *; }
-keep interface com.google.errorprone.annotations.** { *; }

# --- JAVAX ANNOTATIONS --------------------------------------
# Fix for: javax.annotation.*
-keep class javax.annotation.** { *; }
-keep interface javax.annotation.** { *; }

# --- JAVAX.CONCURRENT ANNOTATIONS ---------------------------
# Fix for: javax.annotation.concurrent.*
-keep class javax.annotation.concurrent.** { *; }
-keep interface javax.annotation.concurrent.** { *; }
