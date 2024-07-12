import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/services.dart';
import 'package:minimum/models/application.dart';
import 'package:minimum/models/application_event.dart';
import 'package:minimum/utils/memory_cache.dart';

class ApplicationsManagerService {
  static const kChannelName = 'juniojsv.minimum/applications_manager_plugin';
  static const kEventsChannelName = 'juniojsv.minimum/applications_events';
  static const kGetInstalledApplications = 'get_installed_applications';
  static const kLaunchApplication = 'launch_application';
  static const kGetApplicationIcon = 'get_application_icon';
  static const kIsAlreadyCurrentLauncher = 'is_already_current_launcher';
  static const kOpenCurrentLauncherSystemSettings =
      'open_current_launcher_system_settings';

  static const kOpenApplicationDetails = 'open_application_details';
  static const kUninstallApplication = 'uninstall_application';

  static const kGetApplication = 'get_application';

  final channel = const MethodChannel(kChannelName);
  final eventsChannel = const EventChannel(kEventsChannelName);
  late final eventsStream = eventsChannel.receiveBroadcastStream().map(
    (event) {
      final json = event as Map;
      return ApplicationEvent.fromJson(json.cast());
    },
  );
  final _icons = MemoryCache<Uint8List>(capacity: 100);

  Future<IList<ApplicationBase>> getInstalledApplications() async {
    final json = await channel.invokeListMethod<Map>(kGetInstalledApplications);
    final applications =
        json?.map((json) => ApplicationBase.fromJson(json.cast())).toIList();

    return applications!;
  }

  Future<void> launchApplication(String package) async {
    await channel.invokeMethod(
      kLaunchApplication,
      {'package_name': package},
    );
  }

  Future<Uint8List> getApplicationIcon(String package) async {
    final bytes = await _icons.get(
      package,
      () async {
        final bytes = await channel.invokeMethod<Uint8List>(
          kGetApplicationIcon,
          {'package_name': package},
        );

        return bytes!;
      },
    );
    return bytes;
  }

  Future<bool> isAlreadyCurrentLauncher() async {
    final result = await channel.invokeMethod<bool>(
      kIsAlreadyCurrentLauncher,
    );

    return result == true;
  }

  Future<void> openCurrentLauncherSystemSettings() async {
    await channel.invokeMethod(kOpenCurrentLauncherSystemSettings);
  }

  Future<void> openApplicationDetails(String package) async {
    await channel.invokeMethod(
      kOpenApplicationDetails,
      {'package_name': package},
    );
  }

  Future<void> uninstallApplication(String package) async {
    await channel.invokeMethod(
      kUninstallApplication,
      {'package_name': package},
    );
  }

  Future<Application> getApplication(String package) async {
    final json = await channel.invokeMethod(
      kGetApplication,
      {'package_name': package},
    );

    return Application.fromJson((json as Map).cast());
  }
}
