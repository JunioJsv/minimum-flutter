import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:minimum/models/application_preferences.dart';
import 'package:minimum/models/entry.dart';

part 'application.g.dart';

@JsonSerializable()
class ApplicationBase extends Equatable {
  final String label;
  final String package;
  final String version;

  const ApplicationBase({
    required this.label,
    required this.package,
    required this.version,
  });

  factory ApplicationBase.fromJson(Map<String, dynamic> json) {
    return _$ApplicationBaseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ApplicationBaseToJson(this);

  @override
  List<Object?> get props => [label, package, version];
}

@JsonSerializable()
class Application extends Entry implements ApplicationBase {
  @override
  final String package;
  @override
  final String version;

  final ApplicationPreferences preferences;

  @override
  int get priority {
    var value = 0;
    if (preferences.isPinned) value += 1;
    if (preferences.isHidden) value += 2;

    return value;
  }

  const Application({
    required super.label,
    required this.package,
    required this.version,
    this.preferences = const ApplicationPreferences(),
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return _$ApplicationFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$ApplicationToJson(this);

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
  List<Object?> get props => [...super.props, package, version, preferences];
}
