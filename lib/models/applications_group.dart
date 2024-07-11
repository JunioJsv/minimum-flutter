import 'package:json_annotation/json_annotation.dart';
import 'package:minimum/models/entry.dart';

part 'applications_group.g.dart';

@JsonSerializable()
class ApplicationsGroup extends Entry {
  final String id;
  final String? description;
  final Set<String> packages;

  @override
  int get priority => 0;

  const ApplicationsGroup({
    required this.id,
    required super.label,
    required this.description,
    required this.packages,
  });

  factory ApplicationsGroup.fromJson(Map<String, dynamic> json) {
    return _$ApplicationsGroupFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ApplicationsGroupToJson(this);

  @override
  List<Object?> get props => [...super.props, id, description, packages];
}
