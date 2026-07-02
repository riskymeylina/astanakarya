import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'purchase_theme.dart';

class ReviewSummaryCard extends StatefulWidget {
  const ReviewSummaryCard({
    super.key,
    required this.propertyTitle,
    required this.propertyPrice,
    required this.paymentMethod,
    required this.buyerName,
    this.buyerPhone,
    this.buyerAddress,
    required this.onEditSection,
  });

  final String propertyTitle;
  final double propertyPrice;
  final String paymentMethod;
  final String buyerName;
  final String? buyerPhone;
  final String? buyerAddress;
  final Function(String) onEditSection;

  @override
  State<ReviewSummaryCard> createState() => _ReviewSummaryCardState();
}

class _ReviewSummaryCardState extends State<ReviewSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: PurchaseTheme.durationLong,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
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

  Widget _buildReviewRow({
    required String label,
    required String value,
    required Function() onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PurchaseTheme.spacing12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: PurchaseTheme.hint),
                const SizedBox(height: PurchaseTheme.spacing4),
                Text(
                  value,
                  style: PurchaseTheme.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: PurchaseTheme.spacing12),
          GestureDetector(
            onTap: onEdit,
            child: Text(
              'Edit',
              style: TextStyle(
                color: PurchaseTheme.cream,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'TomatoGrotesk',
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        decoration: PurchaseTheme.cardDecoration(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(PurchaseTheme.radiusXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(PurchaseTheme.spacing16),
                color: PurchaseTheme.background,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: PurchaseTheme.orangeBg,
                        borderRadius: BorderRadius.circular(
                          PurchaseTheme.radiusSmall,
                        ),
                      ),
                      child: const Icon(
                        Icons.fact_check_rounded,
                        color: PurchaseTheme.brown,
                        size: PurchaseTheme.iconMedium,
                      ),
                    ),
                    const SizedBox(width: PurchaseTheme.spacing12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Periksa Kembali Data',
                            style: PurchaseTheme.heading2,
                          ),
                          SizedBox(height: PurchaseTheme.spacing4),
                          Text(
                            'Pastikan semua informasi sudah benar',
                            style: PurchaseTheme.bodySecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Container(height: 1, color: PurchaseTheme.lightBorder),

              // Content
              Padding(
                padding: const EdgeInsets.all(PurchaseTheme.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Property section
                    _buildReviewRow(
                      label: 'Properti yang Dibeli',
                      value: widget.propertyTitle,
                      onEdit: () => widget.onEditSection('property'),
                    ),
                    const SizedBox(height: PurchaseTheme.spacing8),
                    _buildReviewRow(
                      label: 'Harga Total',
                      value: _formatPrice(widget.propertyPrice),
                      onEdit: () => widget.onEditSection('property'),
                    ),

                    // Divider
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: PurchaseTheme.spacing12,
                      ),
                      child: Container(height: 1, color: PurchaseTheme.border),
                    ),

                    // Payment method section
                    _buildReviewRow(
                      label: 'Metode Pembayaran',
                      value: widget.paymentMethod,
                      onEdit: () => widget.onEditSection('payment'),
                    ),

                    // Divider
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: PurchaseTheme.spacing12,
                      ),
                      child: Container(height: 1, color: PurchaseTheme.border),
                    ),

                    // Buyer info section
                    _buildReviewRow(
                      label: 'Nama Pemesan',
                      value: widget.buyerName,
                      onEdit: () => widget.onEditSection('buyer'),
                    ),

                    if (widget.buyerPhone != null &&
                        widget.buyerPhone!.isNotEmpty)
                      Column(
                        children: [
                          const SizedBox(height: PurchaseTheme.spacing8),
                          _buildReviewRow(
                            label: 'Nomor WhatsApp',
                            value: widget.buyerPhone!,
                            onEdit: () => widget.onEditSection('buyer'),
                          ),
                        ],
                      ),

                    if (widget.buyerAddress != null &&
                        widget.buyerAddress!.isNotEmpty)
                      Column(
                        children: [
                          const SizedBox(height: PurchaseTheme.spacing8),
                          _buildReviewRow(
                            label: 'Alamat',
                            value: widget.buyerAddress!,
                            onEdit: () => widget.onEditSection('buyer'),
                          ),
                        ],
                      ),

                    // Warning section
                    Padding(
                      padding: const EdgeInsets.only(
                        top: PurchaseTheme.spacing16,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(PurchaseTheme.spacing12),
                        decoration: BoxDecoration(
                          color: PurchaseTheme.warning.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(
                            PurchaseTheme.radiusMedium,
                          ),
                          border: Border.all(
                            color: PurchaseTheme.warning.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: PurchaseTheme.warning,
                              size: PurchaseTheme.iconMedium,
                            ),
                            const SizedBox(width: PurchaseTheme.spacing8),
                            Expanded(
                              child: Text(
                                'Dengan melanjutkan, Anda menerima Syarat & Ketentuan pengambilalihan properti ini.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: PurchaseTheme.brown,
                                  fontFamily: 'TomatoGrotesk',
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
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
  }
}
