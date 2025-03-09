import 'package:flutter/services.dart';

class LocalAuthenticationService {
  final channel = const MethodChannel(
    'juniojsv.minimum/local_authentication_plugin',
  );
  static const kAuthenticate = 'authenticate';
  static const kIsDeviceSecure = 'is_device_secure';
  Future<void> authenticate({required String title, String? subtitle}) async {
    await channel.invokeMethod(kAuthenticate, {
      'title': title,
      if (subtitle != null) 'subtitle': subtitle,
    });
  }

  Future<bool> isDeviceSecure() async {
    final isDeviceSecure = await channel.invokeMethod<bool>(kIsDeviceSecure);
    return isDeviceSecure ?? false;
  }
}
