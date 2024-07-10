import 'package:flutter/material.dart';
import 'package:minimum/main.dart';
import 'package:minimum/services/applications_manager_service.dart';

class ApplicationIcon extends StatefulWidget {
  final String package;

  const ApplicationIcon({super.key, required this.package});

  @override
  ApplicationIconState createState() => ApplicationIconState();
}

class ApplicationIconState extends State<ApplicationIcon>
    with AutomaticKeepAliveClientMixin {
  final ApplicationsManagerService service = dependencies();
  late final icon = service.getApplicationIcon(widget.package);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: icon,
      builder: (context, snapshot) {
        return AnimatedSwitcher(
          duration: kThemeAnimationDuration,
          child: () {
            final bytes = snapshot.data;
            if (bytes == null) return const SizedBox.expand();
            return DecoratedBox(
              decoration: BoxDecoration(boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(.1),
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                )
              ]),
              child: Image.memory(bytes),
            );
          }(),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
