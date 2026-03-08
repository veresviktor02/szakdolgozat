import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:go_router/go_router.dart';

import '../../user/user_service.dart';
import '../../utils/shared.dart';
import '../../utils/my_calendar.dart';

import 'api_food_search.dart';
import 'daily_target.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:table_calendar/table_calendar.dart';

import '../../day/day_model.dart';
import '../../day/day_service.dart';
import '../../day/measurement_unit/measurement_unit_model.dart';
import '../../day/measurement_unit/measurement_unit_service.dart';

import '../../food/food_model.dart';
import '../../food/food_service.dart';
import '../../food/kcal_and_nutrients_model.dart';

import '../../user/user_model.dart';

import '../../API/api_service.dart';
import '../../API/api_food_model.dart';

class HomePage extends StatefulWidget {
  final int userId;

  //Függőségbefecskendezés: tesztekhez kell!
  final FoodService? foodService;
  final DayService? dayService;
  final MeasurementUnitService? measurementUnitService;

  const HomePage({
    super.key,

    required this.userId,

    this.foodService,
    this.dayService,
    this.measurementUnitService,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserService userService = UserService();
  late final FoodService foodService;
  late final DayService dayService;
  late final MeasurementUnitService measurementUnitService;

  final MyCalendar myCalendar = MyCalendar();

  late Future<List<Food>> foodFuture;
  late Future<List<Day>> dayFuture;
  Future<KcalAndNutrients>? totalFuture;
  late Future<List<MeasurementUnit>> measurementUnitFuture;

  MeasurementUnit? selectedMeasurementUnit;

  //late final User user;

  User? user;
  bool isLoading = true;
  String? errorMessage;

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

    _loadUser();

    //Itt fecskendezzük be a függőséget.
    foodService = widget.foodService ?? FoodService();
    dayService = widget.dayService ?? DayService();
    measurementUnitService = widget.measurementUnitService ?? MeasurementUnitService();

    refreshPage();
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
  void dispose() {
    nameController.dispose();
    kcalController.dispose();
    fatController.dispose();
    carbController.dispose();
    proteinController.dispose();
    foodWeightController.dispose();

    super.dispose();
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
    //Elkerüli a betöltés alatti hibát!
    if(user == null) {
      return Scaffold(
        body: Text('',),
      );
    }

    return Scaffold(
      appBar: Shared.myAppBar('Kalóriaszámláló alkalmazás',),

      backgroundColor: Colors.white,

      body: SizedBox(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          
            children: [
              DailyTarget(
                dailyTargetForSelectedDay: dailyTargetForSelectedDay(),
                totalFuture: totalFuture,
              ),

              _calendar(),

              const SizedBox(height: 5,),

              _dailyInfos(),

              const SizedBox(height: 5,),

              const SizedBox(height: 5,),

              _navigateToThirdPage(context),
          
              const SizedBox(height: 5,),
          
              _futureFoodBuilder(foodFuture),
          
              const SizedBox(height: 20,),
          
              _dataSenderContainer(),
          
              const SizedBox(height: 20,),

              ApiFoodSearch(apiService: apiService,),

              const SizedBox(height: 20,),
          
            ],
          ),
        ),
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
              //Csak egy hetet lehet léptetni a naptárt.
              //(Telefonon működik, gépen touchpaddel nem!)
              pageAnimationEnabled: false,

              availableGestures: AvailableGestures.horizontalSwipe,

              //Visszavált a mai napra kattintás esetén!
              onHeaderTapped: (focusedDay) {
                setState(() {
                  final today = DateTime.now();
                  myCalendar.focusedDay = today;
                  myCalendar.selectedDay = today;
                });
              },

              rowHeight: 75,

              //TODO: headerVisible = false és saját headert csinálni?
              //headerVisible: false,

              headerStyle: HeaderStyle(
                titleCentered: true,

                formatButtonVisible: false,

                headerPadding: EdgeInsets.all(4.0,),

                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent,),
                ),

                titleTextStyle: TextStyle(
                  fontSize: 20,

                  fontWeight: FontWeight.bold,
                ),

                //Hónapok testreszabása
                titleTextFormatter: (date, locale) => MyCalendar.hungarianNameOfMonths(date),
              ),

              daysOfWeekVisible: false,

              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) => MyCalendar.calendarDay(day, Colors.grey),

                todayBuilder: (context, day, focusedDay) => MyCalendar.calendarDay(day, Colors.orange),

                selectedBuilder: (context, day, focusedDay)  => MyCalendar.calendarDay(day, Colors.green),

                outsideBuilder: (context, day, focusedDay)  => MyCalendar.calendarDay(day, Colors.grey),
              ),

              calendarStyle: CalendarStyle(
                outsideTextStyle: TextStyle(color: Colors.grey.shade400),

                cellMargin: EdgeInsets.zero,

                cellPadding: EdgeInsets.zero,
              ),

              firstDay: firstDay,
              lastDay: lastDay,
              focusedDay: myCalendar.focusedDay,

              //default: Vasárnap!
              startingDayOfWeek: StartingDayOfWeek.monday,

              selectedDayPredicate: (day) {
                return isSameDay(myCalendar.selectedDay, day);
              },

              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  myCalendar.selectedDay = selectedDay;
                  myCalendar.focusedDay = focusedDay;
                });

                refreshPage();
              },

              calendarFormat: MyCalendar.calendarFormat,
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

            _myDropdown(),

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

  Widget _myDropdown() {
    return Align(
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

              //final measurementUnits =

              return DropdownButtonFormField<MeasurementUnit>(
                hint: const Text('Mértékegység'),

                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),

                items: measurementUnitSnapshot.data!.map((measurementUnit) {
                  return DropdownMenuItem<MeasurementUnit>(
                    value: measurementUnit,

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(measurementUnit.measurementUnitName),

                        ElevatedButton(
                          onPressed: () async {
                            await measurementUnitService.deleteMeasurementUnit(measurementUnit.id);

                            await refreshPage();
                          },

                          child: const Text('Törlés',),
                        ),
                      ],
                    ),
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
                        Text('Tömeg: ${food.foodWeight} ${food.measurementUnit.measurementUnitName}',),

                        SizedBox(height: 5.0,),

                        _navigateToFoodDataPage(food.id),
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
                if(selectedMeasurementUnit == null) {
                  Shared.mySnackBar(
                    'Nem választottál mértékegységet!',
                    Colors.red,
                    context,
                  );

                  return;
                }

                addFoodToDay();

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

  Future<void> addFoodToDay() async {
    await dayService.addFoodToDay(
        myCalendar.daysMap[myCalendar.dayOnly(myCalendar.selectedDay)]!.id,

        nameController.text,

        KcalAndNutrients(
          kcal: double.parse(kcalController.text),
          fat: double.parse(fatController.text),
          carb: double.parse(carbController.text),
          protein: double.parse(proteinController.text),
        ),

        double.parse(foodWeightController.text),

        selectedMeasurementUnit!
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

  KcalAndNutrients dailyTargetForSelectedDay() {
    switch(myCalendar.selectedDay.weekday) {
      case DateTime.monday:
        return user!.dailyTarget[0];
      case DateTime.tuesday:
        return user!.dailyTarget[1];
      case DateTime.wednesday:
        return user!.dailyTarget[2];
      case DateTime.thursday:
        return user!.dailyTarget[3];
      case DateTime.friday:
        return user!.dailyTarget[4];
      case DateTime.saturday:
        return user!.dailyTarget[5];
    }
    return user!.dailyTarget[6];
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

  Column _foodColumn(AsyncSnapshot<List<Food>> foodSnapshot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: foodSnapshot.data!.map(
              (food) {
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

  ElevatedButton _navigateToFoodDataPage(int foodId) {
    return ElevatedButton(
      onPressed: () {
        context.go('/foodDataPage/$foodId');
      },

      child: const Text('Étel adatlapja',),
    );
  }

  //////////////////////////////////////////////////////////////////////
  ////////////////////Itt ér véget a _HomePageState!////////////////////
  //////////////////////////////////////////////////////////////////////
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

ElevatedButton _navigateToThirdPage(BuildContext context) {
  return ElevatedButton(
      onPressed: () {
        context.push('/third');
      },

      child: const Text('3. oldal',),
  );
}