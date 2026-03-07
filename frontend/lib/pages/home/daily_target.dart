import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../food/kcal_and_nutrients_model.dart';

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
        width: 500,
        height: 500,

        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent,),
        ),

        child: Column(
          children: [
            Text(
              'Napi cél:',

              style: TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 10,),

            Text('${dailyTargetForSelectedDay.kcal} Kcal',),
            Text('${dailyTargetForSelectedDay.fat} g Zsír',),
            Text('${dailyTargetForSelectedDay.carb} g Szénhidrát',),
            Text('${dailyTargetForSelectedDay.protein} g Fehérje',),

            const SizedBox(height: 10,),

            _circularPercentIndicator(),

          ],
        ),
      ),
    );
  }

  Widget _circularPercentIndicator() {
    return FutureBuilder<KcalAndNutrients>(
      future: totalFuture,

      builder: (context, totalSnapshot) {
        if(totalFuture == null || totalSnapshot.connectionState == ConnectionState.waiting) {
          //Ideiglenes CircularPercentIndicator, amíg betölt / értéket kap a totalFuture!
          return CircularPercentIndicator(
            radius: 100,
            lineWidth: 15,
            percent: 0,

            backgroundColor: Colors.grey.shade300,
          );
        }
        else if(totalSnapshot.hasError) {
          return Text('Hiba: ${totalSnapshot.error}',);
        }
        else if(!totalSnapshot.hasData) {
          return const Text('Nincs adat.',);
        }

        return CircularPercentIndicator(
          //Enélkül nem az animationDuration alatt rajzolná ki a kört, hanem egyből!
          key: const ValueKey('kcal_indicator'),

          radius: 100,
          lineWidth: 15,
          percent: (totalSnapshot.data!.kcal / dailyTargetForSelectedDay.kcal).clamp(0.0, 1.0),

          animation: true,
          //1000 = 1 sec
          animationDuration: 800,

          backgroundColor: Colors.grey.shade300,
          progressColor: progressColor(totalSnapshot),

          circularStrokeCap: CircularStrokeCap.round,

          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Text(
                totalSnapshot.data!.kcal.toString(),

                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Text('Kcal',),

              Text(
                '${(
                    (totalSnapshot.data!.kcal / dailyTargetForSelectedDay.kcal) * 100
                ).toStringAsFixed(1)} %',
                style: TextStyle(
                  color: progressColor(totalSnapshot),
                ),
              ),

              Text(
                '${totalSnapshot.data!.kcal - dailyTargetForSelectedDay.kcal}',
                style: TextStyle(
                  color: progressColor(totalSnapshot),
                ),
              ),
            ],
          ),
        );
      },
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