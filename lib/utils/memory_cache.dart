import 'dart:collection';

class MemoryCache<T> {
  final int capacity;

  MemoryCache({required this.capacity});

  final Map<String, T> _cache = {};
  final _keys = Queue<String>();

  Future<T> get(String key, Future<T> Function() ifAbsent) async {
    if (_cache.containsKey(key)) return _cache[key]!;

    final value = await ifAbsent();
    if (_cache.length >= capacity) {
      _cache.remove(_keys.removeFirst());
    }
    _cache.addEntries([MapEntry(key, value)]);
    _keys.addLast(key);
    return value;
  }

  void clear() {
    _cache.clear();
    _keys.clear();
  }
}
