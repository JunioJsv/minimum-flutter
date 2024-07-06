import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@JsonEnum(alwaysCreate: true)
enum Order {
  asc,
  desc;

  Order toggle() {
    return this == Order.desc ? Order.asc : Order.desc;
  }

  String toJson() => _$OrderEnumMap[this]!;

  static Order? fromJson(String value) =>
      Order.values.firstWhereOrNull((element) => element.name == value);
}
