import 'package:flutter/services.dart';
import 'package:minimum/models/application.dart';

class ApplicationsManagerService {
  static const kChannelName = 'juniojsv.minimum/applications_manager_plugin';
  static const kGetInstalledApplications = 'get_installed_applications';
  static const kLaunchApplication = 'launch_application';

  static const kGetApplicationIcon = 'get_application_icon';

  final channel = const MethodChannel(kChannelName);

  final int _maxIconsCached = 30;
  final Map<String, Uint8List> _iconsCache = {};

  Future<List<Application>> getInstalledApplications() async {
    final json = await channel.invokeListMethod<Map>(kGetInstalledApplications);
    final applications =
        json?.map((json) => Application.fromJson(json.cast())).toList();

    return applications!;
  }

  Future<void> launchApplication(String package) async {
    await channel.invokeMethod(
      kLaunchApplication,
      {'package_name': package},
    );
  }

  Future<Uint8List> getApplicationIcon(String package) async {
    var bytes = _iconsCache[package];
    if (bytes != null) return bytes;
    bytes = await channel.invokeMethod<Uint8List>(
      kGetApplicationIcon,
      {'package_name': package},
    );
    if (_iconsCache.length == _maxIconsCached) {
      _iconsCache.remove(_iconsCache.keys.first);
    }
    _iconsCache[package] = bytes!;

    return bytes;
  }
}
