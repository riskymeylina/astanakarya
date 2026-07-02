import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/purchase_order_model.dart';
import 'purchase_theme.dart';

class PaymentInfoCard extends StatelessWidget {
  const PaymentInfoCard({
    super.key,
    required this.order,
    required this.formatPrice,
    required this.formatDate,
    required this.statusLabel,
    this.title = 'Informasi Pembayaran',
    this.compact = false,
  });

  final PurchaseOrderModel order;
  final String Function(double) formatPrice;
  final String Function(String?) formatDate;
  final String Function(String) statusLabel;
  final String title;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accountNumber = order.paymentAccountNumber?.trim().isNotEmpty == true
        ? order.paymentAccountNumber!.trim()
        : '-';
    final accountName = order.paymentAccountName?.trim().isNotEmpty == true
        ? order.paymentAccountName!.trim()
        : '-';
    final bankNote = order.paymentBankNote?.trim().isNotEmpty == true
        ? order.paymentBankNote!.trim()
        : 'Bank BCA';

    final isCash = order.paymentMethod.toLowerCase().contains('cash') ||
        order.paymentMethod.toLowerCase().contains('tunai');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(compact ? 20 : 24),
        border: Border.all(color: const Color(0xFFE8D6C2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCash ? const Color(0xFFE5F5EC) : const Color(0xFFFFF0D9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isCash ? Icons.payments_rounded : Icons.account_balance_wallet_rounded,
                  color: isCash ? const Color(0xFF1F7A45) : const Color(0xFF8E4E16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: compact ? 15 : 17,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF171717),
                        fontFamily: 'TomatoGrotesk',
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isCash
                          ? 'Bayar tunai secara langsung di kantor pemasaran.'
                          : 'Transfer sesuai nominal otomatis di bawah ini.',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF777777),
                        fontFamily: 'TomatoGrotesk',
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(label: statusLabel(order.status)),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isCash
                    ? [const Color(0xFF1F7A45), const Color(0xFF2C9F5A)]
                    : [const Color(0xFF1E2A5A), const Color(0xFF34427D)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCash ? 'Total yang harus dibayar tunai' : 'Total yang harus ditransfer',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE5E8FF),
                    fontFamily: 'TomatoGrotesk',
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  formatPrice(order.payableAmount),
                  style: TextStyle(
                    fontSize: compact ? 20 : 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontFamily: 'TomatoGrotesk',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (isCash) ...[
            const _PaymentInfoRow(
              icon: Icons.location_on_rounded,
              label: 'Lokasi Pembayaran',
              value: 'Kantor Pemasaran Astana Karya',
            ),
            const _PaymentInfoRow(
              icon: Icons.access_time_filled_rounded,
              label: 'Jam Operasional',
              value: '08:00 - 16:30 WIB (Setiap Hari)',
            ),
            _PaymentInfoRow(
              icon: Icons.schedule_rounded,
              label: 'Batas Pembayaran',
              value: formatDate(order.paymentDueAt),
              valueColor: order.isCancelled
                  ? PurchaseTheme.error
                  : const Color(0xFF9A6700),
            ),
          ] else ...[
            _PaymentInfoRow(
              icon: Icons.credit_card_rounded,
              label: 'Nomor Rekening',
              value: accountNumber,
              trailing: accountNumber == '-'
                  ? null
                  : TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: accountNumber));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Nomor rekening disalin')),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Salin'),
                    ),
            ),
            _PaymentInfoRow(
              icon: Icons.person_rounded,
              label: 'Nama Pemilik Rekening',
              value: accountName,
            ),
            _PaymentInfoRow(
              icon: Icons.storefront_rounded,
              label: 'Keterangan',
              value: bankNote,
            ),
            _PaymentInfoRow(
              icon: Icons.schedule_rounded,
              label: 'Batas Pembayaran',
              value: formatDate(order.paymentDueAt),
              valueColor: order.isCancelled
                  ? PurchaseTheme.error
                  : const Color(0xFF9A6700),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: PurchaseTheme.navy,
          fontFamily: 'TomatoGrotesk',
        ),
      ),
    );
  }
}

class _PaymentInfoRow extends StatelessWidget {
  const _PaymentInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0E1D2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF8E4E16)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF8A735F),
                    fontFamily: 'TomatoGrotesk',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: valueColor ?? const Color(0xFF303030),
                    fontFamily: 'TomatoGrotesk',
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
