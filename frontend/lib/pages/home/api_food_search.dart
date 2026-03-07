import 'package:flutter/material.dart';

import '../../API/api_food_model.dart';
import '../../API/api_service.dart';
import '../../utils/shared.dart';

class ApiFoodSearch extends StatefulWidget {
  final APIService apiService;

  const ApiFoodSearch({
    super.key,
    required this.apiService,
  });

  @override
  State<ApiFoodSearch> createState() => ApiFoodSearchState();
}

class ApiFoodSearchState extends State<ApiFoodSearch> {
  late final APIService apiService = APIService();

  final apiQueryController = TextEditingController();

  bool apiLoading = false;

  String? apiError;

  List<APIFood> apiFoodList = [];

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

  String format(double value) => value.toStringAsFixed(1);

  Widget foodCard(APIFood food) {
    return Card(
      elevation: 3,

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

            Text('Calories: ${format(food.calories)} kcal'),
            Text('Serving size: ${format(food.servingSizeG)} g'),
            Text('Protein: ${format(food.proteinG)} g'),
            Text('Fat: ${format(food.fatTotalG)} g'),
            Text('Carbs: ${format(food.carbohydratesTotalG)} g'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,

      padding: const EdgeInsets.all(20.0,),

      decoration: BoxDecoration(
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

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: apiQueryController,

                  decoration: const InputDecoration(
                    labelText: 'Írj be egy vagy több ételt (pl. "banana 100g")',

                    border: OutlineInputBorder(),
                  ),

                  onSubmitted: (_) => apiLoading ? null : searchFromApi(),
                ),
              ),

              const SizedBox(width: 10,),

              ElevatedButton(
                onPressed: apiLoading ? null : searchFromApi,

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

          if(!apiLoading && apiError == null && apiFoodList.isEmpty)
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
    );
  }
}