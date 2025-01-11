import 'package:changan_seat_heat/automotive_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';


class HomePage extends StatelessWidget {
  final AutomotiveStore store;

  const HomePage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontWeight: FontWeight.w400, fontSize: 24);
    const textStyle2 = TextStyle(fontWeight: FontWeight.w400, fontSize: 24);

    Widget buildChairSegment(bool isDriver, int seatHeatLevel,
        SeatHeatTime heatTime, SeatHeatTempThreshold heatThreshold) {
      const charColor = Colors.white10;

      final chairSegment = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Изменяем уровень нагрева от 0 до 3
                final newLevel = (seatHeatLevel + 1) % 4;
                store.setSeatHeatLevel(isDriver, newLevel);
              },
              borderRadius: BorderRadius.circular(12),
              splashColor: Colors.transparent, // Убираем красный цвет при нажатии
              highlightColor: Colors.transparent, // Убираем выделение при нажатии
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0), // Увеличение padding
                    child: Image.asset(
                      "assets/images/single_chair.png",
                      color: Colors.white, // Основное изображение кресла
                    ),
                  ),
                  // Уровни нагрева, смещенные вниз
                  if (seatHeatLevel == 1)
                    Positioned(
                      bottom: 100, // Отступ снизу, чтобы картинка была ближе к креслу
                      child: Image.asset("assets/images/chair_heat_level_one.png"),
                    ),
                  if (seatHeatLevel == 2)
                    Positioned(
                      bottom: 100, // Отступ снизу, чтобы картинка была ближе к креслу
                      child: Image.asset("assets/images/chair_heat_level_two.png"),
                    ),
                  if (seatHeatLevel == 3)
                    Positioned(
                      bottom: 100, // Отступ снизу, чтобы картинка была ближе к креслу
                      child: Image.asset("assets/images/chair_heat_level_three.png"),
                    ),
                  if (seatHeatLevel == 0)
                    Positioned(
                      bottom: 100, // Отступ снизу, чтобы картинка была ближе к креслу
                      child: Image.asset("assets/images/chair_level_off.png"),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Добавляем текст ниже изображения кресла
          Text(
            isDriver ? "Водитель" : "Пассажир",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ],
      );


      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [

          const SizedBox(height: 24),
          Row(
            children: [
              if (!isDriver) ...[
                chairSegment,
                const SizedBox(width: 22),
              ],
              Column(
                crossAxisAlignment: isDriver
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Время работы автоподогрева (минут)", style: textStyle2),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 500,
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 20.0, // Толщина трека
                            activeTrackColor: Colors.blue, // Цвет активной части трека
                            inactiveTrackColor: Colors.grey.shade300, // Цвет неактивной части
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12), // Размер бегунка
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20), // Размер тени вокруг бегунка
                            tickMarkShape: const RoundSliderTickMarkShape(), // Форма разделителей
                            activeTickMarkColor: Colors.blue, // Цвет активных разделителей
                            inactiveTickMarkColor: Colors.grey.shade500, // Цвет неактивных разделителей
                          ),
                          child: Slider(
                            value: heatTime.index.toDouble(),
                            min: 0,
                            max: 6,
                            divisions: 6, // Количество разделителей соответствует количеству опций
                            label: SeatHeatTime.values[heatTime.index]
                                .getDurationInMinutes
                                .toString(), // Подпись текущего значения
                            onChanged: (selection) {
                              final selectedTime = SeatHeatTime.values[selection.toInt()];
                              store.setSeatAutoHeatTime(isDriver, selectedTime);
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: SeatHeatTime.values.map((time) {
                            return Text(
                              time == SeatHeatTime.off
                                  ? "откл."
                                  : "${time.getDurationInMinutes} ",
                              style: textStyle2.copyWith(fontSize: 14), // Уменьшенный шрифт для подписей
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Text("Включать когда температура в салоне ниже (°C)", style: textStyle2),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 500,
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 20.0, // Толщина трека
                            activeTrackColor: Colors.red, // Цвет активной части трека
                            inactiveTrackColor: Colors.grey.shade300, // Цвет неактивной части
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12), // Размер бегунка
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20), // Размер тени вокруг бегунка
                            tickMarkShape: const RoundSliderTickMarkShape(), // Форма разделителей
                            activeTickMarkColor: Colors.red, // Цвет активных разделителей
                            inactiveTickMarkColor: Colors.grey.shade500, // Цвет неактивных разделителей
                          ),
                          child: Slider(
                            value: heatThreshold.index.toDouble(),
                            min: 0,
                            max: 5,
                            divisions: 5, // Количество разделителей
                            label: SeatHeatTempThreshold.values[heatThreshold.index].getTempInCelcius.toString(),
                            onChanged: heatTime == SeatHeatTime.off
                                ? null
                                : (value) {
                              final selectedThreshold = SeatHeatTempThreshold.values[value.toInt()];
                              store.setSeatAutoHeatTempTheshold(isDriver, selectedThreshold);
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: SeatHeatTempThreshold.values.map((threshold) {
                            return Text(
                              "${threshold.getTempInCelcius}",
                              style: textStyle2.copyWith(fontSize: 14), // Уменьшенный шрифт для подписей
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
              if (isDriver) ...[
                const SizedBox(width: 72),
                chairSegment,
              ],
            ],
          ),
        ],
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Observer(
              builder: (ctx) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 40),
                  const Spacer(),
                  const Text("ЗАЖИГАНИЕ", style: textStyle),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.circle_rounded,
                    color: store.ignitionOn ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 32),
                  Text(
                      "ТЕМПЕРАТУРА В САЛОНЕ ${store.insideTemp == null ? "--" : store.insideTemp!}°C",
                      style: textStyle),
                  const Spacer(),

                 // const SizedBox(width: 16),

                 // const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Observer(
                      builder: (context) => buildChairSegment(
                        true,
                        store.driverSeatHeatLevel,
                        store.driverSeatAutoHeatTime,
                        store.driverSeatAutoHeatTempThreshold,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(
                      height: 300,
                      child: VerticalDivider(),
                    ),
                    const Spacer(),
                    Observer(
                      builder: (context) => buildChairSegment(
                        false,
                        store.passengerSeatHeatLevel,
                        store.passengerSeatAutoHeatTime,
                        store.passengerSeatAutoHeatTempThreshold,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
