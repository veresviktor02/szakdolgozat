import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '/pages/welcome.dart';
import '/pages/home/home.dart';
import '/pages/food_data_page.dart';
import '/pages/third_page.dart';

import 'shared.dart';

//context.go   -> Cseréli a linket.
//context.push -> Nem cseréli a linket.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',

  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),

    body: Center(
      child: Text(
        state.error?.toString() ?? 'A keresett oldal nem található!',
      ),
    ),
  ),
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomePage(),
    ),

    GoRoute(
      path: '/home/:userId',
      builder: (context, state) {
        final userId = int.tryParse(state.pathParameters['userId'] ?? '');

        if(userId == null) {
          return const _ErrorPage(message: 'User argumentum hiányzik!');
        }

        return HomePage(userId: userId);
      },
    ),

    GoRoute(
      path: '/foodDataPage/:foodId',
      builder: (context, state) {
        final foodId = int.tryParse(state.pathParameters['foodId'] ?? '');

        if(foodId == null) {
          return const _ErrorPage(message: 'Hiányzó adat!');
        }

        return FoodDataPage(foodId: foodId);
      },
    ),

    GoRoute(
      path: '/third',
      builder: (context, state) => const ThirdPage(),
    ),
  ],
);

class _ErrorPage extends StatelessWidget {
  final String message;

  const _ErrorPage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Shared.myAppBar('ERROR',),

      body: Column(
        children: [
          SizedBox(height: 30,),

          Center(
            child: Text(
              message,

              style: TextStyle(
                fontSize: 40,
              ),
            ),
          ),

          SizedBox(height: 300,),

          ElevatedButton(
            onPressed: () {
              context.go('/');
            },

            child: const Text('Vissza a kezdőlapra'),
          ),
        ],
      ),
    );
  }
}