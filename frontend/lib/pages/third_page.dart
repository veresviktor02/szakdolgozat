import 'package:flutter/material.dart';

import '../food/food_model.dart';
import '../food/food_service.dart';

import '../utils/shared.dart';

class ThirdPage extends StatefulWidget {
  const ThirdPage({super.key});

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  final FoodService foodService = FoodService();

  late Future<List<Food>> foodFuture;

  @override
  void initState() {
    super.initState();

    refreshPage();
  }

  Future<void> refreshPage() async {
    setState(() {
      foodFuture = foodService.fetchFoods(1); //TODO: widget.userId
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Shared.myAppBar('Harmadik oldal',),

      backgroundColor: Colors.white,

      body: Padding(
        padding: const EdgeInsets.all(20.0,),

        child: Center(
          child: Column(
              children: [
                Text(
                  'Az ételeid:',

                  style: TextStyle(
                    fontSize: 24,

                    fontWeight: FontWeight.w400,
                  ),
                ),

                SizedBox(height: 20,),
                
                _futureFoodBuilder()
              ]
          ),
        ),
      ),
    );
  }

  Container _futureFoodBuilder() {
    return Container(
      padding: const EdgeInsets.all(20.0,),

      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
      ),

      child: FutureBuilder<List<Food>>(
        future: foodFuture,

        builder: (context, foodSnapshot) {
          //Várakozik a kapcsolatra
          if(foodSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Shared.myCircularProgressIndicator());
          }
          //Hiba történt
          else if(foodSnapshot.hasError) {
            return Text(
              'Hiba: ${foodSnapshot.error}',
              style: const TextStyle(color: Colors.red),
            );
          }
          //Nem üres a lista
          else if(foodSnapshot.data!.isNotEmpty) {
            return _foodColumn(foodSnapshot);
          }

          //Üres a lista
          return const Text('Nincs adat.',);
        },
      ),
    );
  }

  Column _foodColumn(AsyncSnapshot<List<Food>> foodSnapshot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: foodSnapshot.data!.map((food) {
        return SizedBox(
          width: 200,
          height: 200,

          child: Card(
            elevation: 3,

            margin: const EdgeInsets.symmetric(vertical: 8.0,),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0,),
            ),

            child: Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0,),

              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Név: ${food.name}',

                      style: const TextStyle(fontSize: 16),
                    ),

                    Text('ID: ${food.id}',),
                    Text('Kcal: ${food.kcalAndNutrients.kcal} kcal',),
                    Text('Zsír: ${food.kcalAndNutrients.fat} g',),
                    Text('Szénhidrát: ${food.kcalAndNutrients.carb} g',),
                    Text('Fehérje: ${food.kcalAndNutrients.protein} g',),

                    const SizedBox(height: 10,),

                    ElevatedButton(
                      onPressed: () async {
                        await foodService.deleteFood(food.id);

                        await refreshPage();
                      },

                      child: const Text('Törlés',),
                    ),
                  ],

                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

///////////////////////////////////////////////////////////////////////
////////////////////Itt ér véget a _ThirdPageState!////////////////////
///////////////////////////////////////////////////////////////////////
}