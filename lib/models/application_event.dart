import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'application_event.g.dart';

@JsonEnum(valueField: 'value')
enum ApplicationIntentAction {
  packageRemoved('android.intent.action.PACKAGE_REMOVED'),
  packageAdded('android.intent.action.PACKAGE_ADDED'),
  packageChanged('android.intent.action.PACKAGE_CHANGED');

  final String value;

  const ApplicationIntentAction(this.value);
}

@JsonSerializable()
class ApplicationEvent extends Equatable {
  final ApplicationIntentAction action;
  final String package;
  final bool canLaunch;
  final bool isReplacing;

  const ApplicationEvent({
    required this.action,
    required this.package,
    required this.canLaunch,
    required this.isReplacing,
  });

  factory ApplicationEvent.fromJson(Map<String, dynamic> json) {
    return _$ApplicationEventFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ApplicationEventToJson(this);

  @override
  List<Object> get props => [action, package, canLaunch, isReplacing];
}
