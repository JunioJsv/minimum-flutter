import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:minimum/features/preferences/screens/preferences_screen.dart';
import 'package:minimum/i18n/translations.g.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicationsHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const ApplicationsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final translation = context.translations;
    return AppBar(
      title: Text(translation.appName),
      actions: [
        IconButton(
          onPressed: () {
            launchUrl(Uri(scheme: 'tel'));
          },
          icon: const Icon(Icons.call_outlined),
        ),
        IconButton(
          onPressed: () {
            // Todo move to services
            const intent = AndroidIntent(
              action: 'android.media.action.STILL_IMAGE_CAMERA',
            );

            intent.launchChooser(translation.takePicturesWith);
          },
          icon: const Icon(Icons.camera_alt_outlined),
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed(PreferencesScreen.route);
          },
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
