import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'purchase_theme.dart';

class PaymentProofPreview extends StatefulWidget {
  const PaymentProofPreview({
    super.key,
    required this.imageFile,
    required this.onRemove,
    required this.onReplace,
  });

  final XFile imageFile;
  final Function() onRemove;
  final Function() onReplace;

  @override
  State<PaymentProofPreview> createState() => _PaymentProofPreviewState();
}

class _PaymentProofPreviewState extends State<PaymentProofPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _checkScale;

  String? _fileSize;
  String? _imageDimensions;
  String? _qualityStatus;
  Color? _qualityColor;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _checkScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    _checkController.forward();
    _analyzeImage();
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  void _analyzeImage() {
    _readImageInfo();
  }

  Future<void> _readImageInfo() async {
    try {
      final imageBytes = kIsWeb
          ? await widget.imageFile.readAsBytes()
          : File(widget.imageFile.path).readAsBytesSync();
      _fileSize = _formatFileSize(imageBytes.length);

      final image = img.decodeImage(imageBytes);
      if (image != null) {
        _imageDimensions = '${image.width} x ${image.height} px';
        _determineQuality(image);
      }

      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      // If image analysis fails, continue without dimension info
    }
  }

  void _determineQuality(img.Image image) {
    final width = image.width;
    final height = image.height;
    final minDimension = width < height ? width : height;

    if (minDimension >= 800 && minDimension <= 2000) {
      _qualityStatus = 'Sangat Baik';
      _qualityColor = const Color(0xFF1F7A45);
    } else if (minDimension >= 600 && minDimension < 800) {
      _qualityStatus = 'Baik';
      _qualityColor = const Color(0xFF27AE60);
    } else if (minDimension >= 400) {
      _qualityStatus = 'Cukup';
      _qualityColor = const Color(0xFFF39C12);
    } else {
      _qualityStatus = 'Kurang Jelas';
      _qualityColor = PurchaseTheme.error;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }
    return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(PurchaseTheme.radiusXL),
              child: kIsWeb
                  ? Image.network(
                      widget.imageFile.path,
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(widget.imageFile.path),
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.cover,
                    ),
            ),
            Positioned(
              top: PurchaseTheme.spacing12,
              right: PurchaseTheme.spacing12,
              child: ScaleTransition(
                scale: _checkScale,
                child: Container(
                  padding: const EdgeInsets.all(PurchaseTheme.spacing10),
                  decoration: BoxDecoration(
                    color: PurchaseTheme.success.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(
                      PurchaseTheme.radiusMedium,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: PurchaseTheme.spacing16),

        // File info cards
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                icon: Icons.storage_rounded,
                label: 'Ukuran File',
                value: _fileSize ?? '-',
              ),
            ),
            const SizedBox(width: PurchaseTheme.spacing12),
            Expanded(
              child: _buildInfoCard(
                icon: Icons.image_rounded,
                label: 'Dimensi',
                value: _imageDimensions ?? '-',
              ),
            ),
          ],
        ),

        const SizedBox(height: PurchaseTheme.spacing12),

        // Quality indicator
        if (_qualityStatus != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(PurchaseTheme.spacing12),
            decoration: BoxDecoration(
              color: _qualityColor!.withOpacity(0.08),
              borderRadius: BorderRadius.circular(PurchaseTheme.radiusMedium),
              border: Border.all(color: _qualityColor!.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  _qualityStatus == 'Kurang Jelas'
                      ? Icons.warning_rounded
                      : Icons.check_circle_rounded,
                  color: _qualityColor!,
                  size: 18,
                ),
                const SizedBox(width: PurchaseTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kualitas Gambar',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: PurchaseTheme.hintText,
                          fontFamily: 'TomatoGrotesk',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _qualityStatus!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _qualityColor!,
                          fontFamily: 'TomatoGrotesk',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 28,
                  width: 4,
                  decoration: BoxDecoration(
                    color: _qualityColor!,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: PurchaseTheme.spacing16),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onReplace,
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Ganti'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: PurchaseTheme.brown,
                  side: const BorderSide(color: PurchaseTheme.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      PurchaseTheme.radiusMedium,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: PurchaseTheme.spacing12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: PurchaseTheme.spacing12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onRemove,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Hapus'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: PurchaseTheme.error,
                  side: const BorderSide(color: PurchaseTheme.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      PurchaseTheme.radiusMedium,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: PurchaseTheme.spacing12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(PurchaseTheme.spacing12),
      decoration: BoxDecoration(
        color: PurchaseTheme.background,
        borderRadius: BorderRadius.circular(PurchaseTheme.radiusMedium),
        border: Border.all(color: PurchaseTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: PurchaseTheme.brown),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: PurchaseTheme.hintText,
                  fontFamily: 'TomatoGrotesk',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: PurchaseTheme.darkBrown,
              fontFamily: 'TomatoGrotesk',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
