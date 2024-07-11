import 'package:json_annotation/json_annotation.dart';
import 'package:minimum/models/entry.dart';

part 'applications_group.g.dart';

@JsonSerializable()
class ApplicationsGroup extends Entry {
  final String id;
  final String? description;
  final Set<String> packages;

  final bool isNew;

  @override
  int get priority {
    var value = 0;
    if (isNew) value += 4;

    return value;
  }

  const ApplicationsGroup({
    required this.id,
    required super.label,
    required this.description,
    required this.packages,
    required this.isNew,
  });

  factory ApplicationsGroup.fromJson(Map<String, dynamic> json) {
    return _$ApplicationsGroupFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ApplicationsGroupToJson(this);

  ApplicationsGroup copyWith({
    String? id,
    String? label,
    String? description,
    Set<String>? packages,
    bool? isNew,
  }) {
    return ApplicationsGroup(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      packages: packages ?? this.packages,
      isNew: isNew ?? this.isNew,
    );
  }

  @override
  List<Object?> get props => [...super.props, id, description, packages, isNew];
}
