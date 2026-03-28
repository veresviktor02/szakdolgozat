import 'package:flutter/material.dart';

import '/user/user_model.dart';
import '/user/user_service.dart';

import '/food/food_model.dart';
import '/food/food_service.dart';

import '/utils/shared.dart';

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

    loadUser();
  }

  Future<void> loadUser() async {
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

      backgroundColor: Shared.backgroundColor,

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(100.0,),

            child: Align(
              alignment: AlignmentGeometry.center,

              child: FutureBuilder<Food>(
                future: getFoodById(),

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

                  return _displayFood(foodSnapshot.data!);
                },
              ),
            ),
          ),
        ]
      ),
    );
  }

  Widget _displayFood(Food food) {
    return Container(
      width: Shared.pageWidth,
      height: Shared.pageWidth,

      padding: const EdgeInsets.all(15.0,),

      decoration: BoxDecoration(
        color: Colors.greenAccent,

        border: Border.all(color: Colors.blueAccent,),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,

        children: [
          const Text(
            'Ételed:',

            style: TextStyle(
              fontSize: 20,

              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20,),

          _textField('Név', food.name,),
          _textField('Kcal', Shared.format(food.kcalAndNutrients.kcal),),
          _textField('Zsír', Shared.format(food.kcalAndNutrients.fat),),
          _textField('Szénhidrát', Shared.format(food.kcalAndNutrients.carb),),
          _textField('Fehérje', Shared.format(food.kcalAndNutrients.protein),),
        ],
      ),
    );
  }

  Future<Food> getFoodById() async {
    return await foodService.getFoodById(widget.userId, widget.foodId);
  }

  Widget _textField(label, foodElement) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 4.0,),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(
            '$label: ',

            style: textStyle(),
          ),

          Text(
            foodElement,

            style: textStyle(),
          ),
        ],
      ),
    );
  }
/////////////////////////////////////////////////////////////////////
////////////////////Itt ér véget a _FoodDataPage!////////////////////
/////////////////////////////////////////////////////////////////////
}

TextStyle textStyle() {
  return const TextStyle(
    fontSize: 18,

    fontWeight: FontWeight.w300,
  );
}