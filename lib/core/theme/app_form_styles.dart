import 'package:flutter/material.dart';

/// Consistent form fields — theme-aware labels and no floating-label clipping.
class AppFormStyles {
  AppFormStyles._();

  static const EdgeInsets fieldPadding = EdgeInsets.fromLTRB(14, 26, 14, 16);

  static InputDecoration decoration(
    BuildContext context, {
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? suffixText,
    TextStyle? suffixStyle,
    bool? filled,
    Color? fillColor,
    EdgeInsetsGeometry? contentPadding,
    InputBorder? enabledBorder,
    InputBorder? focusedBorder,
  }) {
    final inputTheme = Theme.of(context).inputDecorationTheme;

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      suffixText: suffixText,
      suffixStyle: suffixStyle,
      filled: filled ?? inputTheme.filled,
      fillColor: fillColor ?? inputTheme.fillColor,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      floatingLabelAlignment: FloatingLabelAlignment.start,
      alignLabelWithHint: true,
      isDense: false,
      contentPadding: contentPadding ?? fieldPadding,
      border: inputTheme.border,
      enabledBorder: enabledBorder ?? inputTheme.enabledBorder,
      focusedBorder: focusedBorder ?? inputTheme.focusedBorder,
      errorBorder: inputTheme.errorBorder,
      focusedErrorBorder: inputTheme.focusedErrorBorder,
      labelStyle: inputTheme.labelStyle,
      floatingLabelStyle: inputTheme.floatingLabelStyle,
      hintStyle: inputTheme.hintStyle,
    );
  }

  static TextStyle fieldText(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!;

  static TextStyle sectionTitle(BuildContext context) =>
      Theme.of(context).textTheme.headlineSmall!;

  static InputDecorationTheme inputTheme({
    required bool isDark,
    required Color fillColor,
    required Color borderColor,
    required Color focusColor,
    required Color labelColor,
    required Color hintColor,
    required Color errorColor,
  }) {
    final borderRadius = BorderRadius.circular(10);
    final outline = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: borderColor),
    );

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      isDense: false,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      floatingLabelAlignment: FloatingLabelAlignment.start,
      alignLabelWithHint: true,
      border: outline,
      enabledBorder: outline,
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: focusColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: fieldPadding,
      constraints: const BoxConstraints(minHeight: 60),
      labelStyle: TextStyle(fontSize: 13, height: 1.2, color: labelColor),
      floatingLabelStyle: TextStyle(fontSize: 13, height: 1.2, color: labelColor),
      hintStyle: TextStyle(fontSize: 14, color: hintColor),
    );
  }
}
