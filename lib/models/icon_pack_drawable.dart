import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'icon_pack_drawable.g.dart';

@JsonSerializable()
class IconPackDrawable extends Equatable {
  final String name;
  final String component;
  final String package;

  const IconPackDrawable({
    required this.name,
    required this.component,
    required this.package,
  });

  factory IconPackDrawable.fromJson(Map<String, dynamic> json) {
    return _$IconPackDrawableFromJson(json);
  }

  Map<String, dynamic> toJson() => _$IconPackDrawableToJson(this);

  @override
  List<Object> get props => [name, component, package];
}
