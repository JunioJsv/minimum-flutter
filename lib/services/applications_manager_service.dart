import 'package:flutter/services.dart';
import 'package:minimum/models/application.dart';

class ApplicationsManagerService {
  static const kChannelName = 'juniojsv.minimum/applications_manager_plugin';
  static const kGetInstalledApplications = 'get_installed_applications';
  static const kLaunchApplication = 'launch_application';

  final channel = const MethodChannel(kChannelName);

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
}
