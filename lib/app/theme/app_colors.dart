import 'package:flutter/material.dart';

/// Централизованная цветовая палитра приложения «Дневник»
///
/// Все цвета взяты из утверждённой дизайн-системы (Фаза 0):
/// - Primary: Изумрудно-зелёный (здоровье, свежесть, баланс)
/// - Secondary: Тёплый коралл (энергия, фокус, активность)
/// - Макросы: уникальный цвет для каждого нутриента
abstract final class AppColors {
  // ── Primary: Изумрудный зелёный ─────────────────────────────────────
  static const Color primary = Color(0xFF059669);
  static const Color primaryLight = Color(0xFF10B981);
  static const Color primaryContainer = Color(0xFFD1FAE5);
  static const Color onPrimaryContainer = Color(0xFF064E3B);

  // ── Secondary: Тёплый коралл/оранжевый (Калории) ──────────────────────
  static const Color secondary = Color(0xFFF97316);
  static const Color secondaryLight = Color(0xFFFB923C);
  static const Color secondaryContainer = Color(0xFFFFEDD5);
  static const Color onSecondaryContainer = Color(0xFF7C2D12);
  static const Color calories = secondary;
  static const Color caloriesLight = secondaryContainer;

  // ── Фоны (Light) ────────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFFAF9F6);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF3F4F6);
  static const Color onBackgroundLight = Color(0xFF111827);
  static const Color onSurfaceLight = Color(0xFF1F2937);
  static const Color onSurfaceVariantLight = Color(0xFF6B7280);

  // ── Фоны (Dark) ──────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF121417);
  static const Color surfaceDark = Color(0xFF1E2228);
  static const Color surfaceVariantDark = Color(0xFF2A2F38);
  static const Color onBackgroundDark = Color(0xFFF9FAFB);
  static const Color onSurfaceDark = Color(0xFFE5E7EB);
  static const Color onSurfaceVariantDark = Color(0xFF9CA3AF);

  // ── Макронутриенты ───────────────────────────────────────────────────
  /// Белки — синий индиго
  static const Color protein = Color(0xFF6366F1);
  static const Color proteinLight = Color(0xFFE0E7FF);
  static const Color proteinDark = Color(0xFF4338CA);

  /// Жиры — тёплый янтарь
  static const Color fat = Color(0xFFF59E0B);
  static const Color fatLight = Color(0xFFFEF3C7);
  static const Color fatDark = Color(0xFFB45309);

  /// Углеводы — бирюза/морская волна
  static const Color carbs = Color(0xFF14B8A6);
  static const Color carbsLight = Color(0xFFCCFBF1);
  static const Color carbsDark = Color(0xFF0F766E);

  /// Вода — чистый лазурный
  static const Color water = Color(0xFF0EA5E9);
  static const Color waterLight = Color(0xFFE0F2FE);
  static const Color waterDark = Color(0xFF0369A1);

  // ── Семантические цвета ──────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color successContainer = Color(0xFFDCFCE7);

  /// Мягкое предупреждение (никогда не красное — психологический принцип)
  static const Color warning = Color(0xFFD97706);
  static const Color warningContainer = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFDC2626);
  static const Color errorContainer = Color(0xFFFEE2E2);

  // ── Разделители и обводки ────────────────────────────────────────────
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF374151);

  // ── Скругление карточек (токены, используются в DecoratedBox) ────────
  static const double radiusCard = 20.0;
  static const double radiusButton = 14.0;
  static const double radiusInput = 12.0;
  static const double radiusSmall = 8.0;
}
