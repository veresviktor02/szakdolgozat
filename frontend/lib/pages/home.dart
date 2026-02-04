import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:table_calendar/table_calendar.dart';

import '../day/day_model.dart';
import '../day/day_service.dart';

import '../food/food_model.dart';
import '../food/food_service.dart';
import '../food/kcal_and_nutrients_model.dart';

import '../my_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FoodService foodService = FoodService();
  final DayService dayService = DayService();

  final MyCalendar myCalendar = MyCalendar();

  late Future<List<Food>> foodFuture;
  late Future<List<Day>> dayFuture;

  //Beviteli mezők
  final nameController = TextEditingController();
  final kcalController = TextEditingController();
  final fatController = TextEditingController();
  final carbController = TextEditingController();
  final proteinController = TextEditingController();
  //

  @override
  void initState() {
    super.initState();

    foodFuture = foodService.fetchFoods();
    dayFuture = dayService.fetchDays();

    dayFuture.then((days) {
      setState(() {
        for (final day in days) {
          myCalendar.daysMap[myCalendar.dayOnly(day.date)] = day;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar(),

      backgroundColor: Colors.white,

      body: SizedBox(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          
            children: [
              _calendar(myCalendar, setState),

              const SizedBox(height: 5,),

              _navigateToSecondPage(context),

              const SizedBox(height: 5,),

              _navigateToThirdPage(context),
          
              const SizedBox(height: 5,),
          
              _futureFoodBuilder(foodFuture),
          
              const SizedBox(height: 20,),
          
              _futureDayBuilder(dayFuture),
          
              const SizedBox(height: 20,),
          
              _dataSenderContainer(
                nameController,
                kcalController,
                fatController,
                carbController,
                proteinController,
                foodService
              ),
          
              const SizedBox(height: 20,),
          
            ],
          ),
        ),
      ),
    );
  }


}

Container _calendar(MyCalendar myCalendar, void Function(VoidCallback) setState) {
  return Container(
    alignment: Alignment.center,

    child: SizedBox(
      width: 600,
      //height: 300,

      child: Column(
        children: [
          TableCalendar(
            //TODO: magyar napok nevei!
            firstDay: DateTime(2024, 1, 1),
            lastDay: DateTime(2027, 12, 31),
            focusedDay: myCalendar.focusedDay,

            //default: Vasárnap!
            startingDayOfWeek: StartingDayOfWeek.monday,

            selectedDayPredicate: (day) {
              return isSameDay(myCalendar.selectedDay, day);
            },

            eventLoader: (day) {
              return myCalendar.daysMap[myCalendar.dayOnly(day)]?.foodList ?? [];
            },

            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                myCalendar.selectedDay = selectedDay;
                myCalendar.focusedDay = focusedDay;
              });
            },

            calendarFormat: myCalendar.calendarFormat,

            //Eltűnik a választó!
            availableCalendarFormats: const {
              CalendarFormat.week: 'Hét',
            },


          ),

          _dayDetails(myCalendar.selectedFoods, myCalendar.selectedDay),
        ],
      ),
    ),
  );
}

Widget _dayDetails(List<Food> selectedFoods, DateTime? selectedDay) {
  late List<Food> lateSelectedFoods = selectedFoods;

  //Nincs kiválasztva (fókuszban) nap
  if (selectedDay == null) {
    return const Center(child: Text('Válassz ki egy napot! (selectedDay == null)'));
  }

  //Nincs étel a napban
  if (lateSelectedFoods.isEmpty) {
    return const Center(child: Text('A napod üres! (lateSelectedFoods.isEmpty == true)'));
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,

    children: [
      ListView.builder(
        shrinkWrap: true,
        itemCount: lateSelectedFoods.length,

        itemBuilder: (context, index) {
          final food = lateSelectedFoods[index];

          return Card(
            color: Colors.blue,
            shadowColor: Colors.greenAccent,
            elevation: 8,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                Text('Név: ${food.name}'),
                Text('Kcal: ${food.kcalAndNutrients.kcal}'),
                Text('Zsír: ${food.kcalAndNutrients.fat}'),
                Text('Szénhidrát: ${food.kcalAndNutrients.carb}'),
                Text('Fehérje: ${food.kcalAndNutrients.protein}'),
              ],
            ),
          );
        },
      ),
    ],
  );
}

Container _dataSenderContainer(
    TextEditingController nameController,
    TextEditingController kcalController,
    TextEditingController fatController,
    TextEditingController carbController,
    TextEditingController proteinController,
    FoodService foodService
    ) {
  return Container(
      padding: const EdgeInsets.all(20),

      child: Column(
        children: [
          Row(
            children: [
              Text('Add meg a bevinni kívánt adatokat!'),
            ],
          ),

          const SizedBox(height: 20,),

          _nameTextField(nameController),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,

            children: [
              _textFieldColumn('Kcal', kcalController), //TODO: Más legyen ez a mező (style)!!!
              _textFieldColumn('Fat', fatController),
              _textFieldColumn('Carb', carbController),
              _textFieldColumn('Protein', proteinController),
            ],
          ),

          Container(
            alignment: Alignment.centerLeft,

            child: ElevatedButton(
              onPressed: () async {

                foodService.sendFood(
                  nameController.text,
                  KcalAndNutrients(
                    kcal: double.parse(kcalController.text),
                    fat: double.parse(fatController.text),
                    carb: double.parse(carbController.text),
                    protein: double.parse(proteinController.text),
                  ),
                );

                print('Gomb lenyomva!');

              },
              style: ButtonStyle(
                //TODO: style
              ),

              child: Text('Kattints ide a küldéshez!'),
            ),
          ),

        ],
      )
  );
}

Container _nameTextField(TextEditingController nameController) {
  return Container(
    alignment: Alignment.topLeft,

    child: SizedBox(
      width: 400,

      child: TextField(
        controller: nameController,

        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.all(15),
          hintText: 'Étel neve:',

          hintStyle: TextStyle(
            color: Color(0xffDDDADA),
            fontSize: 14,
          ),

        ),
      ),
    ),
  );
}

Column _textFieldColumn(String textData, TextEditingController controller) {
  return Column(
    children: [
      SizedBox(
        width: 60, //Ugyanannyi, mint alatta a TextField körüli SizedBox-é!!!

        child: Text(
          textData,
          textAlign: TextAlign.center,
        ),

      ),

      const SizedBox(height: 5,),

      SizedBox(
        width: 60,
        height: 100,

        child: TextField(
          controller: controller,

          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d\.]')),
          ],

          keyboardType: TextInputType.number,

          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.all(15),

            hintText: '0',
            hintStyle: TextStyle(
              color: Color(0xffDDDADA),
              fontSize: 14,
            ),
          ),

        ),

      ),
    ],
  );
}

Container _futureFoodSender() {
  return Container(
    //TODO: Ha kész az adatküldés, akkor áthelyezni ide!!!
  );
}

Container _futureFoodBuilder(Future<List<Food>> foodFuture) {
  return Container(
    padding: const EdgeInsets.all(20),

    child: FutureBuilder<List<Food>>(
      future: foodFuture,

      builder: (context, foodSnapshot) {
        //Várakozik a kapcsolatra
        if(foodSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
        return const Text('Nincs adat.');
      },
    ),
  );
}

Column _foodColumn(AsyncSnapshot<List<Food>> foodSnapshot) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,

    children: foodSnapshot.data!.map(
            (food) {
        return SizedBox(
          width: 180,
          height: 180,

          child: Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),

            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    'Név: ${food.name}',
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 5,),

                  Text('Kcal: ${food.kcalAndNutrients.kcal} kcal'),
                  Text('Zsír: ${food.kcalAndNutrients.fat} g'),
                  Text('Szénhidrát: ${food.kcalAndNutrients.carb} g'),
                  Text('Fehérje: ${food.kcalAndNutrients.protein} g'),
                ],

              ),
            ),
          ),
        );
      }).toList(),
  );
}

Container _futureDayBuilder(Future<List<Day>> dayFuture) {
  return Container(
    padding: const EdgeInsets.all(20),

    child: FutureBuilder<List<Day>>(
      future: dayFuture,

      builder: (context, daySnapshot) {
        //Várakozik a kapcsolatra
        if(daySnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        //Hiba történt
        else if(daySnapshot.hasError) {
          return Text(
            'Hiba: ${daySnapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }
        //Nem üres a lista
        else if(daySnapshot.data!.isNotEmpty) {
          return _dayColumn(daySnapshot);
        }

        //Üres a lista
        return const Text('Nincs adat.');
      },
    ),
  );
}

Column _dayColumn(AsyncSnapshot<List<Day>> daySnapshot) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,

    children: daySnapshot.data!.map(
            (day) {
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  style: const TextStyle(fontSize: 16),

                  //TODO: Egyszámjegyű hónapot és napot kétszámjegyűvé konvertálni!
                  'Dátum: ${day.date.year}-${day.date.month}-${day.date.day}',
                ),

                const SizedBox(height: 5,),

                Text('Ételek:'),

                ListView.builder(
                  shrinkWrap: true,
                  itemCount: day.foodList.length,

                  itemBuilder: (context, index) {
                    final food = day.foodList[index];

                    return Column(
                      //Itt bent elveszik a külső Column crossAxisAlignment-je!
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text('Név: ${food.name}'),
                        Text('Kcal: ${food.kcalAndNutrients.kcal}'),
                        Text('Zsír: ${food.kcalAndNutrients.fat}'),
                        Text('Szénhidrát: ${food.kcalAndNutrients.carb}'),
                        Text('Fehérje: ${food.kcalAndNutrients.protein}'),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
  );
}

ElevatedButton _navigateToSecondPage(BuildContext context) {
  return ElevatedButton(
      onPressed: () {
        print('Gomb lenyomva! (2. oldal gombja)');

        Navigator.of(context).pushNamed(
          '/second',
          arguments: 'Hello',
          //arguments: '12', -> Error oldal!
        );

      },

      child:
      Text('2. oldal')
  );
}

ElevatedButton _navigateToThirdPage(BuildContext context) {
  return ElevatedButton(
      onPressed: () {
        print('Gomb lenyomva! (3. oldal gombja)');

        Navigator.of(context).pushNamed(
          '/third',
        );

      },

      child:
      Text('3. oldal')
  );
}

AppBar _appbar() {
  return AppBar(

    title: Text(
      'Kalóriaszámláló alkalmazás',

      style: TextStyle(
        color: Colors.red,
        fontSize: 34,
        fontWeight: FontWeight.bold,
      ),

    ),

    backgroundColor: Colors.green,
    elevation: 0.0,
    centerTitle: true,
  );
}