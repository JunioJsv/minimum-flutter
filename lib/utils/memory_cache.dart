import 'dart:collection';

class MemoryCache<T> {
  final int capacity;

  MemoryCache({required this.capacity});

  final Map<String, T> _cache = {};
  final _keys = Queue<String>();

  Future<T> get(String key, Future<T> Function() ifAbsent) async {
    T? entry = _cache[key];
    if (entry == null) {
      entry = await ifAbsent();
      if (_cache.length >= capacity) {
        _cache.remove(_keys.removeFirst());
      }
      _cache.addEntries([MapEntry(key, entry as T)]);
      _keys.addLast(key);
      return entry;
    }

    return entry;
  }

  void clear() {
    _cache.clear();
    _keys.clear();
  }
}
