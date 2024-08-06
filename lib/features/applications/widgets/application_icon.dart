import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:minimum/features/applications/blocs/applications_manager/applications_manager_cubit.dart';
import 'package:minimum/features/applications/utils/applications_actions.dart';
import 'package:minimum/main.dart';
import 'package:minimum/models/application.dart';
import 'package:minimum/models/icon_pack_drawable.dart';
import 'package:minimum/services/applications_manager_service.dart';
import 'package:transparent_image/transparent_image.dart';

class ApplicationIcon extends StatefulWidget {
  final String? package;
  final bool shadow;
  final IconPackDrawable? drawable;
  final bool keepAlive;
  final bool ignorePreferences;

  const ApplicationIcon({
    super.key,
    this.package,
    this.shadow = true,
    this.keepAlive = true,
    this.ignorePreferences = false,
  }) : drawable = null;

  const ApplicationIcon.fromIconPack({
    super.key,
    this.package,
    required IconPackDrawable this.drawable,
    this.shadow = true,
    this.keepAlive = true,
    this.ignorePreferences = false,
  });

  @override
  ApplicationIconState createState() => ApplicationIconState();
}

class ApplicationIconState extends State<ApplicationIcon>
    with
        AutomaticKeepAliveClientMixin,
        ApplicationsManagerServiceListener,
        ApplicationsActionsListener {
  final applications = dependencies<ApplicationsManagerCubit>();
  final service = dependencies<ApplicationsManagerService>();
  final applicationActions = dependencies<ApplicationsActions>();
  late var icon = getIcon();

  Future<Uint8List> getIcon() async {
    final state = applications.state;
    final package = widget.package;
    final preferences = !widget.ignorePreferences &&
            package != null &&
            state is ApplicationsManagerFetchSuccess
        ? state.getApplicationPreferences(package)
        : null;
    final drawable = widget.drawable ?? preferences?.icon;
    if (drawable != null) {
      try {
        return await service.getIconPackIcon(
          drawable.package,
          drawable.name,
        );
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    return service.getApplicationIcon(package);
  }

  @override
  void didChangeApplicationsIcons() {
    setState(() {
      icon = getIcon();
    });
  }

  @override
  void didChangeApplicationIcon(Application application) {
    if (application.package == widget.package) {
      setState(() {
        icon = getIcon();
      });
    }
  }

  @override
  void initState() {
    service.addListener(this);
    applicationActions.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    service.removeListener(this);
    applicationActions.removeListener(this);
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
  bool get wantKeepAlive => widget.keepAlive;
}
