import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'application_event.g.dart';

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ApplicationEventType {
  onPackageRemoved,
  onPackageAdded,
  onPackageChanged,
  onPackagesAvailable,
  onPackagesUnavailable
}

@JsonSerializable()
class ApplicationEvent extends Equatable {
  final ApplicationEventType type;
  final List<String> packages;

  const ApplicationEvent({
    required this.type,
    required this.packages,
  });

  factory ApplicationEvent.fromJson(Map<String, dynamic> json) {
    return _$ApplicationEventFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ApplicationEventToJson(this);

  ApplicationEvent copyWith({
    ApplicationEventType? type,
    List<String>? packages,
  }) {
    return ApplicationEvent(
      type: type ?? this.type,
      packages: packages ?? this.packages,
    );
  }

  @override
  List<Object> get props => [type, packages];
}
