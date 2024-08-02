import 'package:flutter/material.dart';
import 'package:minimum/main.dart';
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
    with AutomaticKeepAliveClientMixin, ApplicationsManagerServiceListener {
  final service = dependencies<ApplicationsManagerService>();
  late var icon = service.getApplicationIcon(widget.package);

  @override
  void didChangeApplicationsIcons() {
    setState(() {
      icon = service.getApplicationIcon(widget.package);
    });
  }

  @override
  void initState() {
    service.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    service.removeListener(this);
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
