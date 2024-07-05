import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
part 'application_preferences.g.dart';

@JsonSerializable()
class ApplicationPreferences extends Equatable {
  final bool isPinned;

  const ApplicationPreferences({this.isPinned = false});

  ApplicationPreferences copyWith({
    bool? isPinned,
  }) {
    return ApplicationPreferences(
      isPinned: isPinned ?? this.isPinned,
    );
  }

  factory ApplicationPreferences.fromJson(Map<String, dynamic> json) {
    return _$ApplicationPreferencesFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ApplicationPreferencesToJson(this);

  @override
  List<Object> get props => [isPinned];
}
