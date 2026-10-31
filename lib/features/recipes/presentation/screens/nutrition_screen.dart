import 'package:flutter/material.dart';
import '../widgets/recipes_catalog_view.dart';
import '../../../meal_planner/presentation/widgets/meal_planner_view.dart';

/// Экран «Питание» (Вкладка 3 нижней навигации)
/// Объединяет Книгу рецептов и Недельный планировщик с корзиной покупок
class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Питание и меню'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.restaurant_menu_rounded), text: 'Книга рецептов'),
              Tab(icon: Icon(Icons.calendar_month_rounded), text: 'План & Покупки'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            RecipesCatalogView(),
            MealPlannerView(),
          ],
        ),
      ),
    );
  }
}
