import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'purchase_theme.dart';

class PriceBreakdown extends StatefulWidget {
  const PriceBreakdown({
    super.key,
    required this.basePrice,
    this.tax,
    required this.total,
    this.animateNumbers = true,
  });

  final double basePrice;
  final double? tax;
  final double total;
  final bool animateNumbers;

  @override
  State<PriceBreakdown> createState() => _PriceBreakdownState();
}

class _PriceBreakdownState extends State<PriceBreakdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    if (widget.animateNumbers) {
      _animationController = AnimationController(
        duration: PurchaseTheme.durationMedium,
        vsync: this,
      );

      _animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      );

      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  Widget _buildPriceRow({
    required String label,
    required double amount,
    bool isBold = false,
    Color? labelColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PurchaseTheme.spacing8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 15 : 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: labelColor ?? PurchaseTheme.brownText,
              fontFamily: 'TomatoGrotesk',
            ),
          ),
          if (widget.animateNumbers)
            ScaleTransition(
              scale: _animation,
              child: Text(
                _formatPrice(amount),
                style: TextStyle(
                  fontSize: isBold ? 18 : 14,
                  fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
                  color: isBold ? PurchaseTheme.navy : PurchaseTheme.darkBrown,
                  fontFamily: 'TomatoGrotesk',
                ),
              ),
            )
          else
            Text(
              _formatPrice(amount),
              style: TextStyle(
                fontSize: isBold ? 18 : 14,
                fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
                color: isBold ? PurchaseTheme.navy : PurchaseTheme.darkBrown,
                fontFamily: 'TomatoGrotesk',
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Base price
        _buildPriceRow(label: 'Harga Properti', amount: widget.basePrice),

        // Tax if exists
        if (widget.tax != null && widget.tax! > 0)
          _buildPriceRow(
            label: 'Pajak & Biaya Admin',
            amount: widget.tax!,
            labelColor: PurchaseTheme.hintText,
          ),

        // Divider
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: PurchaseTheme.spacing12,
          ),
          child: Container(height: 1, color: PurchaseTheme.border),
        ),

        // Total
        _buildPriceRow(
          label: 'Total Pemesanan',
          amount: widget.total,
          isBold: true,
        ),
      ],
    );
  }
}
