import 'dart:async';
import 'package:android_automotive_plugin/android_automotive_plugin.dart';
import 'package:android_automotive_plugin/car/car_property_value.dart';
import 'package:android_automotive_plugin/car/car_sensor_event.dart';
import 'package:android_automotive_plugin/car/car_sensor_types.dart';
import 'package:android_automotive_plugin/car/hvac_manager.dart';
import 'package:android_automotive_plugin/car/sensor_manager.dart';

import 'package:android_automotive_plugin/car/vehicle_area_seat.dart';
import 'package:android_automotive_plugin/car/vehicle_property_ids.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'automotive_store.g.dart';

enum SeatHeatTime {
  off,
  short,
  short1,
  medium,
  medium1,
  long,
  long1,
}

extension SeatHeatTimeDuration on SeatHeatTime {
  int get getDurationInMinutes {
    switch (this) {
      case SeatHeatTime.off:
        return 0;
      case SeatHeatTime.short:
        return 5;
      case SeatHeatTime.short1:
        return 10;
      case SeatHeatTime.medium:
        return 15;
      case SeatHeatTime.medium1:
        return 20;
      case SeatHeatTime.long:
        return 25;
      case SeatHeatTime.long1:
        return 30;
    }
  }
}

enum SeatHeatTempThreshold {
  low,
  low1,
  medium,
  medium1,
  high,
  high1,
}

extension SeatHeatTempThresholdTemp on SeatHeatTempThreshold {
  int get getTempInCelcius {
    switch (this) {
      case SeatHeatTempThreshold.low:
        return 0;
      case SeatHeatTempThreshold.low1:
        return 5;
      case SeatHeatTempThreshold.medium:
        return 10;
      case SeatHeatTempThreshold.medium1:
        return 15;
      case SeatHeatTempThreshold.high:
        return 20;
      case SeatHeatTempThreshold.high1:
        return 25;
    }
  }
}

class AutomotiveStore = AutomotiveStoreBase with _$AutomotiveStore;

abstract class AutomotiveStoreBase with Store {
  late final AndroidAutomotivePlugin _androidAutomotivePlugin;
  late final CarHvacManager _carHvacManager;
  late final CarSensorManager _carSensorManager;
  static const int _InOutCAR_INSIDE = 1;/////
  AutomotiveStoreBase() {
    _loadSettings().whenComplete(() async {
      _androidAutomotivePlugin = AndroidAutomotivePlugin();
      _carHvacManager = CarHvacManager(_androidAutomotivePlugin);
      _carSensorManager = CarSensorManager(_androidAutomotivePlugin);
      _androidAutomotivePlugin.onHvacChangeEventCallback = _onHvacChangeEvent;
      _androidAutomotivePlugin.onCarSensorEventCallback = _onCarSensorEvent;

      try {
        await _androidAutomotivePlugin.connect();

        int ignitionState = await _carSensorManager.getIgnitionState();
        _ignitionOn = ignitionState == 4;
      } catch (e) {
        // Handle connection errors if necessary
      }
    });
  }

  @readonly
  bool _ignitionOn = false;

  @readonly
  double? _insideTemp;

  @readonly
  int _driverSeatHeatLevel = 0;

  @readonly
  SeatHeatTime _driverSeatAutoHeatTime = SeatHeatTime.off;

  @readonly
  SeatHeatTempThreshold _driverSeatAutoHeatTempThreshold =
      SeatHeatTempThreshold.medium;

  @readonly
  int _passengerSeatHeatLevel = 0;

  @readonly
  SeatHeatTime _passengerSeatAutoHeatTime = SeatHeatTime.off;

  @readonly
  SeatHeatTempThreshold _passengerSeatAutoHeatTempThreshold =
      SeatHeatTempThreshold.medium;

  @action
  void setSeatHeatLevel(bool isDriverSeat, int level) {
    _carHvacManager.setSeatHeatLevel(isDriverSeat, level);

    if (isDriverSeat) {
      _driverSeatHeatLevel = level;
    } else {
      _passengerSeatHeatLevel = level;
    }
  }

  @action
  void setSeatAutoHeatTime(bool isDriverSeat, SeatHeatTime time) {
    if (isDriverSeat) {
      _driverSeatAutoHeatTime = time;
    } else {
      _passengerSeatAutoHeatTime = time;
    }

    _saveSettings();
  }

  @action
  void setSeatAutoHeatTempTheshold(
      bool isDriverSeat, SeatHeatTempThreshold temp) {
    if (isDriverSeat) {
      _driverSeatAutoHeatTempThreshold = temp;
    } else {
      _passengerSeatAutoHeatTempThreshold = temp;
    }

    _saveSettings();
  }

  //////////////////////////////

  _onCarSensorEvent(CarSensorEvent carSensorEvent) {
    if (carSensorEvent.sensorType ==
        CarSensorTypes.SENSOR_TYPE_IGNITION_STATE) {
      int ignitionState = carSensorEvent.intValues.first;
      _ignitionOn = ignitionState == 4;
    }
  }

  _onHvacChangeEvent(CarPropertyValue carPropertyValue) async {
    try {
      if (carPropertyValue.propertyId ==675289370) {
        if (carPropertyValue.areaId == _InOutCAR_INSIDE) {
          _insideTemp =
              ((double.tryParse(carPropertyValue.value) ?? 0) - 84) / 2;
        }
      } else if (carPropertyValue.propertyId ==
          VehiclePropertyIds.HVAC_SEAT_TEMPERATURE) {
        if (carPropertyValue.areaId == VehicleAreaSeat.SEAT_MAIN_DRIVER) {
          _driverSeatHeatLevel = int.tryParse(carPropertyValue.value) ?? 0;
        } else if (carPropertyValue.areaId == VehicleAreaSeat.SEAT_PASSENGER) {
          _passengerSeatHeatLevel = int.tryParse(carPropertyValue.value) ?? 0;
        }
      }
    } catch (e) {
      // Handle errors if necessary
    }
  }



  //////////////////////////////

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    _driverSeatAutoHeatTime =
    SeatHeatTime.values[prefs.getInt('_driverSeatAutoHeatTime') ?? 0];
    _driverSeatAutoHeatTempThreshold = SeatHeatTempThreshold
        .values[prefs.getInt('_driverSeatAutoHeatTempThreshold') ?? 1];

    _passengerSeatAutoHeatTime =
    SeatHeatTime.values[prefs.getInt('_passengerSeatAutoHeatTime') ?? 0];
    _passengerSeatAutoHeatTempThreshold = SeatHeatTempThreshold
        .values[prefs.getInt('_passengerSeatAutoHeatTempThreshold') ?? 1];
  }

  Future<void> _saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
        '_driverSeatAutoHeatTime', _driverSeatAutoHeatTime.index);
    await prefs.setInt('_driverSeatAutoHeatTempThreshold',
        _driverSeatAutoHeatTempThreshold.index);

    await prefs.setInt(
        '_passengerSeatAutoHeatTime', _passengerSeatAutoHeatTime.index);
    await prefs.setInt('_passengerSeatAutoHeatTempThreshold',
        _passengerSeatAutoHeatTempThreshold.index);
  }
}
