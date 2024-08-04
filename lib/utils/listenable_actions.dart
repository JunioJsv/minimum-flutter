mixin class ListenableActions<T> {
  final _listeners = <T>[];

  void addListener(T listener) {
    _listeners.add(listener);
  }

  void removeListener(T listener) {
    _listeners.remove(listener);
  }

  void notify(void Function(T listener) callback) {
    for (final listener in _listeners) {
      callback(listener);
    }
  }

  void dispose() {
    _listeners.clear();
  }
}
