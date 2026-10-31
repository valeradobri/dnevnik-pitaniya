import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// Стилизованное поле ввода с валидацией по дизайн-системе «Дневника»
class NutriTextField extends StatelessWidget {
  const NutriTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.suffixText,
    this.prefixIcon,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction,
    this.maxLength,
    this.obscureText = false,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? suffixText;
  final Widget? prefixIcon;
  final bool enabled;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      enabled: enabled,
      autofocus: autofocus,
      textInputAction: textInputAction,
      maxLength: maxLength,
      obscureText: obscureText,
      style: AppTypography.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffixText,
        prefixIcon: prefixIcon,
        counterText: '',
        labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        suffixStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
