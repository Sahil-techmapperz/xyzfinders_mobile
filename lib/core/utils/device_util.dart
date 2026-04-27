import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceUtil {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<Map<String, String>> getDeviceInfo() async {
    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        return {
          'device_id': webInfo.userAgent ?? 'web_browser',
          'device_name': '${webInfo.browserName.name} on ${webInfo.platform}',
        };
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'device_id': androidInfo.id,
          'device_name': '${androidInfo.manufacturer} ${androidInfo.model}',
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'device_id': iosInfo.identifierForVendor ?? 'ios_device',
          'device_name': iosInfo.utsname.machine,
        };
      }
    } catch (e) {
      debugPrint('Error getting device info: $e');
    }
    
    return {
      'device_id': 'unknown_id',
      'device_name': Platform.isAndroid ? 'Android Device' : (Platform.isIOS ? 'iOS Device' : 'Unknown Device'),
    };
  }
}
