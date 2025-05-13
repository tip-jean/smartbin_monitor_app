import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controllers/bluetooth_controller.dart';

class SmartBinScreen extends StatefulWidget {
  const SmartBinScreen({super.key});

  @override
  State<SmartBinScreen> createState() => _SmartBinScreenState();
}

class _SmartBinScreenState extends State<SmartBinScreen> {
  final BluetoothController bluetoothController = BluetoothController();
  String binStatusMessage = "Scanning for SmartBin...";
  bool isScanning = false;
  bool isConnected = false;
  bool hasAlertShown = false;

  @override
  void initState() {
    super.initState();
    checkAndRequestPermissions();
  }

  Future<void> checkAndRequestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (statuses[Permission.bluetoothScan]?.isGranted == true &&
        statuses[Permission.bluetoothConnect]?.isGranted == true &&
        statuses[Permission.location]?.isGranted == true) {
      connectToDevice();
    } else {
      setState(() {
        binStatusMessage = "Missing permissions: Enable Bluetooth & Location.";
      });
    }
  }

  void connectToDevice() async {
    if (isScanning) return;

    setState(() {
      isScanning = true;
      binStatusMessage = "Searching for SmartBin...";
    });

    final device = await bluetoothController.scanAndConnect();
    if (device != null) {
      setState(() {
        isConnected = true;
        isScanning = false;
      });

      bluetoothController.listenToBinLevel(device, (message) {
        if (mounted) {
          setState(() {
            binStatusMessage = message;
          });

          if (message.toLowerCase().contains("full") && !hasAlertShown) {
            hasAlertShown = true;
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("SmartBin Alert"),
                content: Text(message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          }
        }
      });
    } else {
      if (mounted) {
        setState(() {
          binStatusMessage = "SmartBin not found.";
          isConnected = false;
          isScanning = false;
        });
      }
    }
  }

  void disconnectFromDevice() {
    bluetoothController.disconnect();
    setState(() {
      isConnected = false;
      binStatusMessage = "Disconnected from SmartBin.";
      hasAlertShown = false;
    });
  }

  Widget buildStatusCard({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Card(
      elevation: 6,
      color: color ?? Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, size: 36, color: Colors.green.shade700),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SmartBin Monitor"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade900, Colors.green.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Icon(FontAwesomeIcons.trashCan, size: 80, color: Colors.white),
                const SizedBox(height: 20),
                buildStatusCard(
                  icon: FontAwesomeIcons.bluetooth,
                  label: "Connection",
                  value: isConnected ? "Connected" : "Not Connected",
                  color: isConnected ? Colors.green.shade100 : Colors.red.shade100,
                ),
                const SizedBox(height: 12),
                buildStatusCard(
                  icon: FontAwesomeIcons.batteryHalf,
                  label: "Bin Status",
                  value: binStatusMessage,
                ),
                const SizedBox(height: 25),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  onPressed: () {
                    if (isConnected) {
                      disconnectFromDevice();
                    } else {
                      hasAlertShown = false;
                      connectToDevice();
                    }
                  },
                  icon: Icon(isConnected ? Icons.cancel : Icons.sync),
                  label: Text(isConnected ? "Disconnect" : (isScanning ? "Scanning..." : "Reconnect")),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
