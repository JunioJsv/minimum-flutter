import 'package:json_annotation/json_annotation.dart';
import 'package:minimum/models/entry.dart';

part 'applications_group.g.dart';

@JsonSerializable()
class ApplicationsGroup extends Entry {
  final String id;
  final String? description;
  final Set<String> components;

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
    required this.components,
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
    Set<String>? components,
    bool? isNew,
  }) {
    return ApplicationsGroup(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      components: components ?? this.components,
      isNew: isNew ?? this.isNew,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    id,
    description,
    components,
    isNew,
  ];
}
