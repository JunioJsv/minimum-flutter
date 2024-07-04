import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'application.g.dart';

@JsonSerializable()
class Application extends Equatable implements Comparable<Application> {
  final String label;
  final String package;

  const Application({required this.label, required this.package});

  factory Application.fromJson(Map<String, dynamic> json) {
    return _$ApplicationFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ApplicationToJson(this);

  @override
  int compareTo(other) {
    return label.toLowerCase().compareTo(other.label.toLowerCase());
  }

  @override
  List<Object> get props => [label, package];
}
