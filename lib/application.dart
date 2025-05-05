import 'package:flutter/material.dart';
import 'package:ios_integration_demo/view/device_info_screen.dart';
import 'package:ios_integration_demo/viewmodel/device_info_viewmodel.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (_) => DeviceInfoViewModel()..getAllDeviceInfo(),
        child: DeviceInfoScreen(),
      ),
    );
  }
}
