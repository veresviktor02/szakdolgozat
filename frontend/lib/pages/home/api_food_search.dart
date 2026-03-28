import 'package:flutter/material.dart';

import '/day/day_service.dart';
import '/day/measurement_unit/measurement_unit_model.dart';

import '/food/kcal_and_nutrients_model.dart';

import '/API/api_food_model.dart';
import '/API/api_service.dart';

import '/utils/my_calendar.dart';
import '/utils/shared.dart';

class ApiFoodSearch extends StatefulWidget {
  final DayService dayService;
  final int userId;
  final MyCalendar myCalendar;

  final Future<void> Function()? onRefresh;

  const ApiFoodSearch({
    super.key,

    required this.dayService,
    required this.userId,
    required this.myCalendar,
    required this.onRefresh,
  });

  @override
  State<ApiFoodSearch> createState() => ApiFoodSearchState();
}

class ApiFoodSearchState extends State<ApiFoodSearch> {
  late final APIService apiService = APIService();
  late final DayService dayService = DayService();
  late final int userId = widget.userId;
  late final MyCalendar myCalendar = widget.myCalendar;

  final apiQueryController = TextEditingController();

  bool apiLoading = false;

  String? apiError;

  List<APIFood> apiFoodList = [];

  bool startedSearching = false;

  @override
  void dispose() {
    apiQueryController.dispose();

    super.dispose();
  }

  Future<void> searchFromApi() async {
    final query = apiQueryController.text.trim();

    if(query.isEmpty) {
      Shared.mySnackBar(
        'Üres a keresési mező!',
        Colors.red,
        context,
      );

      return;
    }

    setState(() {
      apiLoading = true;

      apiError = null;

      apiFoodList = [];
    });

    try {
      final response = await apiService.fetchNutritions(query);

      setState(() {
        apiFoodList = response.items;
      });

    } catch(error) {
      setState(() {
        apiError = error.toString();
      });
    } finally {
      setState(() {
        apiLoading = false;
      });
    }
  }

  Widget foodCard(APIFood food) {
    return Card(
      color: Colors.lightGreenAccent,
      shadowColor: Colors.greenAccent,

      elevation: 8,

      margin: const EdgeInsets.symmetric(vertical: 8.0,),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0,),),

      child: Padding(
        padding: const EdgeInsets.all(12.0,),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              food.name,

              style: const TextStyle(
                fontSize: 16,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10,),

            Text('Kalória: ${Shared.format(food.calories)} kcal',),
            Text('Zsír: ${Shared.format(food.fatTotalG)} g',),
            Text('Szénhidrát: ${Shared.format(food.carbohydratesTotalG)} g',),
            Text('Fehérje: ${Shared.format(food.proteinG)} g',),
            Text('Tömeg: ${Shared.format(food.servingSizeG)} g',),

            ElevatedButton(
                onPressed: () async {
                  addFoodToDay(food);

                  await widget.onRefresh?.call();
                },

                style: Shared.myButtonStyle,

                child: Text('Hozzáadás a naphoz',),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addFoodToDay(APIFood food) async {
    var checkedCalories = food.calories;
    var calculatedCaloriesFromNutrients = food.fatTotalG * 9 + food.carbohydratesTotalG * 4 + food.proteinG * 4;

    if(food.calories < calculatedCaloriesFromNutrients) {
      Shared.mySnackBar(
          'Az API által megadott kalóriaszám hibás! A naptáradba a helyes kalóriaszám kerül be. ',
          Colors.blue,
          context,
      );

      checkedCalories = calculatedCaloriesFromNutrients;
    }

    dayService.addFoodToDay(
      userId,
      myCalendar.daysMap[myCalendar.dayOnly(myCalendar.selectedDay)]!.id,
      food.name,
      KcalAndNutrients(
        kcal: checkedCalories,
        fat: food.fatTotalG,
        carb: food.carbohydratesTotalG,
        protein: food.proteinG,
      ),
      food.servingSizeG,
      MeasurementUnit(
        id: 1,
        measurementUnitName: 'Gramm',
        measurementUnitInGrams: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: Shared.pageWidth,

        padding: const EdgeInsets.all(20.0,),

        decoration: BoxDecoration(
          color: Shared.boxDecorationColor,

          border: Border.all(color: Colors.blueAccent,),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'CalorieNinjas API ételkeresés',

              style: TextStyle(
                fontSize: 16,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10,),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: apiQueryController,

                    decoration: Shared.inputDecoration(
                      'Írj be egy vagy több ételt (pl. "100g banana")',
                      null,
                    ),

                    onSubmitted: (_) => apiLoading ? null : searchFromApi(),
                  ),
                ),

                const SizedBox(width: 10,),

                ElevatedButton(
                  onPressed: apiLoading ? null : () {
                    searchFromApi();

                    startedSearching = true;
                  },

                  style: Shared.myButtonStyle,

                  child: const Text('Keresés',),
                ),
              ],
            ),

            const SizedBox(height: 10,),

            if(apiLoading)
              Center(child: Shared.myCircularProgressIndicator(),),

            if(!apiLoading && apiError != null)
              Text(
                'Hiba: $apiError',

                style: const TextStyle(color: Colors.red,),
              ),

            if(!apiLoading
                && apiError == null
                && apiFoodList.isEmpty
                && startedSearching
            )
              const Text(
                'Nincs találat!',

                style: TextStyle(fontSize: 16,),
              ),

            if(apiFoodList.isNotEmpty) ...[
              const SizedBox(height: 10,),

              ListView.builder(
                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                itemCount: apiFoodList.length,

                itemBuilder: (context, index) => foodCard(apiFoodList[index]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}