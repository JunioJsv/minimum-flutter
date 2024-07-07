import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:minimum/models/application_preferences.dart';

part 'application.g.dart';

@JsonSerializable()
class Application extends Equatable implements Comparable<Application> {
  final String label;
  final String package;
  final String version;

  final ApplicationPreferences preferences;

  int get priority {
    var value = 0;
    if (preferences.isPinned) value += 1;
    if (preferences.isHidden) value += 2;

    return value;
  }

  const Application({
    required this.label,
    required this.package,
    required this.version,
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
    String? version,
    ApplicationPreferences? preferences,
  }) {
    return Application(
      label: label ?? this.label,
      package: package ?? this.package,
      version: version ?? this.version,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  List<Object> get props => [label, package, version, preferences];
}
