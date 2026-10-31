import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_intro_step.dart';
import '../widgets/onboarding_basic_info_step.dart';
import '../widgets/onboarding_body_params_step.dart';
import '../widgets/onboarding_activity_step.dart';
import '../widgets/onboarding_goal_step.dart';
import '../widgets/onboarding_summary_step.dart';

/// Интерактивный экран онбординга — 6 шагов персонализации
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool _isLoading = false;

  final List<Widget> _steps = const [
    OnboardingIntroStep(),
    OnboardingBasicInfoStep(),
    OnboardingBodyParamsStep(),
    OnboardingActivityStep(),
    OnboardingGoalStep(),
    OnboardingSummaryStep(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onStepChanged(int step) {
    ref.read(onboardingProvider.notifier).goToStep(step);
  }

  Future<void> _handleNext() async {
    final state = ref.read(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    if (state.currentStep < _steps.length - 1) {
      notifier.nextStep();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Финальное сохранение
      setState(() => _isLoading = true);
      try {
        final prefs = await SharedPreferences.getInstance();
        await notifier.completeOnboarding(prefs);
        if (mounted) {
          context.go('/home/dashboard');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _handleBack() {
    final state = ref.read(onboardingProvider);
    if (state.currentStep > 0) {
      ref.read(onboardingProvider.notifier).previousStep();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _skipForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await ref.read(onboardingProvider.notifier).completeOnboarding(prefs);
    if (mounted) {
      context.go('/home/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(onboardingProvider);
    final currentStep = state.currentStep;

    final isFirstStep = currentStep == 0;
    final isLastStep = currentStep == _steps.length - 1;

    String buttonLabel;
    if (isFirstStep) {
      buttonLabel = 'Начать настройку';
    } else if (isLastStep) {
      buttonLabel = 'Сохранить и начать';
    } else {
      buttonLabel = 'Продолжить';
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: isFirstStep
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: _handleBack,
              ),
        title: isFirstStep
            ? null
            : Text(
                'Шаг $currentStep из ${_steps.length - 1}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _skipForTesting,
            child: const Text('Быстрый старт'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Индикатор прогресса
            if (!isFirstStep)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: currentStep / (_steps.length - 1),
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                ),
              ),

            // Контент шагов
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: _onStepChanged,
                children: _steps
                    .map((s) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: s,
                        ))
                    .toList(),
              ),
            ),

            // Нижняя панель действий
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isLoading ? null : _handleNext,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          buttonLabel,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
