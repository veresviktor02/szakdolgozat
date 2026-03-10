import 'package:flutter/material.dart';

import '/user/user_model.dart';
import '/user/user_service.dart';

import '/food/food_model.dart';
import '/food/food_service.dart';

import '../utils/shared.dart';

//Ez az oldal arra szolgál, hogy egy adott étel adatait vizsgálhassuk meg.
class FoodDataPage extends StatefulWidget {
  //Ezt adta át az előző oldal!
  final int foodId;
  final int userId;

  const FoodDataPage({
    super.key,

    required this.foodId,
    required this.userId,
  });

  @override
  State<FoodDataPage> createState() => _FoodDataPageState();
}

class _FoodDataPageState extends State<FoodDataPage> {
  final UserService userService = UserService();
  final FoodService foodService = FoodService();

  User? user;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final loadedUser = await userService.getUserById(widget.userId);

      setState(() {
        user = loadedUser;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Nem sikerült betölteni a felhasználót: $error';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Shared.myAppBar('Étel adatlap',),

      backgroundColor: Colors.white,

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(100.0),

            child: Align(
              alignment: AlignmentGeometry.center,

              child: FutureBuilder<Food>(
                future: getFood(),

                builder: (context, foodSnapshot) {
                  if(foodSnapshot.connectionState == ConnectionState.waiting) {
                    return Shared.myCircularProgressIndicator();
                  }

                  if(foodSnapshot.hasError) {
                    return Text('Hiba történt: ${foodSnapshot.error}');
                  }

                  if(!foodSnapshot.hasData) {
                    return const Text('Nincs étel adat.');
                  }

                  return displayFood(foodSnapshot.data!);
                },
              ),
            ),
          ),
        ]
      ),
    );
  }

  Widget displayFood(Food food) {
    return Container(
      width: 300,
      height: 300,

      padding: EdgeInsets.all(15.0),

      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent,),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,

        children: [
          Text(
              'Ételed:',

            style: TextStyle(
              fontSize: 20,

              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 20,),

          _textField('ID', food.id.toString()),
          _textField('Név', food.name.toString()),
          _textField('Kcal', food.kcalAndNutrients.kcal.toString()),
          _textField('Fat', food.kcalAndNutrients.fat.toString()),
          _textField('Carb', food.kcalAndNutrients.carb.toString()),
          _textField('Protein', food.kcalAndNutrients.protein.toString()),
        ],
      ),
    );
  }

  Future<Food> getFood() async {
    return await foodService.getFoodById(widget.userId, widget.foodId);
  }

  Widget _textField(String label, String foodElement) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 4.0),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(
            '$label: ',

            style: TextStyle(
              fontSize: 16,

              fontWeight: FontWeight.w300
            ),
          ),

          Text(
            foodElement,

            style: TextStyle(
                fontSize: 16,

                fontWeight: FontWeight.w300
            ),
          ),
        ],
      ),
    );
  }

  /////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
}