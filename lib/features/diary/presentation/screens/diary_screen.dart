import 'package:flutter/material.dart';
import '../../../../core/widgets/placeholder_screen.dart';

/// Экран дневника питания
/// Полная реализация с Riverpod/Drift — в Фазе 2.
class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Дневник',
      icon: Icons.menu_book_rounded,
      description: 'Дневник питания с приёмами пищи\nи выбором граммовок\nпоявится в Фазе 2',
    );
  }
}
