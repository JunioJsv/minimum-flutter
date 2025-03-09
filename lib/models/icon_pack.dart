import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'icon_pack.g.dart';

@JsonSerializable()
class IconPack extends Equatable {
  final String label;
  final String package;

  const IconPack({required this.label, required this.package});

  factory IconPack.fromJson(Map<String, dynamic> json) {
    return _$IconPackFromJson(json);
  }

  Map<String, dynamic> toJson() => _$IconPackToJson(this);

  @override
  List<Object> get props => [label, package];
}
