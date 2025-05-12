import 'package:flutter/material.dart';
import 'screens/smart_bin_screen.dart';

void main() {
  runApp(const SmartMonitorApp());
}

class SmartMonitorApp extends StatelessWidget {
  const SmartMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartBin Monitor',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SmartBinScreen(),
    );
  }
}
