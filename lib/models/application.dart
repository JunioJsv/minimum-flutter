import 'package:json_annotation/json_annotation.dart';
import 'package:minimum/models/application_preferences.dart';
import 'package:minimum/models/entry.dart';

part 'application.g.dart';

@JsonSerializable()
class Application extends Entry {
  final String package;
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
