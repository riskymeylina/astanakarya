import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'purchase_theme.dart';

class UploadArea extends StatefulWidget {
  const UploadArea({
    super.key,
    required this.onImageSelected,
    required this.onImageRemoved,
    this.imageFile,
    this.acceptedFormats = const ['jpg', 'jpeg', 'png', 'webp'],
    this.maxSizeBytes = 8388608, // 8 MB
  });

  final Function(XFile) onImageSelected;
  final Function() onImageRemoved;
  final XFile? imageFile;
  final List<String> acceptedFormats;
  final int maxSizeBytes;

  @override
  State<UploadArea> createState() => _UploadAreaState();
}

class _UploadAreaState extends State<UploadArea>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  bool _isDragging = false;
  late AnimationController _animationController;
  late Animation<Offset> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _floatingAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, -0.5),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        await _validateAndSelectImage(image);
      }
    } catch (_) {
      _showError('Gagal mengambil gambar');
    }
  }

  Future<void> _validateAndSelectImage(XFile image) async {
    final fileExtension = image.name.split('.').last.toLowerCase();

    if (!widget.acceptedFormats.contains(fileExtension)) {
      _showError(
        'Format ${fileExtension.toUpperCase()} tidak didukung. Gunakan JPG, PNG, atau WEBP.',
      );
      return;
    }

    final fileSizeInBytes = kIsWeb
        ? await image.length()
        : File(image.path).lengthSync();
    if (fileSizeInBytes > widget.maxSizeBytes) {
      _showError(
        'Ukuran file terlalu besar. Maksimal 8 MB, file Anda ${(fileSizeInBytes / 1024 / 1024).toStringAsFixed(2)} MB.',
      );
      return;
    }

    widget.onImageSelected(image);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: PurchaseTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PurchaseTheme.radiusMedium),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageFile != null) {
      return _buildImagePreview();
    }

    return GestureDetector(
      onTap: () => _pickImage(ImageSource.gallery),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: PurchaseTheme.durationShort,
          decoration: BoxDecoration(
            color: _isDragging ? PurchaseTheme.lightCream : Colors.white,
            borderRadius: BorderRadius.circular(PurchaseTheme.radiusXL),
            border: Border.all(
              color: _isDragging ? PurchaseTheme.cream : PurchaseTheme.border,
              width: _isDragging ? 2 : 1.5,
              style: BorderStyle.solid,
            ),
            boxShadow: _isDragging
                ? [
                    BoxShadow(
                      color: PurchaseTheme.cream.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PurchaseTheme.spacing24,
              vertical: PurchaseTheme.spacing32,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlideTransition(
                  position: _floatingAnimation,
                  child: Icon(
                    Icons.cloud_upload_rounded,
                    size: 48,
                    color: _isDragging
                        ? PurchaseTheme.cream
                        : PurchaseTheme.hintText,
                  ),
                ),
                const SizedBox(height: PurchaseTheme.spacing16),
                Text(
                  'Seret bukti pembayaran di sini',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: PurchaseTheme.darkBrown,
                    fontFamily: 'TomatoGrotesk',
                  ),
                ),
                const SizedBox(height: PurchaseTheme.spacing8),
                Text(
                  'atau klik untuk memilih dari galeri',
                  textAlign: TextAlign.center,
                  style: PurchaseTheme.hint,
                ),
                const SizedBox(height: PurchaseTheme.spacing16),
                Container(height: 1, color: PurchaseTheme.border),
                const SizedBox(height: PurchaseTheme.spacing16),
                Text(
                  'Format: JPG, PNG, WEBP | Maks: 8 MB',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: PurchaseTheme.hintText,
                    fontFamily: 'TomatoGrotesk',
                  ),
                ),
                const SizedBox(height: PurchaseTheme.spacing16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: PurchaseTheme.spacing12,
                  runSpacing: PurchaseTheme.spacing12,
                  children: [
                    SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_rounded, size: 18),
                        label: const Text('Galeri'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: PurchaseTheme.brown,
                          side: const BorderSide(color: PurchaseTheme.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              PurchaseTheme.radiusMedium,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: PurchaseTheme.spacing16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_rounded, size: 18),
                        label: const Text('Kamera'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: PurchaseTheme.brown,
                          side: const BorderSide(color: PurchaseTheme.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              PurchaseTheme.radiusMedium,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: PurchaseTheme.spacing16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(PurchaseTheme.radiusXL),
              child: kIsWeb
                  ? Image.network(
                      widget.imageFile!.path,
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(widget.imageFile!.path),
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.cover,
                    ),
            ),
            Positioned(
              top: PurchaseTheme.spacing12,
              right: PurchaseTheme.spacing12,
              child: Container(
                padding: const EdgeInsets.all(PurchaseTheme.spacing8),
                decoration: BoxDecoration(
                  color: PurchaseTheme.success.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(
                    PurchaseTheme.radiusSmall,
                  ),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: PurchaseTheme.spacing12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
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
                onPressed: widget.onImageRemoved,
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
}
