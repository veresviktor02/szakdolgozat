import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:table_calendar/table_calendar.dart';

import 'package:go_router/go_router.dart';

import '/day/day_model.dart';
import '/day/day_service.dart';
import '/day/measurement_unit/measurement_unit_model.dart';
import '/day/measurement_unit/measurement_unit_service.dart';

import '/food/food_model.dart';
import '/food/food_service.dart';
import '/food/kcal_and_nutrients_model.dart';

import '/user/user_model.dart';
import '/user/user_service.dart';

import '/utils/shared.dart';
import '/utils/my_calendar.dart';

import 'api_food_search.dart';

import 'daily_target.dart';

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

  //Dropdown értékek
  MeasurementUnit? selectedMeasurementUnit;
  int? selectedMealNumber;
  //

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

  @override
  void initState() {
    super.initState();

    loadUser();

    //Itt fecskendezzük be a függőséget.
    foodService = widget.foodService ?? FoodService();
    dayService = widget.dayService ?? DayService();
    measurementUnitService = widget.measurementUnitService ?? MeasurementUnitService();

    refreshPage();
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

  void zeroAllTextFields() {
    nameController.text = '';
    kcalController.text = '';
    fatController.text = '';
    carbController.text = '';
    proteinController.text = '';
    foodWeightController.text = '';
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
      foodFuture = foodService.fetchFoods(widget.userId);
      dayFuture = dayService.fetchDays(widget.userId);
      measurementUnitFuture = measurementUnitService.fetchMeasurementUnits(widget.userId);
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
        totalFuture = dayService.getTotalKcalAndNutrients(widget.userId, selected.id);
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
        appBar: Shared.myAppBar('Töltődés...',),

        backgroundColor: Shared.backgroundColor,

        body: Text('',),
      );
    }

    return Scaffold(
      appBar: Shared.myAppBar('Kalóriaszámláló alkalmazás',),

      backgroundColor: Shared.backgroundColor,

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

              const SizedBox(height: 20,),
          
              _futureFoodBuilder(),
          
              const SizedBox(height: 20,),
          
              _dataSenderContainer(),
          
              const SizedBox(height: 20,),

              ApiFoodSearch(
                dayService: dayService,
                userId: widget.userId,
                myCalendar: myCalendar,
                onRefresh: refreshPage,
              ),

              const SizedBox(height: 20,),

              _navigateToLeaderboardPage(),

              const SizedBox(height: 20,),

              _navigateToSettingsPage(),

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
          width: Shared.pageWidth,
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

      child: Padding(
        padding: const EdgeInsets.all(8.0,),

        child: SizedBox(
          width: Shared.pageWidth,
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

                headerStyle: HeaderStyle(
                  titleCentered: true,

                  formatButtonVisible: false,

                  headerPadding: const EdgeInsets.all(4.0,),

                  decoration: BoxDecoration(
                    color: Shared.boxDecorationColor,

                    border: Border.all(color: Shared.borderColor,),
                  ),

                  titleTextStyle: const TextStyle(
                    fontSize: 20,

                    fontWeight: FontWeight.bold,
                  ),

                  //Hónapok testreszabása
                  titleTextFormatter: (date, locale) => MyCalendar.hungarianNameOfMonths(date),
                ),

                daysOfWeekVisible: false,

                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) => MyCalendar.calendarDay(day, Colors.lightGreen[400]!),

                  todayBuilder: (context, day, focusedDay) => MyCalendar.calendarDay(day, Colors.greenAccent),

                  selectedBuilder: (context, day, focusedDay) => MyCalendar.calendarDay(day, Colors.green[600]!),

                  outsideBuilder: (context, day, focusedDay) => MyCalendar.calendarDay(day, Colors.lightGreen[400]!),
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
      ),
    );
  }

  Future<void> sendFood() async {
    await foodService.sendFood(
      widget.userId,

      nameController.text,

      KcalAndNutrients(
        kcal: double.parse(kcalController.text),
        fat: double.parse(fatController.text),
        carb: double.parse(carbController.text),
        protein: double.parse(proteinController.text),
      ),
    );
  }

  Widget _dataSenderContainer() {
    return Center(
      child: Container(
        width: Shared.pageWidth,

        padding: const EdgeInsets.all(20.0,),

        decoration: BoxDecoration(
          color: Shared.boxDecorationColor,

          border: Border.all(color: Shared.borderColor,),
        ),


        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Text(
                  'Add meg a bevinni kívánt adatokat!',

                  style: TextStyle(
                    fontSize: 17,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            _nameTextField(nameController),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                _textFieldColumn('Kcal', kcalController),
                _textFieldColumn('Zsír', fatController),
                _textFieldColumn('Szénhidrát', carbController),
                _textFieldColumn('Fehérje', proteinController),
                _textFieldColumn('Tömeg', foodWeightController),
              ],
            ),

            _measurementUnitDropdown(),

            _mealNumberDropdown(),

            Container(
              alignment: Alignment.center,

              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0,),

                    child: ElevatedButton(
                      onPressed: () async {
                        await sendFood();

                        zeroAllTextFields();

                        emptyMealDropdownValue();

                        await refreshPage();
                      },

                      style: Shared.myButtonStyle,

                      child: const Text('Add hozzá az ételeidhez!',),
                    ),
                  ),

                  _foodSender(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _measurementUnitDropdown() {
    return Align(
      alignment: Alignment.center,

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
              if(measurementUnitSnapshot.hasError) {
                return Text('Hiba történt: ${measurementUnitSnapshot.error}',);
              }
              if(!measurementUnitSnapshot.hasData || measurementUnitSnapshot.data!.isEmpty) {
                return const Text('Nincs elérhető mértékegység.',);
              }

              return DropdownButtonFormField<MeasurementUnit>(
                hint: const Text('Mértékegység',),

                dropdownColor: Shared.dropdownColor,

                decoration: InputDecoration(
                  filled: true,
                  fillColor: Shared.dropdownColor,

                  border: const OutlineInputBorder(),
                ),

                items: measurementUnitSnapshot.data!.map((measurementUnit) {
                  return DropdownMenuItem<MeasurementUnit>(
                    value: measurementUnit,

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Text(measurementUnit.measurementUnitName,),

                        ElevatedButton(
                          onPressed: () async {
                            await measurementUnitService.deleteMeasurementUnit(measurementUnit.id);

                            await refreshPage();
                          },

                          style: Shared.myButtonStyle,

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

  Widget _mealNumberDropdown() {
    return Align(
      alignment: Alignment.center,

      child: Padding(
        padding: const EdgeInsets.all(5.0,),

        child: SizedBox(
          width: 440,

          child: DropdownButtonFormField<int>(
            hint: const Text('Étkezés kiválasztása',),

            dropdownColor: Shared.dropdownColor,

            decoration: InputDecoration(
              filled: true,
              fillColor: Shared.dropdownColor,

              border: const OutlineInputBorder(),
            ),

            value: selectedMealNumber,

            items: [1, 2, 3].map((meal) {
              return DropdownMenuItem<int>(
                value: meal,

                child: Text(mealNames(meal)),
              );
            }).toList(),

            onChanged: (int? value) {
              setState(() {
                selectedMealNumber = value;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _dayDetails() {
    return Column(
      children: [1, 2, 3].map((meal) {
        final foodsForMeal = myCalendar.selectedFoods
            .where((food) => food.mealNumber == meal)
            .toList();

        return Card(
          color: Shared.boxDecorationColor,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Padding(
                padding: const EdgeInsets.all(10.0,),

                child: Center(
                  child: Text(
                    mealNames(meal),

                    style: const TextStyle(
                      fontSize: 20,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 200,

                child: ListView.builder(
                  scrollDirection: Axis.horizontal,

                  shrinkWrap: true,

                  itemCount: foodsForMeal.length,

                  itemBuilder: (context, index) {
                    final food = foodsForMeal[index];

                    return SizedBox(
                      width: 190,

                      child: Card(
                        color: Shared.cardColor,
                        shadowColor: Shared.cardShadowColor,

                        elevation: 8,

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,

                          children: [
                            const SizedBox(height: 10,),

                            Text(
                              'Név: ${food.name}',

                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),

                            const SizedBox(height: 5,),

                            Text('Kcal: ${Shared.format(food.kcalAndNutrients.kcal)}',),
                            Text('Zsír: ${Shared.format(food.kcalAndNutrients.fat)}',),
                            Text('Szénhidrát: ${Shared.format(food.kcalAndNutrients.carb)}',),
                            Text('Fehérje: ${Shared.format(food.kcalAndNutrients.protein)}',),
                            Text('Tömeg: ${food.foodWeight} ${food.measurementUnit.measurementUnitName}',),

                            Padding(
                              padding: const EdgeInsets.all(8.0,),

                              child: ElevatedButton(
                                onPressed: () async {
                                  final day = myCalendar.daysMap[
                                  myCalendar.dayOnly(myCalendar.selectedDay)
                                  ];

                                  await dayService.removeFoodFromDay(
                                      day!.id, food.id
                                  );

                                  await refreshPage();
                                },

                                style: Shared.myButtonStyle,

                                child: const Text('Törlés'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String mealNames(int mealNumber) {
    switch(mealNumber) {
      case 1:
        return 'Reggeli';
      case 2:
        return 'Ebéd';
      case 3:
        return 'Vacsora';
      default:
        throw Exception('Rossz mealNumber lett megadva!');
    }
  }

  Widget _foodSender() {
    return Column(
      children: [
        Center(
          child: ElevatedButton(
            onPressed: () async {
              if(selectedMeasurementUnit == null) {
                Shared.mySnackBar(
                  message: 'Nem választottál mértékegységet!',
                  color: Colors.red,
                  context: context,
                );

                return;
              }

              if(selectedMealNumber == null) {
                Shared.mySnackBar(
                  message: 'Nem választottál étkezést!',
                  color: Colors.red,
                  context: context,
                );

                return;
              }

              addFoodToDay();

              zeroAllTextFields();

              emptyMealDropdownValue();

              await refreshPage();
            },

            style: Shared.myButtonStyle,

            child: const Text('Hozzáadás a napodhoz',),
          ),
        ),
      ],
    );
  }

  Future<void> addFoodToDay() async {
    await dayService.addFoodToDay(
        widget.userId,

        myCalendar.daysMap[myCalendar.dayOnly(myCalendar.selectedDay)]!.id,

        nameController.text,

        KcalAndNutrients(
          kcal: double.parse(kcalController.text),
          fat: double.parse(fatController.text),
          carb: double.parse(carbController.text),
          protein: double.parse(proteinController.text),
        ),

        double.parse(foodWeightController.text),

        selectedMeasurementUnit!,

        selectedMealNumber!
    );
  }

  Future<void> addFoodDetailsToTextFields(
      String name,
      KcalAndNutrients kcalAndNutrients,
  ) async {
    nameController.text = name;

    kcalController.text = kcalAndNutrients.kcal.toString();
    fatController.text = kcalAndNutrients.fat.toString();
    carbController.text = kcalAndNutrients.carb.toString();
    proteinController.text = kcalAndNutrients.protein.toString();
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

  Widget _foodColumn(AsyncSnapshot<List<Food>> foodSnapshot) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: Shared.pageWidth,
        maxHeight: 600,
      ),

      child: SingleChildScrollView(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
        
          children: foodSnapshot.data!.map((food) {
            return SizedBox(
              width: 180,
        
              child: Card(
                color: Shared.cardColor,
                shadowColor: Shared.cardShadowColor,
        
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
        
                          style: const TextStyle(fontSize: 16,),
                        ),
        
                        Text('Kcal: ${Shared.format(food.kcalAndNutrients.kcal)} kcal',),
                        Text('Zsír: ${Shared.format(food.kcalAndNutrients.fat)} g',),
                        Text('Szénhidrát: ${Shared.format(food.kcalAndNutrients.carb)} g',),
                        Text('Fehérje: ${Shared.format(food.kcalAndNutrients.protein)} g',),
        
                        const SizedBox(height: 10,),
        
                        _navigateToFoodDataPage(food.id),
        
                        const SizedBox(height: 10,),
        
                        ElevatedButton(
                          onPressed: () async {
                            await foodService.deleteFood(food.id);
        
                            await refreshPage();
                          },
        
                          style: Shared.myButtonStyle,
        
                          child: const Text('Törlés',),
                        ),

                        const SizedBox(height: 10,),

                        ElevatedButton(
                          onPressed: () async {
                            await addFoodDetailsToTextFields(
                                food.name,
                                food.kcalAndNutrients,
                            );
                          },

                          style: Shared.myButtonStyle,

                          child: const Text('Kitöltés',),
                        ),
                      ],
        
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _futureFoodBuilder() {
    return Center(
      //Hirtelen szélességugrás miatt kell!
      child: SizedBox(
        width: Shared.pageWidth,

        child: Container(
          padding: const EdgeInsets.all(20.0,),

          decoration: BoxDecoration(
            color: Shared.boxDecorationColor,

            border: Border.all(color: Shared.borderColor),
          ),

          child: FutureBuilder<List<Food>>(
            future: foodFuture,

            builder: (context, foodSnapshot) {
              //Várakozik a kapcsolatra
              if(foodSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: Shared.myCircularProgressIndicator());
              }
              //Hiba történt
              if(foodSnapshot.hasError) {
                return Text(
                  'Hiba: ${foodSnapshot.error}',

                  style: const TextStyle(color: Colors.red),
                );
              }
              //Nem üres a lista
              if(foodSnapshot.data!.isNotEmpty) {
                return _foodColumn(foodSnapshot);
              }

              //Üres a lista
              return const Text('Nincs adat.',);
            },
          ),
        ),
      ),
    );
  }

  Widget _navigateToFoodDataPage(int foodId) {
    return ElevatedButton(
      onPressed: () {
        context.go('/foodDataPage/${user!.id}/$foodId');
      },

      style: Shared.myButtonStyle,

      child: const Text('Étel adatlapja',),
    );
  }

  Widget _navigateToLeaderboardPage() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          context.go('/leaderboard');
        },

        style: Shared.myButtonStyle,

        child: const Text('Ranglista',),
      ),
    );
  }

  Widget _navigateToSettingsPage() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          context.push('/settings/${user!.id}');
        },

        style: Shared.myButtonStyle,

        child: const Text('Beállítások',),
      ),
    );
  }

  void emptyMealDropdownValue() {
    setState(() {
      selectedMealNumber = null;
    });
  }

  //////////////////////////////////////////////////////////////////////
  ////////////////////Itt ér véget a _HomePageState!////////////////////
  //////////////////////////////////////////////////////////////////////
}

Container _nameTextField(TextEditingController nameController) {
  return Container(
    alignment: Alignment.center,

    width: 450,

    padding: const EdgeInsets.all(5.0,),

    child: TextField(
      controller: nameController,

      decoration: Shared.inputDecoration('Étel neve', null,),
    ),
  );
}

Widget _textFieldColumn(String textData, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.all(5.0,),

    child: Column(
      children: [
        Text(
          textData,

          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 5,),

        SizedBox(
          width: 80,

          child: TextField(
            controller: controller,

            inputFormatters: [
              FilteringTextInputFormatter.allow(Shared.onlyNumbers,),
            ],

            keyboardType: TextInputType.number,

            decoration: Shared.inputDecoration(null, '0',),
          ),
        ),
      ],
    ),
  );
}