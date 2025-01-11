import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

@JsonSerializable()
class SeatSettings {
  final int autoHeatTime;
  final int autoHeatTempThreshold;



  SeatSettings({
    required this.autoHeatTime,
    required this.autoHeatTempThreshold,

  });

  SeatSettings copyWith({
    int? autoHeatTime,
    int? autoHeatTempThreshold,

  }) =>
      SeatSettings(
        autoHeatTime: autoHeatTime ?? this.autoHeatTime,
        autoHeatTempThreshold:
        autoHeatTempThreshold ?? this.autoHeatTempThreshold,
      );

  factory SeatSettings.defaultSettings() => SeatSettings(
    autoHeatTime: 10,
    autoHeatTempThreshold: 15,

  );

  factory SeatSettings.fromJson(Map<String, dynamic> json) =>
      _$SeatSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SeatSettingsToJson(this);
}