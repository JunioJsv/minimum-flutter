import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:minimum/models/application_preferences.dart';

part 'application.g.dart';

@JsonSerializable()
class Application extends Equatable implements Comparable<Application> {
  final String label;
  final String package;

  final ApplicationPreferences preferences;

  int get priority => preferences.isPinned ? 1 : 0;

  const Application({
    required this.label,
    required this.package,
    this.preferences = const ApplicationPreferences(),
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return _$ApplicationFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ApplicationToJson(this);

  @override
  int compareTo(other) {
    if (priority != other.priority) {
      return other.priority.compareTo(priority);
    }
    return label.toLowerCase().compareTo(other.label.toLowerCase());
  }

  Application copyWith({
    String? label,
    String? package,
    ApplicationPreferences? preferences,
  }) {
    return Application(
      label: label ?? this.label,
      package: package ?? this.package,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  List<Object> get props => [label, package, preferences];
}
