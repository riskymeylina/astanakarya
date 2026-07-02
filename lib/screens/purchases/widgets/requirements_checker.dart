import 'package:flutter/material.dart';
import 'purchase_theme.dart';

class RequirementsChecker extends StatefulWidget {
  const RequirementsChecker({super.key, this.showOnOpen = false});

  final bool showOnOpen;

  @override
  State<RequirementsChecker> createState() => _RequirementsCheckerState();
}

class _RequirementsCheckerState extends State<RequirementsChecker> {
  bool _hasShownModal = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.showOnOpen && !_hasShownModal) {
      _hasShownModal = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showRequirementsModal(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: PurchaseTheme.cardDecoration(),
      padding: const EdgeInsets.all(PurchaseTheme.spacing16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: PurchaseTheme.orangeBg,
              borderRadius: BorderRadius.circular(PurchaseTheme.radiusSmall),
            ),
            child: const Icon(
              Icons.checklist_rounded,
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
                  'Persyaratan Bukti Pembayaran',
                  style: PurchaseTheme.heading2,
                ),
                SizedBox(height: PurchaseTheme.spacing4),
                Text(
                  'Lihat syarat bukti pembayaran sebelum mengunggah.',
                  style: PurchaseTheme.bodySecondary,
                ),
              ],
            ),
          ),
          const SizedBox(width: PurchaseTheme.spacing12),
          OutlinedButton(
            onPressed: () => _showRequirementsModal(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: PurchaseTheme.brown,
              side: const BorderSide(color: PurchaseTheme.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PurchaseTheme.radiusMedium),
              ),
            ),
            child: const Text('Lihat'),
          ),
        ],
      ),
    );
  }

  void _showRequirementsModal(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PurchaseTheme.radiusXL),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: PurchaseTheme.orangeBg,
                borderRadius: BorderRadius.circular(PurchaseTheme.radiusSmall),
              ),
              child: const Icon(
                Icons.checklist_rounded,
                color: PurchaseTheme.brown,
                size: 22,
              ),
            ),
            const SizedBox(width: PurchaseTheme.spacing12),
            const Expanded(
              child: Text(
                'Persyaratan Bukti Pembayaran',
                style: PurchaseTheme.heading2,
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                _RequirementItem(
                  icon: Icons.receipt_rounded,
                  title: 'Bukti Pembayaran Lengkap',
                  description:
                      'Harus menampilkan kwitansi atau konfirmasi pembayaran yang jelas',
                  isRequired: true,
                ),
                SizedBox(height: PurchaseTheme.spacing12),
                _RequirementItem(
                  icon: Icons.monetization_on_rounded,
                  title: 'Nominal Sesuai',
                  description:
                      'Jumlah pembayaran harus sesuai dengan total pesanan properti',
                  isRequired: true,
                ),
                SizedBox(height: PurchaseTheme.spacing12),
                _RequirementItem(
                  icon: Icons.person_rounded,
                  title: 'Nama Penerima Terlihat',
                  description:
                      'Nama penerima atau rekening harus terlihat jelas di bukti pembayaran',
                  isRequired: true,
                ),
                SizedBox(height: PurchaseTheme.spacing12),
                _RequirementItem(
                  icon: Icons.access_time_rounded,
                  title: 'Tanggal dan Waktu Terlihat',
                  description:
                      'Tanggal dan jam transaksi harus terlihat dengan jelas',
                  isRequired: true,
                ),
                SizedBox(height: PurchaseTheme.spacing12),
                _RequirementItem(
                  icon: Icons.image_rounded,
                  title: 'Format File',
                  description:
                      'JPG, PNG, atau WEBP (transparansi PNG akan dikonversi)',
                  isRequired: false,
                ),
                SizedBox(height: PurchaseTheme.spacing12),
                _RequirementItem(
                  icon: Icons.storage_rounded,
                  title: 'Ukuran File',
                  description: 'Maksimal 8 MB untuk performa optimal',
                  isRequired: false,
                ),
                SizedBox(height: PurchaseTheme.spacing12),
                _RequirementItem(
                  icon: Icons.image_rounded,
                  title: 'Kualitas Gambar',
                  description:
                      'Gambar harus jelas dan tidak blur agar dapat diverifikasi',
                  isRequired: true,
                ),
              ],
            ),
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: PurchaseTheme.cream,
                foregroundColor: PurchaseTheme.darkBrown,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    PurchaseTheme.radiusMedium,
                  ),
                ),
              ),
              child: const Text(
                'Saya mengerti',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontFamily: 'TomatoGrotesk',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  const _RequirementItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.isRequired,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PurchaseTheme.spacing12),
      decoration: BoxDecoration(
        color: isRequired
            ? PurchaseTheme.warning.withOpacity(0.05)
            : PurchaseTheme.background,
        borderRadius: BorderRadius.circular(PurchaseTheme.radiusMedium),
        border: Border.all(
          color: isRequired
              ? PurchaseTheme.warning.withOpacity(0.2)
              : PurchaseTheme.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isRequired
                  ? PurchaseTheme.warning.withOpacity(0.15)
                  : PurchaseTheme.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(PurchaseTheme.radiusSmall),
            ),
            child: Icon(
              isRequired ? icon : Icons.check_circle_rounded,
              color: isRequired ? PurchaseTheme.warning : PurchaseTheme.success,
              size: 16,
            ),
          ),
          const SizedBox(width: PurchaseTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: PurchaseTheme.darkBrown,
                    fontFamily: 'TomatoGrotesk',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: PurchaseTheme.hintText,
                    fontFamily: 'TomatoGrotesk',
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (isRequired)
            const Padding(
              padding: EdgeInsets.only(left: PurchaseTheme.spacing8),
              child: Text(
                '*',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: PurchaseTheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
