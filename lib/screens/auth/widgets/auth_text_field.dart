import 'package:flutter/material.dart';

const Color _kBrown = Color(0xFF8B3E0F);

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onTogglePasswordVisibility,
    this.borderRadius = 12,
    this.textInputAction,
    this.textAlign = TextAlign.start,
    this.maxLength,
    this.focusNode,
    this.onChanged,
    this.contentPadding,
    this.style,
    this.filledColor,
    this.enabledBorderColor,
    this.prefixIcon,
  });

  final TextEditingController controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onTogglePasswordVisibility;
  final double borderRadius;
  final TextInputAction? textInputAction;
  final TextAlign textAlign;
  final int? maxLength;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? style;
  final Color? filledColor;
  final Color? enabledBorderColor;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: isPassword ? !isPasswordVisible : obscureText,
      textInputAction: textInputAction,
      textAlign: textAlign,
      maxLength: maxLength,
      onChanged: onChanged,
      style: style ??
          const TextStyle(
            fontSize: 15,
            color: Color(0xFF1A1A1A),
          ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: filledColor ?? Colors.grey.shade50,
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: IconTheme(
                  data: IconThemeData(
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                  child: prefixIcon!,
                ),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: enabledBorderColor ?? Colors.grey.shade200,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: _kBrown, width: 1.8),
        ),
        suffixIcon: isPassword
            ? IconButton(
                onPressed: onTogglePasswordVisibility,
                icon: Icon(
                  isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
              )
            : null,
        counterText: '',
      ),
    );
  }
}
