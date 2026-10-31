# CHANGELOG: ДНЕВНИК ПИТАНИЯ

Все значимые изменения в проекте документируются в данном файле в соответствии с принципами Semantic Versioning.

---

## [0.1.0-alpha.1] - 2026-10-31 (Фаза 1: Фундамент, Инфраструктура и Дизайн-система)
### Добавлено
- Установлен и настроен Flutter 3.47.9 / Dart 3.13.7.
- Создана модульная Feature-First структура проекта с поддержкой Android и iOS.
- Настроен `pubspec.yaml` со всеми базовыми зависимостями: Flutter Riverpod, GoRouter, Drift, Flutter Localizations, SQLite3 Flutter Libs, FL Chart, Shared Preferences, Secure Storage, Google Fonts, Intl.
- Развернута полная Material 3 дизайн-система:
  - `AppColors`: адаптированные изумрудная и коралловая палитры, БЖУ-цвета, светлая и темная гаммы.
  - `AppTypography`: типографическая шкала шрифтов.
  - `AppTheme`: светлая и темная темы ThemeData с CardThemeData, DialogThemeData, AppBar, BottomNavigationBar, BottomSheet.
  - Атомарные UI-компоненты: `NutriCard`, `PrimaryButton`, `MacroBar` (с `MacroTile`), `NutriTextField`, `CalorieRing`.
- Полноценная локальная база данных на Drift (SQLite):
  - 11 таблиц схемы (`UserProfiles`, `FoodProducts`, `DiaryEntries`, `WaterEntries`, `WeightEntries`, `Recipes`, `RecipeIngredients`, `MealPlans`, `MealPlanItems`, `Achievements`, `UserAchievements`).
  - Кодогенерация Drift через `build_runner`.
  - Датасет начального сидирования: ~100 популярных русских продуктов с проверенным КБЖУ (`initialFoodProducts`) и 6 базовых достижений.
  - Типизированные DAO: `FoodDao` (поиск с кириллицей, избранное), `DiaryDao` (посуточный учет и суммирование КБЖУ), `UserDao` (профиль и вес), `WaterDao` (учет и сброс воды), `WeightDao` (история и последнее взвешивание).
  - Riverpod провайдеры для базы данных и всех DAOs.
- Навигационный маршрутизатор GoRouter:
  - `StatefulShellRoute.indexedStack` для 5 вкладок (Главная, Дневник, Питание, Статистика, Профиль).
  - Центральный FAB быстрого добавления со всплывающим BottomSheet.
  - Логика первоначального редиректа на Онбординг (`onboarding_complete` flag).
- Полный комплект тестов (19 тестов, 100% passed):
  - 10 unit-тестов калькулятора питания `NutritionCalculator` (Mifflin-St Jeor BMR, TDEE, безопасные дефициты, макронутриенты, норма воды).
  - 6 интеграционных тестов Drift БД и DAOs на SQLite in-memory.
  - 2 widget smoke теста `DnevnikApp` (онбординг и дашборд при разном состоянии SharedPreferences).
- `flutter analyze`: 0 ошибок, 0 предупреждений.

## [0.1.0-alpha.0] - 2026-10-31 (Фаза 0)
### Добавлено
- Выполнен комплексный аудит рабочей среды `D:\go-projects\Dnevnik`.
- Инициализирован Git-репозиторий.
- Спроектирована архитектура Feature-First Clean Architecture на Flutter / Dart.
- Разработана спецификация и схема реляционной базы данных Drift (SQLite) с поддержкой реактивных Streams и внешних ключей.
- Спроектирована дизайн-система в эстетике Material 3 с теплой светлой и глубокой темной темами, акцентным изумрудно-коралловым стилем.
- Составлена математическая модель клинического расчета метаболизма по формуле Миффлина-Сан Жеора, коэффициентам физической активности (PAL) и безопасным границам дефицита калоража.
- Созданы базовые проектные документы:
  - `PROJECT_CONTEXT.md` — полный контекст архитектуры, схемы БД, решений и текущего статуса.
  - `DEVELOPMENT_PLAN.md` — подробный пошаговый роадмап от Фазы 0 до релиза в Google Play с критериями качества QA.
  - `CHANGELOG.md` — журнал версий.
  - `README.md` — обзор проекта, стек технологий и инструкции по развертыванию.
