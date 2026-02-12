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
  Future<KcalAndNutrients>? totalFuture;

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
    refreshPage();

    //Ez a kettő azért kell ide, mert rövid időre Error lenne nélküle!
    foodFuture = foodService.fetchFoods();
    dayFuture = dayService.fetchDays();
  }

  Future<void> refreshPage() async {
    final days = await dayService.fetchDays();

    setState(() {
      foodFuture = foodService.fetchFoods();
      dayFuture = dayService.fetchDays();

      myCalendar.daysMap.clear();

      for(final day in days) {
        myCalendar.daysMap[myCalendar.dayOnly(day.date)] = day;
      }

      final today = myCalendar.daysMap[myCalendar.dayOnly(DateTime.now())];

      totalFuture = dayService.getTotalKcalAndNutrients(today!.id);
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
              _calendar(),

              const SizedBox(height: 5,),

              _dailyInfos(),

              const SizedBox(height: 5,),

              _navigateToSecondPage(context),

              const SizedBox(height: 5,),

              _navigateToThirdPage(context),
          
              const SizedBox(height: 5,),
          
              _futureFoodBuilder(foodFuture),
          
              const SizedBox(height: 20,),
          
              _futureDayBuilder(dayFuture),
          
              const SizedBox(height: 20,),
          
              _dataSenderContainer(),
          
              const SizedBox(height: 20,),
          
            ],
          ),
        ),
      ),
    );
  }

  Container _calendar() {
    return Container(
      alignment: Alignment.center,

      child: SizedBox(
        width: 600,
        //TODO: Megcsinálni a magasságot!
        height: 500,

        child: Column(
          children: [
            TableCalendar(
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,

              //Hónapok testreszabása
              titleTextFormatter: (date, locale) => _hungarianNameOfMonths(date),

            ),

              //Hét napjainak testreszabása
              calendarBuilders: CalendarBuilders(
                dowBuilder: (context, day) => _hungarianNameOfDays(day),
              ),

              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),

                selectedDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),

                //weekendTextStyle: const TextStyle(color: Colors.blue),
                defaultTextStyle: const TextStyle(color: Colors.black),

                outsideTextStyle: TextStyle(color: Colors.grey.shade400),
              ),

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

            _dayDetails(),
          ],
        ),
      ),
    );
  }

  Future<void> sendFood() async {
    await foodService.sendFood(
      nameController.text,

      KcalAndNutrients(
        kcal: double.parse(kcalController.text),
        fat: double.parse(fatController.text),
        carb: double.parse(carbController.text),
        protein: double.parse(proteinController.text),
      ),
    );
  }


  Container _dataSenderContainer() {
    return Container(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            Row(
              children: [
                const Text('Add meg a bevinni kívánt adatokat!'),
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
                onPressed: () {
                  sendFood();
                  refreshPage();
                },
                style: ButtonStyle(
                  //TODO: style
                ),

                child: const Text('Kattints ide a küldéshez!'),
              ),
            ),

          ],
        )
    );
  }

  Widget _dayDetails() {
    //Nincs kiválasztva (fókuszban) nap
    if (myCalendar.selectedDay == null) {
      return const Center(child: Text('Válassz ki egy napot! (myCalendar.selectedDay == null)'));
    }

    //Nincs étel a napban
    if (myCalendar.selectedFoods.isEmpty) {
      return const Center(child: Text('A napod üres! (myCalendar.selectedFoods.isEmpty == true)'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,

      children: [
        ListView.builder(
          shrinkWrap: true,
          itemCount: myCalendar.selectedFoods.length,

          itemBuilder: (context, index) {
            final food = myCalendar.selectedFoods[index];

            return Card(
              color: Colors.blue,
              shadowColor: Colors.greenAccent,
              elevation: 8,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final day = myCalendar.daysMap[myCalendar.dayOnly(myCalendar.selectedDay!)];

                      await dayService.removeFoodFromDay(day!.id, food.id);

                      print("Étel sikeresen törölve! (ID: ${food.id}, Név: ${food.name})");

                      await refreshPage();
                    },

                    child: const Text("Törlés"),
                  ),

                  Text('ID: ${food.id}'),
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

  Container _dailyInfos() {
    return Container(
      width: 400,
      height: 400,

      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
      ),

      child: Column(
        children: [
          FutureBuilder<KcalAndNutrients>(
            future: totalFuture,

            builder: (context, totalSnapshot) {
              if(totalFuture == null) {
                return const Text('Válassz ki egy napot!');
              }
              else if(totalSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              else if(totalSnapshot.hasError) {
                return Text(
                  'Hiba: ${totalSnapshot.error}',
                  style: const TextStyle(color: Colors.red),
                );
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const Text(
                    'Napi összes Tápérték:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10,),

                  Text('Kcal: ${totalSnapshot.data!.kcal} Kcal'),
                  Text('Zsír: ${totalSnapshot.data!.fat} g'),
                  Text('Szénhidrát: ${totalSnapshot.data!.carb} g'),
                  Text('Fehérje: ${totalSnapshot.data!.protein} g'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
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

          contentPadding: const EdgeInsets.all(15),

          hintText: 'Étel neve:',

          hintStyle: const TextStyle(
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
            //Csak számok!
            FilteringTextInputFormatter.allow(RegExp(r'[\d\.]')),
          ],

          keyboardType: TextInputType.number,

          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,

            contentPadding: const EdgeInsets.all(15),

            hintText: '0',

            hintStyle: const TextStyle(
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

                const Text('Ételek:'),

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

      child: const Text('2. oldal')
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

      child: const Text('3. oldal')
  );
}

AppBar _appbar() {
  return AppBar(

    title: Text(
      'Kalóriaszámláló alkalmazás',

      style: const TextStyle(
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

Widget _hungarianNameOfDays(DateTime day) {
  switch(day.weekday) {
    case DateTime.monday:
      return const Center(child: Text('H'));
    case DateTime.tuesday:
      return const Center(child: Text('K'));
    case DateTime.wednesday:
      return const Center(child: Text('Sze'));
    case DateTime.thursday:
      return const Center(child: Text('Cs'));
    case DateTime.friday:
      return const Center(child: Text('P'));
    case DateTime.saturday:
      return const Center(child: Text('Szo'));
    default:
      return const Center(child: Text('V'));
  }
}

String _hungarianNameOfMonths(DateTime date) {
  switch(date.month) {
    case DateTime.january:
      return '${date.year} Január';
    case DateTime.february:
      return '${date.year} Február';
    case DateTime.march:
      return '${date.year} Március';
    case DateTime.april:
      return '${date.year} Április';
    case DateTime.may:
      return '${date.year} Május';
    case DateTime.june:
      return '${date.year} Június';
    case DateTime.july:
      return '${date.year} Július';
    case DateTime.august:
      return '${date.year} Augusztus';
    case DateTime.september:
      return '${date.year} Szeptember';
    case DateTime.october:
      return '${date.year} Október';
    case DateTime.november:
      return '${date.year} November';
    default:
      return '${date.year} December';
  }
}