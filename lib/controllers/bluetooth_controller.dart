import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:location/location.dart' as location;
import 'package:logging/logging.dart';

final Logger _logger = Logger('BluetoothController');

class BluetoothController {
  final String deviceName = "SmartBinESP"; 
  Future<void> requestPermissions() async {
    _logger.info('Requesting Bluetooth and Location Permissions...');
    await [
      ph.Permission.bluetoothScan,
      ph.Permission.bluetoothConnect,
      ph.Permission.location,
    ].request();
  }

  Future<BluetoothDevice?> scanAndConnect() async {
    BluetoothDevice? connectedDevice;
    await requestPermissions();
    _logger.info('Starting Bluetooth Scan...');

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

   
    await for (final results in FlutterBluePlus.scanResults) {
      for (final result in results) {
        _logger.info("Found Device: ${result.device.platformName}");
        if (result.device.platformName == deviceName) {
          _logger.info("SmartBinESP found! Attempting connection...");
          await FlutterBluePlus.stopScan();

          try {
            await result.device.connect();
            _logger.info("Connected to SmartBinESP!");
            connectedDevice = result.device;
          } catch (e) {
            _logger.severe("Connection Failed: $e");
          }
          return connectedDevice;
        }
      }
    }

    _logger.info("Scan complete. SmartBinESP ${connectedDevice != null ? 'connected' : 'not found'}.");
    return connectedDevice;
  }

  Future<void> listenToBinLevel(
    BluetoothDevice device,
    Function(String) onData,
  ) async {
    _logger.info("Discovering Services...");
    final services = await device.discoverServices();

    for (final service in services) {
      for (final characteristic in service.characteristics) {
        _logger.info("Found Characteristic: ${characteristic.uuid}");
        if (characteristic.properties.notify || characteristic.properties.read) {
          await characteristic.setNotifyValue(true);
          characteristic.onValueReceived.listen((value) {
            final level = String.fromCharCodes(value);
            _logger.info("Received Bin Level Data: $level%");
            onData(level);
          });
        }
      }
    }
  }

  Future<void> checkAndRequestLocationServices() async {
    location.Location locationService = location.Location();
    bool serviceEnabled = await locationService.serviceEnabled();
    location.PermissionStatus locationPermissionStatus;

    if (!serviceEnabled) {
      serviceEnabled = await locationService.requestService();
      if (!serviceEnabled) {
        _logger.info("Location services are required for Bluetooth scanning.");
        return;
      }
    }

    locationPermissionStatus = await locationService.hasPermission();
    if (locationPermissionStatus == location.PermissionStatus.denied) {
      locationPermissionStatus = await locationService.requestPermission();
      if (locationPermissionStatus != location.PermissionStatus.granted) {
        _logger.info("Location permission is required for Bluetooth scanning.");
        return;
      }
    }

    await scanAndConnect();
  }
}