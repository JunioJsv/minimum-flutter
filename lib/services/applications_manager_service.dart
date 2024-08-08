import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:minimum/models/application.dart';
import 'package:minimum/models/application_event.dart';
import 'package:minimum/models/icon_pack.dart';
import 'package:minimum/utils/memory_cache.dart';

mixin ApplicationsManagerServiceListener {
  void didChangeApplicationsIcons() {}
}

class ApplicationsManagerService with WidgetsBindingObserver {
  static const kChannelName = 'juniojsv.minimum/applications_manager_plugin';
  static const kEventsChannelName = 'juniojsv.minimum/applications_events';
  static const kGetInstalledApplications = 'get_installed_applications';
  static const kLaunchApplication = 'launch_application';
  static const kGetApplicationIcon = 'get_application_icon';
  static const kGetPackageIcon = "get_package_icon";
  static const kIsAlreadyCurrentLauncher = 'is_already_current_launcher';
  static const kOpenCurrentLauncherSystemSettings =
      'open_current_launcher_system_settings';

  static const kOpenApplicationDetails = 'open_application_details';
  static const kUninstallPackage = 'uninstall_package';

  static const kGetApplication = 'get_application';
  static const kGetPackageApplications = 'get_package_applications';
  static const kGetIconPacks = 'get_icon_packs';

  static const kSetIconPack = 'set_icon_pack';
  static const kIsPackageEnabled = "is_package_enabled";

  static const kGetIconPackDrawables = "get_icon_pack_drawables";

  static const kGetIconFromIconPack = "get_icon_from_icon_pack";

  final _listeners = <ApplicationsManagerServiceListener>[];

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

  void addListener(ApplicationsManagerServiceListener listener) {
    _listeners.add(listener);
  }

  void removeListener(ApplicationsManagerServiceListener listener) {
    _listeners.remove(listener);
  }

  Future<void> launchApplication(String component) async {
    await channel.invokeMethod(
      kLaunchApplication,
      {'component_name': component},
    );
  }

  Future<Uint8List> getIconFromIconPack(
    String package,
    String drawable, [
    int size = 96,
  ]) async {
    final bytes = await _icons.get(
      [package, drawable].join('/'),
      () async {
        final bytes = await channel.invokeMethod<Uint8List>(
          kGetIconFromIconPack,
          {
            'package_name': package,
            'drawable_name': drawable,
            'size': size,
          },
        );

        return bytes!;
      },
    );
    return bytes;
  }

  Future<Uint8List> getApplicationIcon([
    String? component,
    int size = 96,
  ]) async {
    final bytes = await _icons.get(
      component ?? 'default',
      () async {
        final bytes = await channel.invokeMethod<Uint8List>(
          kGetApplicationIcon,
          {
            if (component != null) 'component_name': component,
            'size': size,
          },
        );

        return bytes!;
      },
    );
    return bytes;
  }

  Future<Uint8List> getPackageIcon([
    String? package,
    int size = 96,
  ]) async {
    final bytes = await _icons.get(
      package ?? 'default',
      () async {
        final bytes = await channel.invokeMethod<Uint8List>(
          kGetPackageIcon,
          {
            if (package != null) 'package_name': package,
            'size': size,
          },
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

  Future<void> openApplicationDetails(String component) async {
    await channel.invokeMethod(
      kOpenApplicationDetails,
      {'component_name': component},
    );
  }

  Future<void> uninstallPackage(String package) async {
    await channel.invokeMethod(
      kUninstallPackage,
      {'package_name': package},
    );
  }

  Future<ApplicationBase> getApplication(String component) async {
    final json = await channel.invokeMethod(
      kGetApplication,
      {'component_name': component},
    );

    return ApplicationBase.fromJson((json as Map).cast());
  }

  Future<IList<ApplicationBase>> getPackageApplications(String package) async {
    final json = await channel.invokeListMethod<Map>(
      kGetPackageApplications,
      {'package_name': package},
    );

    final applications = json
        ?.map(
          (json) => ApplicationBase.fromJson(json.cast()),
        )
        .toIList();

    return applications!;
  }

  Future<IList<IconPack>> getIconPacks() async {
    final json = await channel.invokeListMethod<Map>(kGetIconPacks);
    final iconPacks = json?.map((json) {
      return IconPack.fromJson(json.cast());
    }).toIList();

    return iconPacks!;
  }

  @override
  void didChangePlatformBrightness() {
    _icons.clear();
    for (final listener in _listeners) {
      listener.didChangeApplicationsIcons();
    }
  }

  Future<bool> setIconPack(String? package) async {
    final isIconPackApplied = await channel.invokeMethod<bool>(
      kSetIconPack,
      {
        if (package != null) 'package_name': package,
      },
    ).then((value) => value ?? false);

    if (isIconPackApplied) {
      _icons.clear();
      for (final listener in _listeners) {
        listener.didChangeApplicationsIcons();
      }
    }

    return isIconPackApplied;
  }

  Future<bool> isPackageEnabled(String package) async {
    final isApplicationEnabled = await channel.invokeMethod<bool>(
      kIsPackageEnabled,
      {
        'package_name': package,
      },
    ).then((value) => value ?? false);

    return isApplicationEnabled;
  }

  /// @return Map<ComponentName, DrawableName>
  Future<Map<String, String>> getIconPackDrawables(String package) async {
    final drawables = await channel.invokeMethod<Map>(
      kGetIconPackDrawables,
      {
        'package_name': package,
      },
    );

    return drawables!.cast();
  }
}
