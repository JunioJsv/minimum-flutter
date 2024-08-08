import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minimum/environment.dart';
import 'package:minimum/features/applications/widgets/application_icon.dart';
import 'package:minimum/features/icon_packs/screens/icon_pack_selector_screen.dart';
import 'package:minimum/features/preferences/blocs/preferences_manager/preferences_manager_cubit.dart';
import 'package:minimum/features/preferences/widgets/category_text.dart';
import 'package:minimum/features/preferences/widgets/slider_list_tile.dart';
import 'package:minimum/i18n/translations.g.dart';
import 'package:minimum/main.dart';
import 'package:minimum/models/application.dart';
import 'package:minimum/models/icon_pack.dart';
import 'package:minimum/services/applications_manager_service.dart';
import 'package:minimum/services/local_authentication_service.dart';
import 'package:minimum/widgets/confirmation_dialog.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PreferencesScreen extends StatelessWidget {
  static final String route = '$PreferencesScreen';

  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final translation = context.translations;
    final PreferencesManagerCubit preferences = dependencies();
    final ApplicationsManagerService service = dependencies();
    final LocalAuthenticationService auth = dependencies();
    return Scaffold(
      appBar: AppBar(
        title: Text(translation.preferences),
        leading: const BackButton(),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          CategoryText(text: translation.appearance),
          BlocSelector<PreferencesManagerCubit, PreferencesManagerState, bool>(
            bloc: preferences,
            selector: (state) {
              return state.isGridLayoutEnabled;
            },
            builder: (context, value) {
              return SwitchListTile(
                title: Text(translation.gridView),
                value: value,
                onChanged: (value) => preferences.update((preferences) {
                  return preferences.copyWith(isGridLayoutEnabled: value);
                }),
              );
            },
          ),
          BlocSelector<PreferencesManagerCubit, PreferencesManagerState,
              ({bool isEnabled, int count})>(
            bloc: preferences,
            selector: (state) {
              return (
                isEnabled: state.isGridLayoutEnabled,
                count: state.gridCrossAxisCount,
              );
            },
            builder: (context, preference) {
              return SliderListTile(
                min: 3,
                max: 5,
                title: translation.gridCrossAxisCount,
                subtitle: translation.defineApplicationsPerLine,
                isEnabled: preference.isEnabled,
                value: preference.count,
                onChange: (int value) => preferences.update((preferences) {
                  return preferences.copyWith(gridCrossAxisCount: value);
                }),
              );
            },
          ),
          BlocSelector<PreferencesManagerCubit, PreferencesManagerState,
              IconPack?>(
            bloc: preferences,
            selector: (state) {
              return state.iconPack;
            },
            builder: (context, iconPack) {
              final subtitle = iconPack?.label ?? translation.standard;
              final package = iconPack?.package;
              return ListTile(
                key: ValueKey(package ?? 'system'),
                title: Text(translation.iconPack),
                subtitle: Text(subtitle),
                leading: package != null
                    ? SizedBox.square(
                        dimension: 48,
                        child: ApplicationIcon.formPackage(
                          package: package,
                          ignorePreferences: true,
                        ),
                      )
                    : null,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    IconPackSelectorScreen.route,
                    arguments: IconPackSelectorScreenArguments(
                      onSelect: (context, value) {
                        Navigator.pop(context);
                        preferences.update((preferences) {
                          return preferences.copyWith(iconPack: () => value);
                        });
                      },
                    ),
                  );
                },
              );
            },
          ),
          const Divider(height: 32),
          CategoryText(text: translation.general),
          BlocSelector<PreferencesManagerCubit, PreferencesManagerState, bool>(
            bloc: preferences,
            selector: (state) {
              return state.showHidden;
            },
            builder: (context, isShowingHidden) {
              return SwitchListTile(
                title: Text(translation.showHidden),
                subtitle: Text(translation.showHiddenApplications),
                value: isShowingHidden,
                onChanged: (value) async {
                  final isDeviceSecure = await auth.isDeviceSecure();
                  if (!isDeviceSecure && value) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showDialog(
                        context: context,
                        builder: (context) => ConfirmationDialog(
                          icon: const Icon(Icons.visibility_outlined),
                          title: translation.lockscreenRequired,
                          message: translation.setupLockscreen(
                            to: translation.showHiddenApplications
                                .toLowerCase(),
                          ),
                          confirm: translation.understood,
                        ),
                      );
                    });
                    return;
                  }
                  if (value && isDeviceSecure) {
                    await auth.authenticate(
                      title: translation.authenticationRequired,
                      subtitle: translation.useAuthentication(
                        to: translation.showHiddenApplications.toLowerCase(),
                      ),
                    );
                  }
                  preferences.update((preferences) {
                    return preferences.copyWith(showHidden: value);
                  });
                },
              );
            },
          ),
          const Divider(height: 32),
          CategoryText(text: translation.about),
          FutureBuilder<ApplicationBase>(
              future: service.getApplication(
                'juniojsv.minimum/juniojsv.minimum.MainActivity',
              ),
              builder: (context, snapshot) {
                final application = snapshot.data;
                return ListTile(
                  title: Text(translation.appName),
                  subtitle: application != null
                      ? Text(
                          '${translation.version}'
                          ' ${application.version}',
                        )
                      : null,
                  onTap: () {
                    launchUrlString(kGithubProjectUrl);
                  },
                );
              }),
          ListTile(
            title: Text(translation.author),
            subtitle: Text(translation.createdByJuniojsv),
            onTap: () {
              launchUrlString(kGithubProfileUrl);
            },
          ),
          ListTile(
            title: Text(translation.licences),
            subtitle: Text(translation.infoAboutLicenses),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: translation.appName,
                applicationLegalese: translation.copyright,
              );
            },
          ),
          const SizedBox(height: kToolbarHeight),
        ],
      ),
    );
  }
}
