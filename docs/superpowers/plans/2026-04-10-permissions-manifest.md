# Task 2: Permissions and Manifest — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Declare all app permissions in the manifest, bump minSdk to 36, and build a centralized PermissionManager that feature screens will use to request permissions contextually with Ez's friendly rationale.

**Architecture:** A `permissions` package containing an enum of all app permissions (with rationale text), a manager class that wraps the Activity Result API, a sealed status type, and Compose UI helpers for rationale/denied dialogs. No permissions are requested at launch — each is triggered by the feature that needs it.

**Tech Stack:** Kotlin, Jetpack Compose, Activity Result API (`registerForActivityResult`), Material3 AlertDialog

---

## File Structure

| Action | Path | Responsibility |
|--------|------|----------------|
| Modify | `app/build.gradle.kts:15` | Bump minSdk from 26 to 36 |
| Modify | `app/src/main/AndroidManifest.xml` | Add all permission declarations and BLE uses-feature |
| Create | `app/src/main/java/org/ezdozit/app/permissions/PermissionStatus.kt` | Sealed class for permission states |
| Create | `app/src/main/java/org/ezdozit/app/permissions/AppPermission.kt` | Enum of all permissions with rationale text |
| Create | `app/src/main/java/org/ezdozit/app/permissions/PermissionManager.kt` | Check/request logic wrapping Activity Result API |
| Create | `app/src/main/java/org/ezdozit/app/permissions/PermissionUI.kt` | Compose rationale dialog, denied dialog, rememberPermissionRequest |
| Create | `app/src/test/java/org/ezdozit/app/permissions/AppPermissionTest.kt` | Unit tests for AppPermission enum |
| Create | `app/src/test/java/org/ezdozit/app/permissions/PermissionStatusTest.kt` | Unit tests for PermissionStatus sealed class |

---

### Task 1: Bump minSdk and update manifest

**Files:**
- Modify: `app/build.gradle.kts:15`
- Modify: `app/src/main/AndroidManifest.xml`

- [ ] **Step 1: Bump minSdk in build.gradle.kts**

In `app/build.gradle.kts`, change line 15 from:
```kotlin
        minSdk = 26
```
to:
```kotlin
        minSdk = 36
```

- [ ] **Step 2: Add permissions and uses-feature to AndroidManifest.xml**

Replace the entire `app/src/main/AndroidManifest.xml` with:
```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <!-- Location -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

    <!-- Bluetooth (API 31+) -->
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN"
        android:usesPermissionFlags="neverForLocation" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

    <!-- Activity Recognition -->
    <uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />

    <!-- Foreground Service -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />

    <!-- Notifications -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <!-- BLE hardware not required — app works without it -->
    <uses-feature
        android:name="android.hardware.bluetooth_le"
        android:required="false" />

    <application
        android:allowBackup="true"
        android:dataExtractionRules="@xml/data_extraction_rules"
        android:fullBackupContent="@xml/backup_rules"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.EzDozit">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:label="@string/app_name"
            android:theme="@style/Theme.EzDozit">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />

                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>

</manifest>
```

- [ ] **Step 3: Verify the build compiles**

Run:
```bash
JAVA_HOME=/snap/android-studio/209/jbr ./gradlew assembleDebug
```
Expected: BUILD SUCCESSFUL

- [ ] **Step 4: Commit**

```bash
git add app/build.gradle.kts app/src/main/AndroidManifest.xml
git commit -m "feat: bump minSdk to 36, add all permission declarations to manifest"
```

---

### Task 2: PermissionStatus sealed class

**Files:**
- Create: `app/src/main/java/org/ezdozit/app/permissions/PermissionStatus.kt`
- Create: `app/src/test/java/org/ezdozit/app/permissions/PermissionStatusTest.kt`

- [ ] **Step 1: Write the failing test**

Create `app/src/test/java/org/ezdozit/app/permissions/PermissionStatusTest.kt`:
```kotlin
package org.ezdozit.app.permissions

import org.junit.Assert.*
import org.junit.Test

class PermissionStatusTest {

    @Test
    fun `Granted is a PermissionStatus`() {
        val status: PermissionStatus = PermissionStatus.Granted
        assertTrue(status is PermissionStatus.Granted)
    }

    @Test
    fun `NotRequested is a PermissionStatus`() {
        val status: PermissionStatus = PermissionStatus.NotRequested
        assertTrue(status is PermissionStatus.NotRequested)
    }

    @Test
    fun `Denied is a PermissionStatus`() {
        val status: PermissionStatus = PermissionStatus.Denied
        assertTrue(status is PermissionStatus.Denied)
    }

    @Test
    fun `PermanentlyDenied is a PermissionStatus`() {
        val status: PermissionStatus = PermissionStatus.PermanentlyDenied
        assertTrue(status is PermissionStatus.PermanentlyDenied)
    }

    @Test
    fun `isGranted returns true only for Granted`() {
        assertTrue(PermissionStatus.Granted.isGranted)
        assertFalse(PermissionStatus.NotRequested.isGranted)
        assertFalse(PermissionStatus.Denied.isGranted)
        assertFalse(PermissionStatus.PermanentlyDenied.isGranted)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:
```bash
JAVA_HOME=/snap/android-studio/209/jbr ./gradlew testDebugUnitTest --tests "org.ezdozit.app.permissions.PermissionStatusTest"
```
Expected: FAIL — `PermissionStatus` class does not exist

- [ ] **Step 3: Write the implementation**

Create `app/src/main/java/org/ezdozit/app/permissions/PermissionStatus.kt`:
```kotlin
package org.ezdozit.app.permissions

sealed class PermissionStatus {
    data object Granted : PermissionStatus()
    data object NotRequested : PermissionStatus()
    data object Denied : PermissionStatus()
    data object PermanentlyDenied : PermissionStatus()

    val isGranted: Boolean get() = this is Granted
}
```

- [ ] **Step 4: Run test to verify it passes**

Run:
```bash
JAVA_HOME=/snap/android-studio/209/jbr ./gradlew testDebugUnitTest --tests "org.ezdozit.app.permissions.PermissionStatusTest"
```
Expected: PASS — all 5 tests green

- [ ] **Step 5: Commit**

```bash
git add app/src/main/java/org/ezdozit/app/permissions/PermissionStatus.kt \
       app/src/test/java/org/ezdozit/app/permissions/PermissionStatusTest.kt
git commit -m "feat: add PermissionStatus sealed class with unit tests"
```

---

### Task 3: AppPermission enum

**Files:**
- Create: `app/src/main/java/org/ezdozit/app/permissions/AppPermission.kt`
- Create: `app/src/test/java/org/ezdozit/app/permissions/AppPermissionTest.kt`

- [ ] **Step 1: Write the failing test**

Create `app/src/test/java/org/ezdozit/app/permissions/AppPermissionTest.kt`:
```kotlin
package org.ezdozit.app.permissions

import android.Manifest
import org.junit.Assert.*
import org.junit.Test

class AppPermissionTest {

    @Test
    fun `FineLocation maps to ACCESS_FINE_LOCATION`() {
        assertEquals(
            listOf(Manifest.permission.ACCESS_FINE_LOCATION),
            AppPermission.FineLocation.permissions
        )
    }

    @Test
    fun `BackgroundLocation maps to ACCESS_BACKGROUND_LOCATION`() {
        assertEquals(
            listOf(Manifest.permission.ACCESS_BACKGROUND_LOCATION),
            AppPermission.BackgroundLocation.permissions
        )
    }

    @Test
    fun `BluetoothScan maps to BLUETOOTH_SCAN`() {
        assertEquals(
            listOf(Manifest.permission.BLUETOOTH_SCAN),
            AppPermission.BluetoothScan.permissions
        )
    }

    @Test
    fun `BluetoothConnect maps to BLUETOOTH_CONNECT`() {
        assertEquals(
            listOf(Manifest.permission.BLUETOOTH_CONNECT),
            AppPermission.BluetoothConnect.permissions
        )
    }

    @Test
    fun `ActivityRecognition maps to ACTIVITY_RECOGNITION`() {
        assertEquals(
            listOf(Manifest.permission.ACTIVITY_RECOGNITION),
            AppPermission.ActivityRecognition.permissions
        )
    }

    @Test
    fun `Notifications maps to POST_NOTIFICATIONS`() {
        assertEquals(
            listOf(Manifest.permission.POST_NOTIFICATIONS),
            AppPermission.Notifications.permissions
        )
    }

    @Test
    fun `every permission has non-empty rationale text`() {
        AppPermission.entries.forEach { permission ->
            assertTrue(
                "${permission.name} has empty rationale",
                permission.rationale.isNotBlank()
            )
        }
    }

    @Test
    fun `every permission has non-empty denied text`() {
        AppPermission.entries.forEach { permission ->
            assertTrue(
                "${permission.name} has empty denied message",
                permission.deniedMessage.isNotBlank()
            )
        }
    }

    @Test
    fun `ActivityRecognition is optional`() {
        assertFalse(AppPermission.ActivityRecognition.required)
    }

    @Test
    fun `FineLocation is required`() {
        assertTrue(AppPermission.FineLocation.required)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:
```bash
JAVA_HOME=/snap/android-studio/209/jbr ./gradlew testDebugUnitTest --tests "org.ezdozit.app.permissions.AppPermissionTest"
```
Expected: FAIL — `AppPermission` class does not exist

- [ ] **Step 3: Write the implementation**

Create `app/src/main/java/org/ezdozit/app/permissions/AppPermission.kt`:
```kotlin
package org.ezdozit.app.permissions

import android.Manifest

enum class AppPermission(
    val permissions: List<String>,
    val rationale: String,
    val deniedMessage: String,
    val required: Boolean = true
) {
    FineLocation(
        permissions = listOf(Manifest.permission.ACCESS_FINE_LOCATION),
        rationale = "Hey, I need to know where we are so I can show you the map. Mind sharing your location?",
        deniedMessage = "No worries! If you change your mind, you can turn on location in Settings anytime."
    ),
    BackgroundLocation(
        permissions = listOf(Manifest.permission.ACCESS_BACKGROUND_LOCATION),
        rationale = "To keep tracking your adventure when the screen is off, I need background location access. You're in control — you can turn this off anytime.",
        deniedMessage = "That's okay! Your adventures will just pause when the screen turns off. You can change this in Settings later."
    ),
    BluetoothScan(
        permissions = listOf(Manifest.permission.BLUETOOTH_SCAN),
        rationale = "I use Bluetooth to notice when people are nearby — it's how encounters work! Can I turn on scanning?",
        deniedMessage = "No problem! Encounters just won't be tracked. You can enable Bluetooth scanning in Settings if you change your mind."
    ),
    BluetoothConnect(
        permissions = listOf(Manifest.permission.BLUETOOTH_CONNECT),
        rationale = "I'd like to check your paired devices so I can ignore things like your earbuds. Cool?",
        deniedMessage = "All good! I might count your own devices as encounters though. You can change this in Settings."
    ),
    ActivityRecognition(
        permissions = listOf(Manifest.permission.ACTIVITY_RECOGNITION),
        rationale = "Want me to count your steps while we explore? I'll need access to your activity data for that.",
        deniedMessage = "No worries! We'll skip the step counting. You can turn it on later in Settings.",
        required = false
    ),
    Notifications(
        permissions = listOf(Manifest.permission.POST_NOTIFICATIONS),
        rationale = "I'd like to let you know when I'm exploring with you. Mind if I send notifications?",
        deniedMessage = "That's fine! I'll still be here exploring with you, just quietly. You can enable notifications in Settings."
    )
}
```

- [ ] **Step 4: Run test to verify it passes**

Run:
```bash
JAVA_HOME=/snap/android-studio/209/jbr ./gradlew testDebugUnitTest --tests "org.ezdozit.app.permissions.AppPermissionTest"
```
Expected: PASS — all 10 tests green

- [ ] **Step 5: Commit**

```bash
git add app/src/main/java/org/ezdozit/app/permissions/AppPermission.kt \
       app/src/test/java/org/ezdozit/app/permissions/AppPermissionTest.kt
git commit -m "feat: add AppPermission enum with rationale text and unit tests"
```

---

### Task 4: PermissionManager

**Files:**
- Create: `app/src/main/java/org/ezdozit/app/permissions/PermissionManager.kt`

- [ ] **Step 1: Write the implementation**

Create `app/src/main/java/org/ezdozit/app/permissions/PermissionManager.kt`:
```kotlin
package org.ezdozit.app.permissions

import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

class PermissionManager(private val context: Context) {

    fun check(permission: AppPermission): PermissionStatus {
        val allGranted = permission.permissions.all { perm ->
            ContextCompat.checkSelfPermission(context, perm) == PackageManager.PERMISSION_GRANTED
        }
        if (allGranted) return PermissionStatus.Granted

        val activity = context as? Activity ?: return PermissionStatus.NotRequested

        val shouldShowRationale = permission.permissions.any { perm ->
            ActivityCompat.shouldShowRequestPermissionRationale(activity, perm)
        }

        return if (shouldShowRationale) {
            PermissionStatus.Denied
        } else {
            // Could be NotRequested or PermanentlyDenied — we check shared prefs
            if (hasBeenRequestedBefore(permission)) {
                PermissionStatus.PermanentlyDenied
            } else {
                PermissionStatus.NotRequested
            }
        }
    }

    fun markAsRequested(permission: AppPermission) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putBoolean(prefKey(permission), true)
            .apply()
    }

    private fun hasBeenRequestedBefore(permission: AppPermission): Boolean {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getBoolean(prefKey(permission), false)
    }

    private fun prefKey(permission: AppPermission): String =
        "permission_requested_${permission.name}"

    companion object {
        private const val PREFS_NAME = "ez_dozit_permissions"
    }
}
```

Note: Unit testing `PermissionManager` requires mocking Android framework classes (`Context`, `PackageManager`, `Activity`). Since we'll be validating this through the emulator and the logic is straightforward, we skip unit tests for this class — the `AppPermission` and `PermissionStatus` tests cover the data model, and the UI integration tests the flow.

- [ ] **Step 2: Verify the build compiles**

Run:
```bash
JAVA_HOME=/snap/android-studio/209/jbr ./gradlew assembleDebug
```
Expected: BUILD SUCCESSFUL

- [ ] **Step 3: Commit**

```bash
git add app/src/main/java/org/ezdozit/app/permissions/PermissionManager.kt
git commit -m "feat: add PermissionManager for checking and tracking permission state"
```

---

### Task 5: Permission UI composables

**Files:**
- Create: `app/src/main/java/org/ezdozit/app/permissions/PermissionUI.kt`

- [ ] **Step 1: Write the implementation**

Create `app/src/main/java/org/ezdozit/app/permissions/PermissionUI.kt`:
```kotlin
package org.ezdozit.app.permissions

import android.content.Intent
import android.net.Uri
import android.provider.Settings
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.platform.LocalContext

@Composable
fun EzRationaleDialog(
    permission: AppPermission,
    onAccept: () -> Unit,
    onDismiss: () -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Hey, quick thing!") },
        text = { Text(permission.rationale) },
        confirmButton = {
            TextButton(onClick = onAccept) {
                Text("Sure!")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Not now")
            }
        }
    )
}

@Composable
fun EzDeniedDialog(
    permission: AppPermission,
    onOpenSettings: () -> Unit,
    onDismiss: () -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("No problem!") },
        text = { Text(permission.deniedMessage) },
        confirmButton = {
            TextButton(onClick = onOpenSettings) {
                Text("Open Settings")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Maybe later")
            }
        }
    )
}

class PermissionRequestState(
    val launch: () -> Unit
)

@Composable
fun rememberPermissionRequest(
    permission: AppPermission,
    onResult: (PermissionStatus) -> Unit
): PermissionRequestState {
    val context = LocalContext.current
    val permissionManager = remember { PermissionManager(context) }

    val launcher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestMultiplePermissions()
    ) { results ->
        permissionManager.markAsRequested(permission)
        val allGranted = results.values.all { it }
        if (allGranted) {
            onResult(PermissionStatus.Granted)
        } else {
            val newStatus = permissionManager.check(permission)
            onResult(newStatus)
        }
    }

    return remember(permission) {
        PermissionRequestState(
            launch = {
                permissionManager.markAsRequested(permission)
                launcher.launch(permission.permissions.toTypedArray())
            }
        )
    }
}

fun openAppSettings(context: android.content.Context) {
    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
        data = Uri.fromParts("package", context.packageName, null)
    }
    context.startActivity(intent)
}
```

- [ ] **Step 2: Verify the build compiles**

Run:
```bash
JAVA_HOME=/snap/android-studio/209/jbr ./gradlew assembleDebug
```
Expected: BUILD SUCCESSFUL

- [ ] **Step 3: Commit**

```bash
git add app/src/main/java/org/ezdozit/app/permissions/PermissionUI.kt
git commit -m "feat: add Compose permission UI helpers (rationale dialog, denied dialog, rememberPermissionRequest)"
```

---

### Task 6: Wire up a demo screen and run all tests

**Files:**
- Modify: `app/src/main/java/org/ezdozit/app/MainActivity.kt`

- [ ] **Step 1: Update MainActivity to demo the permission flow**

Replace the content of `app/src/main/java/org/ezdozit/app/MainActivity.kt` with:
```kotlin
package org.ezdozit.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import org.ezdozit.app.permissions.AppPermission
import org.ezdozit.app.permissions.EzDeniedDialog
import org.ezdozit.app.permissions.EzRationaleDialog
import org.ezdozit.app.permissions.PermissionManager
import org.ezdozit.app.permissions.PermissionStatus
import org.ezdozit.app.permissions.openAppSettings
import org.ezdozit.app.permissions.rememberPermissionRequest
import org.ezdozit.app.ui.theme.EzDozitTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            EzDozitTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    PermissionDemoScreen(modifier = Modifier.padding(innerPadding))
                }
            }
        }
    }
}

@Composable
fun PermissionDemoScreen(modifier: Modifier = Modifier) {
    val context = LocalContext.current
    val permissionManager = remember { PermissionManager(context) }

    var statusText by remember { mutableStateOf("Tap a button to test permissions") }
    var showRationale by remember { mutableStateOf<AppPermission?>(null) }
    var showDenied by remember { mutableStateOf<AppPermission?>(null) }

    val locationRequest = rememberPermissionRequest(AppPermission.FineLocation) { status ->
        statusText = "Location: ${status::class.simpleName}"
        if (status is PermissionStatus.PermanentlyDenied) {
            showDenied = AppPermission.FineLocation
        }
    }

    val notificationRequest = rememberPermissionRequest(AppPermission.Notifications) { status ->
        statusText = "Notifications: ${status::class.simpleName}"
        if (status is PermissionStatus.PermanentlyDenied) {
            showDenied = AppPermission.Notifications
        }
    }

    Column(
        modifier = modifier.fillMaxSize(),
        verticalArrangement = Arrangement.spacedBy(16.dp, Alignment.CenterVertically),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(text = statusText)

        Button(onClick = {
            val status = permissionManager.check(AppPermission.FineLocation)
            if (status is PermissionStatus.Granted) {
                statusText = "Location: already granted!"
            } else {
                showRationale = AppPermission.FineLocation
            }
        }) {
            Text("Request Location")
        }

        Button(onClick = {
            val status = permissionManager.check(AppPermission.Notifications)
            if (status is PermissionStatus.Granted) {
                statusText = "Notifications: already granted!"
            } else {
                showRationale = AppPermission.Notifications
            }
        }) {
            Text("Request Notifications")
        }
    }

    showRationale?.let { permission ->
        EzRationaleDialog(
            permission = permission,
            onAccept = {
                showRationale = null
                when (permission) {
                    AppPermission.FineLocation -> locationRequest.launch()
                    AppPermission.Notifications -> notificationRequest.launch()
                    else -> {}
                }
            },
            onDismiss = {
                showRationale = null
                statusText = "${permission.name}: dismissed rationale"
            }
        )
    }

    showDenied?.let { permission ->
        EzDeniedDialog(
            permission = permission,
            onOpenSettings = {
                showDenied = null
                openAppSettings(context)
            },
            onDismiss = {
                showDenied = null
            }
        )
    }
}
```

- [ ] **Step 2: Run all unit tests**

Run:
```bash
JAVA_HOME=/snap/android-studio/209/jbr ./gradlew testDebugUnitTest
```
Expected: All tests PASS

- [ ] **Step 3: Run full build**

Run:
```bash
JAVA_HOME=/snap/android-studio/209/jbr ./gradlew assembleDebug
```
Expected: BUILD SUCCESSFUL

- [ ] **Step 4: Commit**

```bash
git add app/src/main/java/org/ezdozit/app/MainActivity.kt
git commit -m "feat: add permission demo screen to test rationale and request flow"
```

- [ ] **Step 5: Test on emulator**

Open the project in Android Studio and run the app on the emulator. You should see:
1. A screen with "Tap a button to test permissions" text
2. Two buttons: "Request Location" and "Request Notifications"
3. Tapping a button shows Ez's rationale dialog first
4. Tapping "Sure!" triggers the system permission prompt
5. The status text updates to show the result
6. If permanently denied, the denied dialog appears with an "Open Settings" option
