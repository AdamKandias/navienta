import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

class Utils {
  static Future<Map<String, dynamic>> isTablet(BuildContext context) async {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    bool isTabletDevice = shortestSide >= 600;

    if (Platform.isIOS) {
      final deviceInfo = DeviceInfoPlugin();
      final iosInfo = await deviceInfo.iosInfo;
      isTabletDevice = iosInfo.model.toLowerCase().contains("ipad");
    }

    return {
      'isTab': isTabletDevice,
      'shortestSide': shortestSide,
    };
  }
}
