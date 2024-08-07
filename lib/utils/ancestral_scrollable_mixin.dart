import 'package:flutter/material.dart';

@optionalTypeArgs
mixin AncestralScrollableMixin<T extends StatefulWidget> on State<T> {
  ScrollableState? ancestralScrollable;

  void didChangeAncestralScrollablePosition();

  @mustCallSuper
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ancestralScrollable?.position.removeListener(
      didChangeAncestralScrollablePosition,
    );
    ancestralScrollable = Scrollable.maybeOf(context);
    ancestralScrollable?.position.addListener(
      didChangeAncestralScrollablePosition,
    );
  }

  @mustCallSuper
  @override
  void dispose() {
    ancestralScrollable?.position.removeListener(
      didChangeAncestralScrollablePosition,
    );
    super.dispose();
  }
}
