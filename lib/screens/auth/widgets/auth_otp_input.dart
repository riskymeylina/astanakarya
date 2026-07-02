import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthOtpInput extends StatelessWidget {
  const AuthOtpInput({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
  }) : assert(controllers.length == 6),
       assert(focusNodes.length == 6);

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(String value, int index) onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const itemCount = 6;
        const gap = 10.0;
        final width =
            ((constraints.maxWidth - (gap * (itemCount - 1))) / itemCount)
                .clamp(44.0, 54.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            itemCount,
            (index) => Padding(
              padding: EdgeInsets.only(right: index == itemCount - 1 ? 0 : gap),
              child: SizedBox(
                width: width,
                child: TextField(
                  controller: controllers[index],
                  focusNode: focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  textInputAction: index == itemCount - 1
                      ? TextInputAction.done
                      : TextInputAction.next,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                    counterText: '',
                  ),
                  maxLength: 1,
                  onChanged: (value) => onChanged(value, index),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
