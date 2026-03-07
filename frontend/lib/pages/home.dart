import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/shared.dart';
import '../utils/my_calendar.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:table_calendar/table_calendar.dart';

import 'package:percent_indicator/percent_indicator.dart';

import '../day/day_model.dart';
import '../day/day_service.dart';

import 'package:flutter_application/day/measurement_unit/measurement_unit_model.dart';
import 'package:flutter_application/day/measurement_unit/measurement_unit_service.dart';

import '../food/food_model.dart';
import '../food/food_service.dart';
import '../food/kcal_and_nutrients_model.dart';

import '../user/user_model.dart';

import '../API/api_service.dart';
import '../API/api_food_model.dart';

class HomePage extends StatefulWidget {
  final User user;

  //Függőségbefecskendezés: tesztekhez kell!
  final FoodService? foodService;
  final DayService? dayService;
  final MeasurementUnitService? measurementUnitService;

  const HomePage({
    super.key,

    required this.user,

    this.foodService,
    this.dayService,
    this.measurementUnitService,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final FoodService foodService;
  late final DayService dayService;
  late final MeasurementUnitService measurementUnitService;

  final MyCalendar myCalendar = MyCalendar();

  late Future<List<Food>> foodFuture;
  late Future<List<Day>> dayFuture;
  Future<KcalAndNutrients>? totalFuture;
  late Future<List<MeasurementUnit>> measurementUnitFuture;

  MeasurementUnit? selectedMeasurementUnit;

  late final User user;

  //Beviteli mezők
  final nameController = TextEditingController();
  final kcalController = TextEditingController();
  final fatController = TextEditingController();
  final carbController = TextEditingController();
  final proteinController = TextEditingController();
  final foodWeightController = TextEditingController();
  //

  //API
  final apiQueryController = TextEditingController();
  late final APIService apiService = APIService();
  bool apiLoading = false;
  String? apiError;
  List<APIFood> apiFoodList = [];
  //

  @override
  void initState() {
    super.initState();

    user = widget.user;

    //Itt fecskendezzük be a függőséget.
    foodService = widget.foodService ?? FoodService();
    dayService = widget.dayService ?? DayService();
    measurementUnitService = widget.measurementUnitService ?? MeasurementUnitService();

    refreshPage();
  }

  @override
  void dispose() {
    super.dispose();

    nameController.dispose();
    kcalController.dispose();
    fatController.dispose();
    carbController.dispose();
    proteinController.dispose();
    foodWeightController.dispose();
  }

  Future<void> refreshPage() async {
    //Külön setState kell, mert nem lenne inicializálva másképpen!
    setState(() {
      foodFuture = foodService.fetchFoods();
      dayFuture = dayService.fetchDays();
      measurementUnitFuture = measurementUnitService.fetchMeasurementUnits();
    });

    final days = await dayFuture;

    setState(() {
      myCalendar.daysMap.clear();

      for(final day in days) {
        myCalendar.daysMap[myCalendar.dayOnly(day.date)] = day;
      }

      //null crash mellőzése!
      final selected = myCalendar.daysMap[myCalendar.dayOnly(myCalendar.selectedDay)];

      //Kijelölt nap összes adata
      if(selected != null) {
        totalFuture = dayService.getTotalKcalAndNutrients(selected.id);
      } else {
        totalFuture = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Shared.myAppBar('Kalóriaszámláló alkalmazás',),

      backgroundColor: Colors.white,

      body: SizedBox(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          
            children: [
              _dailyTarget(),

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
          
              //_futureDayBuilder(dayFuture), //Picit belassul tőle!
          
              const SizedBox(height: 20,),
          
              _dataSenderContainer(),
          
              const SizedBox(height: 20,),

              _apiFoodSearch(),

              const SizedBox(height: 20,),
          
            ],
          ),
        ),
      ),
    );
  }

  Widget _apiFoodSearch() {
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

  Container _calendar() {
    //Ha nincs check, akkor egy rövid pillanatra hiba: 'Bad state: No element'.
    if(myCalendar.daysMap.isEmpty) {
      return Container(
        alignment: Alignment.center,

        child: SizedBox(
          width: 600,
          height: 200,

          child: Center(child: Shared.myCircularProgressIndicator(),),
        ),
      );
    }

    //Első és utolsó dátum kiolvasása myCalendar.daysMap-ből.
    //Ez az adat a backendről érkezik!
    final firstDay = myCalendar.daysMap.keys.reduce(
        //Sorrendbe rakása a dátumoknak, ha nem kronológiai sorrendben lennének!
        (a, b) => a.isBefore(b) ? a : b,
    );

    final lastDay = myCalendar.daysMap.keys.reduce(
        (a, b) => a.isAfter(b) ? a : b,
    );

    return Container(
      alignment: Alignment.center,

      child: SizedBox(
        width: 600,
        //Itt NE legyen magasság, mert az alatta lévő SingleChildScrollView
        //nem tudja magát üzemeltetni!
        //height: 500,

        child: Column(
          children: [
            TableCalendar(
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,

              //Hónapok testreszabása
              titleTextFormatter: (date, locale) => MyCalendar.hungarianNameOfMonths(date),

            ),

              //Hét napjainak testreszabása
              calendarBuilders: CalendarBuilders(
                dowBuilder: (context, day) => Center(child: Text(MyCalendar.hungarianNameOfDays(day),),),
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

                defaultTextStyle: const TextStyle(color: Colors.black),

                outsideTextStyle: TextStyle(color: Colors.grey.shade400),
              ),

              firstDay: firstDay,
              lastDay: lastDay,
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

                refreshPage();
              },

              calendarFormat: myCalendar.calendarFormat,
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
        width: 600,
        height: 500,

        padding: const EdgeInsets.all(20.0,),

        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent),
        ),


        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Add meg a bevinni kívánt adatokat!',

                  style: TextStyle(
                    fontSize: 17,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20,),

            _nameTextField(nameController),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,

              children: [
                _textFieldColumn('Kcal', kcalController),
                _textFieldColumn('Zsír', fatController),
                _textFieldColumn('Szénhidrát', carbController),
                _textFieldColumn('Fehérje', proteinController),
                _textFieldColumn('Tömeg', foodWeightController),
              ],
            ),

            //TODO: Refaktorálni! + Küldésnél küldeni!
            Align(
              alignment: Alignment.centerLeft,

              child: Padding(
                padding: const EdgeInsets.all(5.0,),

                child: SizedBox(
                  width: 440,

                  child: FutureBuilder<List<MeasurementUnit>>(
                    future: measurementUnitFuture,

                    builder: (context, measurementUnitSnapshot) {
                      if(measurementUnitSnapshot.connectionState == ConnectionState.waiting) {
                        return Shared.myCircularProgressIndicator();
                      }
                      else if(measurementUnitSnapshot.hasError) {
                        return Text('Hiba történt: ${measurementUnitSnapshot.error}');
                      }
                      else if(!measurementUnitSnapshot.hasData || measurementUnitSnapshot.data!.isEmpty) {
                        return const Text('Nincs elérhető mértékegység.');
                      }

                      final measurementUnits = measurementUnitSnapshot.data!;

                      return DropdownButtonFormField<MeasurementUnit>(
                        hint: const Text('Mértékegység'),

                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),

                        items: measurementUnits.map((measurementUnit) {
                          return DropdownMenuItem<MeasurementUnit>(
                            value: measurementUnit,

                            child: Text(measurementUnit.measurementUnitName),
                          );
                        }).toList(),

                        onChanged: (MeasurementUnit? value) {
                          setState(() {
                            selectedMeasurementUnit = value;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10,),

            Container(
              alignment: Alignment.centerLeft,

              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0,),

                    child: ElevatedButton(
                      onPressed: () async {
                        await sendFood();

                        zeroAllTextFields();

                        await refreshPage();
                      },
                      style: ButtonStyle(
                        //TODO: style
                      ),

                      child: const Text('Add hozzá az ételeidhez!',),
                    ),
                  ),

                  _foodSender(),
                ],
              ),
            ),

          ],
        )
    );
  }

  Widget _dayDetails() {
    //Nincs étel a napban
    if(myCalendar.selectedFoods.isEmpty) {
      return Column(
        children: [
          SizedBox(
            height: 500,

            child: const Center(
              child: Text(
                'A napod üres! (myCalendar.selectedFoods.isEmpty == true)',
              ),
            ),
          ),

          _foodSender(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,

      children: [
        SizedBox(
          //Fixelt magasság kell, mert a Flutter nem tudja kezelni a
          //görgethető Widgeten belüli görgethető Widgetet másképpen!
          height: 500,

          child: SingleChildScrollView(
            child: Scrollbar(
              child: ListView.builder(
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
                            final day = myCalendar.daysMap[myCalendar.dayOnly(myCalendar.selectedDay)];

                            await dayService.removeFoodFromDay(day!.id, food.id);

                            print('Étel sikeresen törölve! (ID: ${food.id}, Név: ${food.name})',);

                            await refreshPage();
                          },

                          child: const Text('Törlés',),
                        ),

                        Text('ID: ${food.id}',),
                        Text('Név: ${food.name}',),
                        Text('Kcal: ${food.kcalAndNutrients.kcal}',),
                        Text('Zsír: ${food.kcalAndNutrients.fat}',),
                        Text('Szénhidrát: ${food.kcalAndNutrients.carb}',),
                        Text('Fehérje: ${food.kcalAndNutrients.protein}',),
                        Text('Tömeg: ${food.foodWeight}',),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        _foodSender(),
      ],
    );
  }

  Container _foodSender() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
      ),

      child: Column(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () async {
                dayService.addFoodToDay(
                  myCalendar.daysMap[myCalendar.dayOnly(myCalendar.selectedDay)]!.id,

                  nameController.text,

                  KcalAndNutrients(
                    kcal: double.parse(kcalController.text),
                    fat: double.parse(fatController.text),
                    carb: double.parse(carbController.text),
                    protein: double.parse(proteinController.text),
                  ),

                  double.parse(foodWeightController.text),
                );

                zeroAllTextFields();

                await refreshPage();
              },

              child: const Text(
                'Hozzáadás',

                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
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
                return const Text('Válassz ki egy napot!',);
              }
              else if(totalSnapshot.connectionState == ConnectionState.waiting) {
                return Shared.myCircularProgressIndicator();
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

                  Text('Kcal: ${totalSnapshot.data!.kcal} Kcal',),
                  Text('Zsír: ${totalSnapshot.data!.fat} g',),
                  Text('Szénhidrát: ${totalSnapshot.data!.carb} g',),
                  Text('Fehérje: ${totalSnapshot.data!.protein} g',),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Center _dailyTarget() {
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

            Text('${dailyTargetForSelectedDay().kcal} Kcal',),
            Text('${dailyTargetForSelectedDay().fat} g Zsír',),
            Text('${dailyTargetForSelectedDay().carb} g Szénhidrát',),
            Text('${dailyTargetForSelectedDay().protein} g Fehérje',),

            const SizedBox(height: 10,),

            _circularPercentIndicator(),

          ],
        ),
      ),
    );
  }

  KcalAndNutrients dailyTargetForSelectedDay() {
    switch(myCalendar.selectedDay.weekday) {
      case DateTime.monday:
        return user.dailyTarget[0];
      case DateTime.tuesday:
        return user.dailyTarget[1];
      case DateTime.wednesday:
        return user.dailyTarget[2];
      case DateTime.thursday:
        return user.dailyTarget[3];
      case DateTime.friday:
        return user.dailyTarget[4];
      case DateTime.saturday:
        return user.dailyTarget[5];
    }
    return user.dailyTarget[6];
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
          percent: (totalSnapshot.data!.kcal / dailyTargetForSelectedDay().kcal).clamp(0.0, 1.0),

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
                    (totalSnapshot.data!.kcal / dailyTargetForSelectedDay().kcal) * 100
                  ).toStringAsFixed(1)} %',
                style: TextStyle(
                    color: progressColor(totalSnapshot),
                ),
              ),

              Text(
                '${totalSnapshot.data!.kcal - dailyTargetForSelectedDay().kcal}',
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
    if(totalSnapshot.data!.kcal <= dailyTargetForSelectedDay().kcal) {
      return Colors.green;
    }
    //20%-os túllépés.
    else if(totalSnapshot.data!.kcal <= dailyTargetForSelectedDay().kcal * 1.2) {
      return Colors.yellowAccent;
    }
    //40%-os túllépés
    else if(totalSnapshot.data!.kcal <= dailyTargetForSelectedDay().kcal * 1.4) {
      return Colors.orange;
    }
    //Több, mint 40%-os túllépés
    return Colors.red;
  }

  void zeroAllTextFields() {
    nameController.text = '';
    kcalController.text = '';
    fatController.text = '';
    carbController.text = '';
    proteinController.text = '';
    foodWeightController.text = '';
    apiQueryController.text = '';
  }
}

Container _nameTextField(TextEditingController nameController) {
  return Container(
    alignment: Alignment.topLeft,

    padding: const EdgeInsets.all(5.0,),

    child: SizedBox(
      //5 TextField alatta: 5x80-as szélesség + 5x8 (2x5 - 2 széle!) padding!
      width: 440,

      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent,),
        ),

        child: TextField(
          controller: nameController,

          decoration: InputDecoration(
            filled: true,

            fillColor: Colors.white,

            contentPadding: const EdgeInsets.all(15.0,),

            labelText: 'Étel neve:',

            hintStyle: const TextStyle(
              color: Color(0xffDDDADA,),

              fontSize: 13,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _textFieldColumn(String textData, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.all(5.0,),

    child: Column(
      children: [
        SizedBox(
          width: 80, //Ugyanannyi, mint alatta a TextField körüli SizedBox-é!!!

          child: Text(
            textData,
            textAlign: TextAlign.center,
          ),

        ),

        const SizedBox(height: 5,),

        SizedBox(
          width: 80,

          child: TextField(
            controller: controller,

            inputFormatters: [
              //Csak számok!
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],

            keyboardType: TextInputType.number,

            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,

              contentPadding: const EdgeInsets.all(15.0,),

              hintText: '0',

              hintStyle: const TextStyle(
                color: Color(0xffDDDADA),
                fontSize: 14,
              ),
            ),

          ),

        ),
      ],
    ),
  );
}

Container _futureFoodBuilder(Future<List<Food>> foodFuture) {
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

    children: foodSnapshot.data!.map(
            (food) {
        return SizedBox(
          width: 180,
          height: 180,

          child: Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8.0,),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0,),
            ),

            child: Padding(
              padding: const EdgeInsets.all(16.0,),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    'Név: ${food.name}',
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 5,),

                  Text('ID: ${food.id}',),
                  Text('Kcal: ${food.kcalAndNutrients.kcal} kcal',),
                  Text('Zsír: ${food.kcalAndNutrients.fat} g',),
                  Text('Szénhidrát: ${food.kcalAndNutrients.carb} g',),
                  Text('Fehérje: ${food.kcalAndNutrients.protein} g',),
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
    padding: const EdgeInsets.all(20.0,),

    child: FutureBuilder<List<Day>>(
      future: dayFuture,

      builder: (context, daySnapshot) {
        //Várakozik a kapcsolatra
        if(daySnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Shared.myCircularProgressIndicator());
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
        return const Text('Nincs adat.',);
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

          margin: const EdgeInsets.symmetric(vertical: 8.0,),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          child: Padding(
            padding: const EdgeInsets.all(16.0,),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  style: const TextStyle(fontSize: 16,),

                  //TODO: Egyszámjegyű hónapot és napot kétszámjegyűvé konvertálni!
                  'Dátum: ${day.date.year}-${day.date.month}-${day.date.day}',
                ),

                const SizedBox(height: 5,),

                const Text('Ételek:',),

                ListView.builder(
                  shrinkWrap: true,

                  itemCount: day.foodList.length,

                  itemBuilder: (context, index) {
                    final food = day.foodList[index];

                    return Column(
                      //Itt bent elveszik a külső Column crossAxisAlignment-je!
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text('Név: ${food.name}',),
                        Text('Kcal: ${food.kcalAndNutrients.kcal}',),
                        Text('Zsír: ${food.kcalAndNutrients.fat}',),
                        Text('Szénhidrát: ${food.kcalAndNutrients.carb}',),
                        Text('Fehérje: ${food.kcalAndNutrients.protein}',),
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

      child: const Text('2. oldal',),
  );
}

ElevatedButton _navigateToThirdPage(BuildContext context) {
  return ElevatedButton(
      onPressed: () {
        print('Gomb lenyomva! (3. oldal gombja)',);

        Navigator.of(context).pushNamed(
          '/third',
        );
      },

      child: const Text('3. oldal',),
  );
}