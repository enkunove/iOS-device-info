import 'package:flutter/cupertino.dart';

import '../services/device_info_service.dart';

class DeviceInfoViewModel extends ChangeNotifier{

  Future<Map<String, dynamic>> data = Future.value({});

  Future<void> getAllDeviceInfo() async {
    data = DeviceInfoService.getAllDeviceInfo();
    notifyListeners();
  }
}