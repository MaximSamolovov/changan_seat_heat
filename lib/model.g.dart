// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SeatSettings _$SeatSettingsFromJson(Map<String, dynamic> json) => SeatSettings(
  autoHeatTime: (json['autoHeatTime'] as num).toInt(),
  autoHeatTempThreshold: (json['autoHeatTempThreshold'] as num).toInt(),
);

Map<String, dynamic> _$SeatSettingsToJson(SeatSettings instance) =>
    <String, dynamic>{
      'autoHeatTime': instance.autoHeatTime,
      'autoHeatTempThreshold': instance.autoHeatTempThreshold,

    };