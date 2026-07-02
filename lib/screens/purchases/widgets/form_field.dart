import 'package:flutter/material.dart';
import 'purchase_theme.dart';

class FormField extends StatefulWidget {
  const FormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.icon,
    this.isRequired = false,
    this.maxLength,
    this.showCharacterCount = false,
    this.keyboardType = TextInputType.text,
    this.validateRealTime = true,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
    this.formatPhone = false,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final IconData? icon;
  final bool isRequired;
  final int? maxLength;
  final bool showCharacterCount;
  final TextInputType keyboardType;
  final bool validateRealTime;
  final Function(String)? onChanged;
  final TextCapitalization textCapitalization;
  final bool formatPhone;

  @override
  State<FormField> createState() => _FormFieldState();
}

class _FormFieldState extends State<FormField> with TickerProviderStateMixin {
  late AnimationController _validationController;
  late Animation<double> _validationScale;
  late Animation<double> _validationOpacity;

  String? _errorMessage;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();

    _validationController = AnimationController(
      duration: PurchaseTheme.durationShort,
      vsync: this,
    );

    _validationScale = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _validationController, curve: Curves.elasticOut),
    );

    _validationOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _validationController, curve: Curves.easeOut),
    );

    widget.controller.addListener(_validateField);
  }

  @override
  void dispose() {
    _validationController.dispose();
    widget.controller.removeListener(_validateField);
    super.dispose();
  }

  void _validateField() {
    if (!widget.validateRealTime) return;

    final value = widget.controller.text;
    final error = widget.validator?.call(value);

    setState(() {
      _errorMessage = error;
      _isValid = error == null && value.isNotEmpty;
    });

    if (_isValid || error != null) {
      _validationController.forward(from: 0);
    }
  }

  String _formatPhoneNumber(String value) {
    if (!widget.formatPhone) return value;

    // Remove non-digits
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) return '';
    if (digits.length <= 2) return digits;
    if (digits.length <= 5)
      return '${digits.substring(0, 2)}${digits.substring(2)}';
    if (digits.length <= 8) {
      return '${digits.substring(0, 2)} ${digits.substring(2, 5)} ${digits.substring(5)}';
    }

    return '${digits.substring(0, 2)} ${digits.substring(2, 5)} ${digits.substring(5, 8)} ${digits.substring(8)}';
  }

  void _onPhoneChanged(String value) {
    if (widget.formatPhone) {
      final formatted = _formatPhoneNumber(value);
      widget.controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.fromPosition(
          TextPosition(offset: formatted.length),
        ),
      );
    }

    widget.onChanged?.call(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final showCharCount = widget.showCharacterCount && widget.maxLength != null;
    final currentLength = widget.controller.text.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with required indicator
        Row(
          children: [
            Text(widget.label, style: PurchaseTheme.body),
            if (widget.isRequired)
              const Text(
                '*',
                style: TextStyle(
                  color: PurchaseTheme.error,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
        const SizedBox(height: PurchaseTheme.spacing8),

        // Text field
        TextField(
          controller: widget.controller,
          textCapitalization: widget.textCapitalization,
          keyboardType: widget.keyboardType,
          maxLength: widget.maxLength,
          onChanged: widget.formatPhone ? _onPhoneChanged : widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: PurchaseTheme.hint,
            filled: true,
            fillColor: PurchaseTheme.lightCream,
            counter: showCharCount
                ? Text(
                    '$currentLength / ${widget.maxLength}',
                    style: PurchaseTheme.caption,
                  )
                : SizedBox.fromSize(size: Size.zero),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: PurchaseTheme.spacing14,
              vertical: PurchaseTheme.spacing12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PurchaseTheme.radiusMedium),
              borderSide: const BorderSide(color: PurchaseTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PurchaseTheme.radiusMedium),
              borderSide: const BorderSide(color: PurchaseTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PurchaseTheme.radiusMedium),
              borderSide: const BorderSide(
                color: PurchaseTheme.cream,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PurchaseTheme.radiusMedium),
              borderSide: const BorderSide(color: PurchaseTheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PurchaseTheme.radiusMedium),
              borderSide: const BorderSide(
                color: PurchaseTheme.error,
                width: 2,
              ),
            ),
            suffixIcon: _isValid
                ? ScaleTransition(
                    scale: _validationScale,
                    child: FadeTransition(
                      opacity: _validationOpacity,
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: PurchaseTheme.success,
                        size: PurchaseTheme.iconStandard,
                      ),
                    ),
                  )
                : _errorMessage != null
                ? ScaleTransition(
                    scale: _validationScale,
                    child: FadeTransition(
                      opacity: _validationOpacity,
                      child: const Icon(
                        Icons.cancel_rounded,
                        color: PurchaseTheme.error,
                        size: PurchaseTheme.iconStandard,
                      ),
                    ),
                  )
                : null,
          ),
        ),

        // Error message
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: PurchaseTheme.spacing8),
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: PurchaseTheme.error,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'TomatoGrotesk',
              ),
            ),
          ),
      ],
    );
  }
}
