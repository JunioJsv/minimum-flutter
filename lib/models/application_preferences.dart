import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'application_preferences.g.dart';

@JsonSerializable()
class ApplicationPreferences extends Equatable {
  final bool isPinned;
  final bool isHidden;

  const ApplicationPreferences({
    this.isPinned = false,
    this.isHidden = false,
  });

  ApplicationPreferences copyWith({
    bool? isPinned,
    bool? isHidden,
  }) {
    return ApplicationPreferences(
      isPinned: isPinned ?? this.isPinned,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  factory ApplicationPreferences.fromJson(Map<String, dynamic> json) {
    return _$ApplicationPreferencesFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ApplicationPreferencesToJson(this);

  @override
  List<Object> get props => [isPinned, isHidden];
}
