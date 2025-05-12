# Smart Monitor (SmartBin) 🗑️📱

A Flutter application that connects to an **ESP32-based SmartBin** over Bluetooth Low Energy (BLE), reads the fill-level reported by an ultrasonic sensor, and shows live status updates on your phone.

---

## ✨ Features

| Feature                     | Description                                                                                               |
| --------------------------- | --------------------------------------------------------------------------------------------------------- |
| **BLE Scan & Connect**      | Scans for a device named `SmartBinESP`, stops scanning once found, and establishes a BLE connection.      |
| **Live Fill-Level Updates** | Subscribes to a notify characteristic and displays the bin’s fill percentage in real-time.                |
| **Clean Architecture**      | Logic and UI are separated (`controllers/bluetooth_controller.dart` & `screens/smart_bin_screen.dart`).   |
| **Permission Handling**     | Requests Bluetooth and Location permissions at runtime and checks that Location Services are switched on. |
| **Cross-Platform**          | Developed and tested on Android (API 21 +); iOS compatible after minor Info.plist updates.                |

---

## 🗂 Project Structure

```
lib/
├── controllers/
│   └── bluetooth_controller.dart   # BLE + permission logic
├── screens/
│   └── smart_bin_screen.dart      # UI that displays bin level
├── main.dart                      # App entry point
pubspec.yaml                       # Dependencies (flutter_blue_plus, permission_handler, location)
└── README.md                      # You’re reading it! 🥳
```

---

## 📡 ESP32 Firmware (Arduino)

`/firmware/smart_bin.ino` (example) advertises a custom service `1234…abc` and a notify characteristic `abcd…ef`. Make sure to:

```cpp
BLEDevice::init("SmartBinESP");
```

so the Flutter app can identify it.

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK ≥ 3.6.2
* Dart ≥ 3.6
* Android Studio / VS Code with Flutter & Dart extensions
* A physical Android device (BLE is unreliable in emulators)
* ESP32 dev board flashed with the firmware above

### Installation

```bash
# 1⃣ Clone the repo
$ git clone https://github.com/your-username/smart_monitor.git
$ cd smart_monitor

# 2⃣ Install dependencies
$ flutter pub get

# 3⃣ Run on a device
$ flutter run  # or flutter build apk && flutter install
```

> **Note:** The first launch prompts for Bluetooth & Location permissions. Accept them and ensure Location Services are ON.

---

## 🔧 Build & Release

| Command                       | Purpose                                     |
| ----------------------------- | ------------------------------------------- |
| `flutter build apk --release` | Build a release APK.                        |
| `flutter build appbundle`     | Generate an AAB for Play Store.             |
| `flutter clean`               | Clear the build cache if Gradle misbehaves. |

### Android-specific

* **Namespace:** Set once in `android/app/build.gradle` → `namespace = "com.example.smart_monitor"`.
* **minSdkVersion 21** required for BLE.

---

## 🩹 Troubleshooting

| Problem                                         | Fix                                                                              |
| ----------------------------------------------- | -------------------------------------------------------------------------------- |
| *`Namespace not specified`*                     | Ensure every module’s `build.gradle` has an `android { namespace = "…" }` block. |
| *Location services required for Bluetooth scan* | Turn on Location Services and grant permissions.                                 |
| *AGP ≤ 8.1 + Java 21 build error*               | Bump AGP to ≥ 8.2.1 in root `settings.gradle` and Gradle wrapper to 8.2.         |

---

## 📜 License

MIT © 2025 Jean Mangaser
