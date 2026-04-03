import 'package:flutter/material.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '/food/kcal_and_nutrients_model.dart';

import '/utils/shared.dart';

class DailyTarget extends StatelessWidget {
  final KcalAndNutrients dailyTargetForSelectedDay;
  final Future<KcalAndNutrients>? totalFuture;

  const DailyTarget({
    super.key,

    required this.dailyTargetForSelectedDay,
    required this.totalFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: Shared.pageWidth,
        height: 400,

        decoration: BoxDecoration(
          color: Shared.boxDecorationColor,

          border: Border.all(color: Colors.blueAccent,),
        ),

        child: _percentIndicators(),
      ),
    );
  }

  Widget _percentIndicators() {
    return FutureBuilder<KcalAndNutrients>(
      future: totalFuture,

      builder: (context, totalSnapshot) {
        if(totalFuture == null || totalSnapshot.connectionState == ConnectionState.waiting) {
          //Skeleton a programnak!
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              CircularPercentIndicator(
                radius: 100,
                lineWidth: 15,
                percent: 0,
                backgroundColor: Shared.circularPercentIndicatorBackgroundColor,
              ),

              const SizedBox(height: 30,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: [
                  _nutrients('Zsír', 0, 100, Colors.orange),

                  _nutrients('Szénhidrát', 0, 100, Colors.cyanAccent),

                  _nutrients('Fehérje', 0, 100, Colors.brown),
                ],
              ),
            ],
          );
        }
        if(totalSnapshot.hasError) {
          return Text('Hiba: ${totalSnapshot.error}',);
        }
        if(!totalSnapshot.hasData) {
          return const Text('Nincs adat.',);
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            CircularPercentIndicator(
              //Enélkül nem az animationDuration alatt rajzolná ki a kört, hanem egyből!
              key: const ValueKey('kcal_indicator'),

              radius: 100,
              lineWidth: 15,
              percent: (totalSnapshot.data!.kcal / dailyTargetForSelectedDay.kcal).clamp(0.0, 1.0),

              animation: true,
              animationDuration: Shared.animationDuration,

              backgroundColor: Shared.circularPercentIndicatorBackgroundColor,
              progressColor: progressColor(totalSnapshot),

              circularStrokeCap: CircularStrokeCap.round,

              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Text(
                    Shared.format(totalSnapshot.data!.kcal),

                    style: const TextStyle(
                      fontSize: 32,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Text(
                    'Kcal',

                    style: TextStyle(fontSize: 20,),
                  ),

                  Text(
                    Shared.format(totalSnapshot.data!.kcal - dailyTargetForSelectedDay.kcal),

                    style: TextStyle(
                      fontSize: 17,

                      color: progressColor(totalSnapshot),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                _nutrients(
                    'Zsír',
                    totalSnapshot.data!.fat,
                    dailyTargetForSelectedDay.fat,
                    Colors.orange,
                ),

                _nutrients(
                    'Szénhidrát',
                    totalSnapshot.data!.carb,
                    dailyTargetForSelectedDay.carb,
                    Colors.cyanAccent,
                ),

                _nutrients(
                    'Fehérje',
                    totalSnapshot.data!.protein,
                    dailyTargetForSelectedDay.protein,
                    Colors.brown,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _nutrients(text, totalSnapshotNutrient, dailyTargetNutrient, color) {
    return Column(
      children: [
        Text(
          text,

          style: const TextStyle(
            fontSize: 18,

            fontWeight: FontWeight.w400,
          ),
        ),

        Text(
          '${Shared.format(totalSnapshotNutrient)} g / $dailyTargetNutrient g',

          style: const TextStyle(fontSize: 17,),
        ),

        const SizedBox(height: 5,),

        LinearPercentIndicator(
          padding: EdgeInsets.zero,

          width: 150.0,
          lineHeight: 20.0,

          progressColor: color,
          backgroundColor: Colors.grey.shade300,

          percent: (totalSnapshotNutrient / dailyTargetNutrient).clamp(0.0, 1.0),

          animation: true,
          animationDuration: Shared.animationDuration,
        ),
      ],
    );
  }

  Color progressColor(AsyncSnapshot<KcalAndNutrients> totalSnapshot) {
    //A célon belül van a felhasználó.
    if(totalSnapshot.data!.kcal <= dailyTargetForSelectedDay.kcal) {
      return Colors.green;
    }
    //20%-os túllépés.
    else if(totalSnapshot.data!.kcal <= dailyTargetForSelectedDay.kcal * 1.2) {
      return Colors.yellowAccent;
    }
    //40%-os túllépés
    else if(totalSnapshot.data!.kcal <= dailyTargetForSelectedDay.kcal * 1.4) {
      return Colors.orange;
    }
    //Több, mint 40%-os túllépés
    return Colors.red;
  }
}