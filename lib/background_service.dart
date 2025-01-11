// this will be used as notification channel id
import 'dart:async';
import 'dart:ui';
import 'package:android_automotive_plugin/android_automotive_plugin.dart';
import 'package:android_automotive_plugin/car/car_sensor_event.dart';
import 'package:android_automotive_plugin/car/car_sensor_types.dart';
import 'package:android_automotive_plugin/car/hvac_manager.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'automotive_store.dart';

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      iOS: DarwinInitializationSettings(),
      android: AndroidInitializationSettings('ic_bg_service_small'),
    ),
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      autoStartOnBoot: true,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'App Service',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
  );
}

late AndroidAutomotivePlugin _androidAutomotivePlugin;

Timer? _timerDriver;
Timer? _timerPassenger;

@pragma('vm:entry-point')
onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "App Service",
      content: "Updated at ${DateTime.now()}",
    );
  }

  _androidAutomotivePlugin = AndroidAutomotivePlugin();
  final completer = Completer();

  _androidAutomotivePlugin.onCarSensorEventCallback = _onCarSensorEvent;

  await _androidAutomotivePlugin.connect();
  await completer.future;
}

_onCarSensorEvent(CarSensorEvent carSensorEvent) async {
  try {
    if (carSensorEvent.sensorType ==
        CarSensorTypes.SENSOR_TYPE_IGNITION_STATE) {
      int ignitionState = carSensorEvent.intValues.first;
      bool ignitionOn = ignitionState == 4;

      if (ignitionOn) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        final driverSeatAutoHeatTime =
        SeatHeatTime.values[prefs.getInt('_driverSeatAutoHeatTime') ?? 0];
        final driverSeatAutoHeatTempThreshold = SeatHeatTempThreshold
            .values[prefs.getInt('_driverSeatAutoHeatTempThreshold') ?? 1];

        final passengerSeatAutoHeatTime = SeatHeatTime
            .values[prefs.getInt('_passengerSeatAutoHeatTime') ?? 0];
        final passengerSeatAutoHeatTempThreshold = SeatHeatTempThreshold
            .values[prefs.getInt('_passengerSeatAutoHeatTempThreshold') ?? 1];

        final hvacManager = CarHvacManager(_androidAutomotivePlugin);
        final temp = await hvacManager.getInsideTemperature();

        final insideTemp = (temp - 84) / 2;

        if (driverSeatAutoHeatTime != SeatHeatTime.off &&
            insideTemp < driverSeatAutoHeatTempThreshold.getTempInCelcius) {
          hvacManager.setSeatHeatLevel(true, 3);

          _timerDriver?.cancel();

          Timer(Duration(minutes: 5), () {
            hvacManager.setSeatHeatLevel(true, 1);
          });

          _timerDriver = Timer(
            Duration(minutes: driverSeatAutoHeatTime.getDurationInMinutes),
                () {
              hvacManager.setSeatHeatLevel(true, 0);
            },
          );
        }

        if (passengerSeatAutoHeatTime != SeatHeatTime.off &&
            insideTemp < passengerSeatAutoHeatTempThreshold.getTempInCelcius) {
          hvacManager.setSeatHeatLevel(false, 3);

          _timerPassenger?.cancel();

          Timer(Duration(minutes: 5), () {
            hvacManager.setSeatHeatLevel(false, 1);
          });

          _timerPassenger = Timer(
            Duration(minutes: passengerSeatAutoHeatTime.getDurationInMinutes),
                () {
              hvacManager.setSeatHeatLevel(false, 0);
            },
          );
        }
      } else {
        _timerDriver?.cancel();
        _timerPassenger?.cancel();
      }
    }
  } catch (e) {
    // Обработка ошибок без логирования
  }
}
