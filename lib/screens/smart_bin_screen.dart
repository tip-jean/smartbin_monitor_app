import 'package:flutter/material.dart';
import '../controllers/bluetooth_controller.dart';
import 'package:permission_handler/permission_handler.dart';

class SmartBinScreen extends StatefulWidget {
  const SmartBinScreen({super.key});

  @override
  State<SmartBinScreen> createState() => _SmartBinScreenState();
}

class _SmartBinScreenState extends State<SmartBinScreen> {
  final BluetoothController bluetoothController = BluetoothController();
  String binLevel = "Scanning for SmartBin...";
  bool isScanning = false;

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
        binLevel = "Missing permissions: Enable Bluetooth & Location.";
      });
    }
  }


  void connectToDevice() async {
    if (isScanning) return;

    setState(() {
      isScanning = true;
      binLevel = "Searching for SmartBin...";
    });

    final device = await bluetoothController.scanAndConnect();
    if (device != null) {
      bluetoothController.listenToBinLevel(device, (level) {
        if (mounted) {
          setState(() {
            binLevel = "Bin Fill Level: $level%";
          });
        }
      });
    } else {
      if (mounted) {
        setState(() {
          binLevel = "SmartBin not found.";
          isScanning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SmartBin Monitor")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              binLevel,
              style: const TextStyle(fontSize: 28),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: connectToDevice,
              child: Text(isScanning ? "Scanning..." : "Reconnect"),
            ),
          ],
        ),
      ),
    );
  }
}