import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:minimum/models/icon_pack_drawable.dart';

part 'application_preferences.g.dart';

@JsonSerializable()
class ApplicationPreferences extends Equatable {
  final bool isPinned;
  final bool isHidden;
  final bool isNew;
  final IconPackDrawable? icon;

  const ApplicationPreferences({
    this.isPinned = false,
    this.isHidden = false,
    this.isNew = false,
    this.icon,
  });

  ApplicationPreferences copyWith({
    bool? isPinned,
    bool? isHidden,
    bool? isNew,
    ValueGetter<IconPackDrawable?>? icon,
  }) {
    return ApplicationPreferences(
      isPinned: isPinned ?? this.isPinned,
      isHidden: isHidden ?? this.isHidden,
      isNew: isNew ?? this.isNew,
      icon: icon != null ? icon() : this.icon,
    );
  }

  factory ApplicationPreferences.fromJson(Map<String, dynamic> json) {
    return _$ApplicationPreferencesFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ApplicationPreferencesToJson(this);

  @override
  List<Object?> get props => [isPinned, isHidden, isNew, icon];
}
