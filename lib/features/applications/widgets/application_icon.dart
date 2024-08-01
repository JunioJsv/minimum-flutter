import 'dart:async';

import 'package:flutter/material.dart';
import 'package:minimum/features/preferences/blocs/preferences_manager/preferences_manager_cubit.dart';
import 'package:minimum/main.dart';
import 'package:minimum/models/icon_pack.dart';
import 'package:minimum/services/applications_manager_service.dart';
import 'package:transparent_image/transparent_image.dart';

class ApplicationIcon extends StatefulWidget {
  final String? package;
  final bool shadow;

  const ApplicationIcon({
    super.key,
    this.package,
    this.shadow = true,
  });

  @override
  ApplicationIconState createState() => ApplicationIconState();
}

class ApplicationIconState extends State<ApplicationIcon>
    with AutomaticKeepAliveClientMixin {
  final service = dependencies<ApplicationsManagerService>();
  final preferences = dependencies<PreferencesManagerCubit>();
  late IconPack? iconPack;
  late var icon = service.getApplicationIcon(widget.package);

  final List<StreamSubscription<dynamic>> subscriptions = [];

  @override
  void initState() {
    iconPack = preferences.state.iconPack;
    subscriptions.add(preferences.stream.listen((preferences) {
      if (preferences.iconPack != iconPack) {
        iconPack = preferences.iconPack;
        setState(() {
          icon = service.getApplicationIcon(widget.package);
        });
      }
    }));
    super.initState();
  }

  @override
  void dispose() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: icon,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        return DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: widget.shadow
                ? <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withOpacity(.1),
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    )
                  ]
                : null,
          ),
          child: SizedBox.expand(
            child: bytes != null
                ? FadeInImage(
                    placeholder: MemoryImage(kTransparentImage),
                    image: MemoryImage(bytes),
                  )
                : Container(),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
