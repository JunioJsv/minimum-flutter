import 'package:equatable/equatable.dart';
import 'package:minimum/models/order.dart';

abstract class Entry extends Equatable implements Comparable<Entry> {
  static Order orderBy = Order.asc;
  final String label;

  int get priority;

  const Entry({required this.label});

  @override
  int compareTo(Entry other) {
    if (priority != other.priority) return other.priority.compareTo(priority);
    if (orderBy == Order.desc) {
      return other.label.toLowerCase().compareTo(label.toLowerCase());
    }

    return label.toLowerCase().compareTo(other.label.toLowerCase());
  }

  @override
  List<Object?> get props => [label];
}
