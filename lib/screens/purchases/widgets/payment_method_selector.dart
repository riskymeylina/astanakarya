import 'package:flutter/material.dart';
import 'purchase_theme.dart';

class PaymentMethodSelector extends StatefulWidget {
  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final Function(String) onChanged;

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  static const List<Map<String, dynamic>> _methods = [
    {
      'id': 'Transfer Bank',
      'title': 'Transfer Bank',
      'description': 'Transfer ke rekening tujuan dengan nominal otomatis.',
      'badge': 'Bank',
      'icon': Icons.account_balance_rounded,
    },
    {
      'id': 'Cash Payment',
      'title': 'Cash Payment',
      'description': 'Pembayaran tunai tetap menampilkan instruksi rekening.',
      'badge': 'Full',
      'icon': Icons.payments_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._methods.map((method) {
          final isSelected = widget.selected == method['id'];

          return Padding(
            padding: const EdgeInsets.only(bottom: PurchaseTheme.spacing10),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => widget.onChanged(method['id']),
              child: AnimatedContainer(
                duration: PurchaseTheme.durationShort,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? PurchaseTheme.paymentSelectedBg
                      : PurchaseTheme.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? PurchaseTheme.success.withOpacity(0.45)
                        : PurchaseTheme.dividerColor,
                    width: isSelected ? 1.4 : 1,
                  ),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? PurchaseTheme.success.withOpacity(0.14)
                            : const Color(0xFFF6F1EA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        method['icon'],
                        color: isSelected
                            ? PurchaseTheme.success
                            : const Color(0xFF8A735F),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: PurchaseTheme.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  method['title'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF303030),
                                    fontFamily: 'TomatoGrotesk',
                                  ),
                                ),
                              ),
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: isSelected
                                    ? PurchaseTheme.success
                                    : const Color(0xFFB8B8B8),
                                size: 21,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            method['description'],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF777777),
                              height: 1.35,
                              fontFamily: 'TomatoGrotesk',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: PurchaseTheme.dividerColor,
                              ),
                            ),
                            child: Text(
                              method['badge'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: isSelected
                                    ? PurchaseTheme.navy
                                    : const Color(0xFF8A8A8A),
                                fontFamily: 'TomatoGrotesk',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF0E1D2)),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF9A6700),
                size: 18,
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Nominal pembayaran otomatis mengikuti total pesanan.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6D5540),
                    fontFamily: 'TomatoGrotesk',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
