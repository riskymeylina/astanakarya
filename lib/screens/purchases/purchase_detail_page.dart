import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../models/purchase_order_model.dart';
import '../../services/auth_service.dart';
import '../../services/purchase_service.dart';
import '../../widgets/braga_page_header.dart';
import 'widgets/purchase_theme.dart';
import 'widgets/payment_info_card.dart';

class PurchaseDetailPage extends StatefulWidget {
  final int purchaseId;
  const PurchaseDetailPage({super.key, required this.purchaseId});

  @override
  State<PurchaseDetailPage> createState() => _PurchaseDetailPageState();
}

class _PurchaseDetailPageState extends State<PurchaseDetailPage> {
  final PurchaseService _purchaseService = PurchaseService();
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
  final NumberFormat _priceFormat = NumberFormat.currency(
    locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0,
  );

  bool _isLoading = true;
  String? _errorMessage;
  PurchaseOrderModel? _order;

  String get _userRole =>
      (AuthService().getSession()?['role']?.toString() ?? UserRoles.pembeli).toLowerCase();

  bool get _isStaff => _userRole == UserRoles.staf;
  bool get _isAdmin => _userRole == UserRoles.admin;
  bool get _isBuyer => _userRole == UserRoles.pembeli;

  @override
  void initState() {
    super.initState();
    _preparePage();
  }

  Future<void> _preparePage() async {
    await initializeDateFormatting('id_ID');
    await _loadOrder();
  }

  Future<void> _loadOrder() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final response = await _purchaseService
          .getOrderDetail(widget.purchaseId)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Koneksi timeout. Periksa jaringan Anda.'),
          );

      if (!mounted) return;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        setState(() {
          _errorMessage = _purchaseService.parseMessage(response.body);
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _order = _purchaseService.parseOrder(response.body);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? value) {
    final parsed = DateTime.tryParse(value ?? '');
    if (parsed == null) return '-';
    return _dateFormat.format(parsed.toLocal());
  }

  String _formatDateShort(String? value) {
    final parsed = DateTime.tryParse(value ?? '');
    if (parsed == null) return '-';
    return DateFormat('dd MMM yyyy', 'id_ID').format(parsed.toLocal());
  }

  String _formatTime(String? value) {
    final parsed = DateTime.tryParse(value ?? '');
    if (parsed == null) return '';
    return '${DateFormat('HH:mm', 'id_ID').format(parsed.toLocal())} WIB';
  }

  String _formatPrice(double value) => _priceFormat.format(value);

  Future<void> _confirmOrder(PurchaseOrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Pemesanan', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Konfirmasi pemesanan "${order.propertyTitle}" oleh ${order.buyerNameSnapshot}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1F7A45)),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Tampilkan loading
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF1F7A45))),
    );

    final response = await _purchaseService.updateOrderStatus(
      purchaseId: order.id,
      status: 'confirmed',
    );

    if (!mounted) return;
    Navigator.of(context).pop(); // tutup loading

    if (response.statusCode >= 200 && response.statusCode < 300) {
      await _loadOrder();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: const Color(0xFFF0FFF5),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F7A45).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, size: 40, color: Color(0xFF1F7A45)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pesanan Dikonfirmasi!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1A3A2A), fontFamily: 'TomatoGrotesk'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pemesanan "${order.propertyTitle}" berhasil dikonfirmasi. Status pesanan telah diperbarui.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF3D6B50), height: 1.5, fontFamily: 'TomatoGrotesk'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F7A45),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w800, fontFamily: 'TomatoGrotesk')),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_purchaseService.parseMessage(response.body)),
          backgroundColor: const Color(0xFFC0392B),
        ),
      );
    }
  }

  Future<void> _rejectOrder(PurchaseOrderModel order) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tolak Bukti Pembayaran', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tolak bukti pembayaran dari ${order.buyerNameSnapshot}? Pembeli dapat mengunggah ulang setelah ditolak.'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Alasan penolakan',
                hintText: 'Contoh: bukti transfer tidak terlihat jelas',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              final text = reasonController.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(ctx, text);
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC0392B)),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty || !mounted) return;

    // Tampilkan loading
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFFC0392B))),
    );

    final response = await _purchaseService.updateOrderStatus(
      purchaseId: order.id,
      status: 'rejected',
      rejectionReason: reason,
    );

    if (!mounted) return;
    Navigator.of(context).pop(); // tutup loading

    if (response.statusCode >= 200 && response.statusCode < 300) {
      await _loadOrder();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: const Color(0xFFFFF5F5),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC0392B).withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cancel_rounded, size: 40, color: Color(0xFFC0392B)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bukti Ditolak',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF3A1A1A), fontFamily: 'TomatoGrotesk'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bukti pembayaran dari ${order.buyerNameSnapshot} telah ditolak. Pembeli dapat mengunggah ulang.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6D3030), height: 1.5, fontFamily: 'TomatoGrotesk'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC0392B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w800, fontFamily: 'TomatoGrotesk')),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_purchaseService.parseMessage(response.body)),
          backgroundColor: const Color(0xFFC0392B),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: _buildScaffoldBody(),
    );
  }

  Widget _buildScaffoldBody() {
    if (_isLoading) return _buildLoadingState();
    if (_errorMessage != null) return _buildErrorState();
    final order = _order;
    if (order == null) return _buildEmptyState();
    return _buildContent(order);
  }

  // ── LOADING STATE ────────────────────────────────────────────────────────────
  Widget _buildLoadingState() {
    return Column(
      children: [
        _buildHeroBanner(null),
        const Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(0xFF8B4513),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Memuat detail pemesanan...',
                  style: TextStyle(fontSize: 14, color: Color(0xFF8A7563)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── ERROR STATE ──────────────────────────────────────────────────────────────
  Widget _buildErrorState() {
    return Column(
      children: [
        _buildHeroBanner(null),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFE0D6)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE8E6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.wifi_off_rounded, color: Color(0xFFC0392B), size: 28),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Gagal memuat data',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF888888), height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _loadOrder,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF8B4513),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Coba lagi', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── EMPTY STATE ──────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Column(
      children: [
        _buildHeroBanner(null),
        const Expanded(
          child: Center(
            child: Text('Data pemesanan tidak ditemukan.', style: TextStyle(color: Color(0xFF888888))),
          ),
        ),
      ],
    );
  }

  // ── HERO BANNER ──────────────────────────────────────────────────────────────
  Widget _buildHeroBanner(PurchaseOrderModel? order) {
    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(14, 12, 14, 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5C1E04), Color(0xFF8F4E1E)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5C1E04).withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Detail Pemesanan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'TomatoGrotesk',
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (order != null) ...[
                    Text(
                      order.propertyTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFEED9C4),
                        height: 1.3,
                        fontFamily: 'TomatoGrotesk',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ] else
                    const Text(
                      'Memuat informasi...',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFEED9C4),
                        fontFamily: 'TomatoGrotesk',
                      ),
                    ),
                ],
              ),
            ),
            if (order != null) ...[
              const SizedBox(width: 12),
              _buildStatusBadge(order.status),
            ],
          ],
        ),
      ),
    );
  }

  // ── MAIN CONTENT ─────────────────────────────────────────────────────────────
  Widget _buildContent(PurchaseOrderModel order) {
    return Column(
      children: [
        _buildHeroBanner(order),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadOrder,
            color: const Color(0xFF8B4513),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              children: [
                // ── PROPERTI INFO ────────────────────────────────────────────
                _buildPropertyCard(order),
                const SizedBox(height: 14),

                // ── RINGKASAN TRANSAKSI ──────────────────────────────────────
                _buildTransactionSummaryCard(order),
                const SizedBox(height: 14),

                // ── INFORMASI PEMBAYARAN ─────────────────────────────────────
                _buildPaymentCard(order),
                const SizedBox(height: 14),

                // ── DATA BUYER ───────────────────────────────────────────────
                _buildBuyerCard(order),
                const SizedBox(height: 14),

                // ── BUKTI & VERIFIKASI ───────────────────────────────────────
                _buildProofCard(order),
                const SizedBox(height: 20),

                // ── TOMBOL AKSI ──────────────────────────────────────────────
                _buildActionButtons(order),
                if (_isStaff) const SizedBox(height: 10),
                if (_isStaff) _buildStaffNotice(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── PROPERTI INFO CARD ───────────────────────────────────────────────────────
  Widget _buildPropertyCard(PurchaseOrderModel order) {
    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: (order.propertyThumbnailUrl?.trim().isNotEmpty ?? false)
                ? Image.network(
                    order.propertyThumbnailUrl!,
                    width: 88, height: 72, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _ImgFallback(width: 88, height: 72),
                  )
                : const _ImgFallback(width: 88, height: 72),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.propertyTitle,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF888888)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        order.propertyLocation,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF888888)),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateShort(order.createdAt),
                      style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '• ${_formatTime(order.createdAt)}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── RINGKASAN TRANSAKSI CARD ─────────────────────────────────────────────────
  Widget _buildTransactionSummaryCard(PurchaseOrderModel order) {
    return _Card(
      title: 'Ringkasan Transaksi',
      titleIcon: Icons.receipt_outlined,
      child: Column(
        children: [
          // Total Harga (highlight box)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF5C1E04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Nilai Transaksi', style: TextStyle(fontSize: 11, color: Color(0xFFEED9C4))),
                const SizedBox(height: 4),
                Text(
                  _formatPrice(order.propertyPrice),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _DataRow(icon: Icons.credit_card_outlined, label: 'Metode Pembayaran', value: order.paymentMethod),
          _DataRow(icon: Icons.calendar_month_outlined, label: 'Tanggal Pesan', value: _formatDate(order.createdAt)),
          if ((order.notes ?? '').trim().isNotEmpty)
            _DataRow(icon: Icons.notes_outlined, label: 'Catatan', value: order.notes!),
        ],
      ),
    );
  }

  // ── INFORMASI PEMBAYARAN CARD ────────────────────────────────────────────────
  Widget _buildPaymentCard(PurchaseOrderModel order) {
    return _Card(
      title: 'Informasi Pembayaran',
      titleIcon: Icons.account_balance_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _PaymentDetailCol(
                icon: Icons.calendar_today_outlined,
                label: 'Tanggal Transfer',
                value: _formatDateShort(order.paymentProofUploadedAt),
                sub: _formatTime(order.paymentProofUploadedAt),
              )),
              Expanded(child: _PaymentDetailCol(
                icon: Icons.credit_card_outlined,
                label: 'Metode',
                value: order.paymentMethod,
                sub: '',
              )),
            ],
          ),
        ],
      ),
    );
  }

  // ── BUYER CARD ────────────────────────────────────────────────────────────────
  Widget _buildBuyerCard(PurchaseOrderModel order) {
    return _Card(
      title: 'Data Buyer',
      titleIcon: Icons.person_outline_rounded,
      trailing: OutlinedButton.icon(
        onPressed: () => _showBuyerDetailSheet(order),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF8B4513),
          side: const BorderSide(color: Color(0xFF8B4513)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: const Icon(Icons.open_in_new_rounded, size: 13),
        label: const Text('Lihat Lengkap', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      ),
      child: Column(
        children: [
          // Avatar + Nama row
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(color: Color(0xFFFFD9B0), shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    _getInitials(order.buyerNameSnapshot),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF8E4E16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.buyerNameSnapshot, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
                    if ((order.buyerPhoneSnapshot ?? '').isNotEmpty)
                      Text(order.buyerPhoneSnapshot!, style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                  ],
                ),
              ),
            ],
          ),
          if ((order.buyerAddressSnapshot ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _DataRow(icon: Icons.location_on_outlined, label: 'Alamat', value: order.buyerAddressSnapshot!),
          ],
          if ((order.notes ?? '').trim().isNotEmpty) ...[
            _DataRow(icon: Icons.notes_outlined, label: 'Catatan', value: order.notes!),
          ],
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'B';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  // ── BUKTI & VERIFIKASI CARD ──────────────────────────────────────────────────
  Widget _buildProofCard(PurchaseOrderModel order) {
    final hasProof = (order.paymentProofUrl ?? '').isNotEmpty;
    return _Card(
      title: 'Bukti & Verifikasi',
      titleIcon: Icons.verified_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Bukti Gambar (utama) ──
          if (hasProof) ...[
            GestureDetector(
              onTap: () => _showProofFullScreen(order.paymentProofUrl!),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.network(
                      order.paymentProofUrl!,
                      height: 200, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _ImgFallback(width: double.infinity, height: 140),
                    ),
                    // Overlay label "Ketuk untuk perbesar"
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black.withOpacity(0.55), Colors.transparent],
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.zoom_in_rounded, size: 14, color: Colors.white),
                            SizedBox(width: 5),
                            Text('Ketuk untuk perbesar', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 32, color: Color(0xFFCCCCCC)),
                  SizedBox(height: 6),
                  Text('Bukti pembayaran belum diunggah', style: TextStyle(fontSize: 13, color: Color(0xFF999999))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),

          // ── Meta info ──
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              _MetaChip(label: 'Diunggah', value: _formatDate(order.paymentProofUploadedAt)),
              _MetaChip(label: 'Diproses oleh', value: order.processedByName ?? '-'),
              _MetaChip(label: 'Tanggal proses', value: _formatDate(order.processedAt)),
            ],
          ),

          // ── Alasan penolakan ──
          if ((order.rejectionReason ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFCE8E6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF7C1C1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.cancel_outlined, size: 14, color: Color(0xFFC0392B)),
                    SizedBox(width: 6),
                    Text('Alasan Penolakan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFC0392B))),
                  ]),
                  const SizedBox(height: 4),
                  Text(order.rejectionReason!, style: const TextStyle(fontSize: 13, color: Color(0xFF791F1F), height: 1.4)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }


  // ── TOMBOL AKSI ──────────────────────────────────────────────────────────────
  Widget _buildActionButtons(PurchaseOrderModel order) {
    final canConfirm = _isStaff && (order.status == 'payment_uploaded' || order.status == 'payment_review');
    final showUploadProof = !_isStaff && !_isAdmin && order.canUploadProof;
    final isReupload = order.isRejected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canConfirm) ...[
          FilledButton.icon(
            onPressed: () => _confirmOrder(order),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1F7A45),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
            label: const Text('Konfirmasi Pemesanan', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _rejectOrder(order),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFC0392B),
              side: const BorderSide(color: Color(0xFFE6B0AA)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.cancel_outlined, size: 16),
            label: const Text('Tolak Bukti Pembayaran', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ] else if (showUploadProof) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.pushNamed(
                context, '/upload-payment', arguments: order,
              ).then((_) => _loadOrder()),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1E5FAF),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: Icon(
                isReupload ? Icons.refresh_rounded : Icons.upload_file_rounded,
                size: 16,
              ),
              label: Text(
                isReupload ? 'Upload Ulang Bukti Pembayaran' : 'Upload Bukti Pembayaran',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F6F1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE1D9C9)),
            ),
            child: Text(
              _isStaff
                  ? 'Aksi konfirmasi hanya tersedia saat bukti pembayaran telah diunggah dan menunggu verifikasi.'
                  : 'Pemesanan akan otomatis diperbarui untuk pembeli saat transaksi dikonfirmasi oleh staf.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6D5A47), height: 1.4),
            ),
          ),
        ],
      ],
    );
  }

  // ── STATUS BADGE ─────────────────────────────────────────────────────────────
  Widget _buildStatusBadge(String status) {
    final style = _resolveStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: style.bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 12, color: style.fg),
          const SizedBox(width: 5),
          Text(style.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: style.fg)),
        ],
      ),
    );
  }

  void _showBuyerDetailSheet(PurchaseOrderModel order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BuyerDetailSheet(order: order, total: _formatPrice(order.payableAmount)),
    );
  }

  Widget _buildStaffNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F7EE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB6E2C5)),
      ),
      child: const Text(
        'Konfirmasi pesanan dapat dilakukan di halaman ini oleh staf. Cetak atau bagikan invoice hanya dapat dilakukan melalui akses admin.',
        style: TextStyle(fontSize: 12.5, color: Color(0xFF2F5F3F), height: 1.4),
      ),
    );
  }

  void _showProofFullScreen(String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            InteractiveViewer(
              child: Center(
                child: Image.network(
                  url, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Text('Gagal memuat gambar', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8, right: 8,
              child: IconButton(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── STATUS HELPER ────────────────────────────────────────────────────────────
class _StatusStyle {
  final String label;
  final Color bg;
  final Color fg;
  final IconData icon;
  const _StatusStyle({required this.label, required this.bg, required this.fg, required this.icon});
}

_StatusStyle _resolveStatus(String status) {
  switch (status) {
    case 'confirmed':
      return const _StatusStyle(label: 'Dikonfirmasi', bg: Color(0xFFE6F6EC), fg: Color(0xFF1F7A45), icon: Icons.check_circle_outline_rounded);
    case 'rejected':
      return const _StatusStyle(label: 'Ditolak', bg: Color(0xFFFCE8E6), fg: Color(0xFFC0392B), icon: Icons.cancel_outlined);
    case 'cancelled':
      return const _StatusStyle(label: 'Dibatalkan', bg: Color(0xFFF1F1F1), fg: Color(0xFF6B7280), icon: Icons.do_not_disturb_on_outlined);
    case 'payment_uploaded':
      return const _StatusStyle(label: 'Bukti Diunggah', bg: Color(0xFFE3EFFD), fg: Color(0xFF1E5FAF), icon: Icons.cloud_upload_outlined);
    case 'payment_review':
      return const _StatusStyle(label: 'Sedang Diverifikasi', bg: Color(0xFFFFF3E0), fg: Color(0xFFE65C00), icon: Icons.remove_red_eye_outlined);
    default:
      return const _StatusStyle(label: 'Menunggu Pembayaran', bg: Color(0xFFFFF3D9), fg: Color(0xFF9A6700), icon: Icons.hourglass_empty_rounded);
  }
}

// ── REUSABLE WIDGETS ─────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final String? title;
  final IconData? titleIcon;
  final Widget? trailing;
  final Widget child;

  const _Card({this.title, this.titleIcon, this.trailing, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFEFEF)),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  if (titleIcon != null) ...[
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(color: const Color(0xFFFFF2E0), borderRadius: BorderRadius.circular(7)),
                      child: Icon(titleIcon!, color: const Color(0xFFCB7D2A), size: 15),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(title!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF5F5F5)),
            const SizedBox(height: 4),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DataRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: const Color(0xFFCB7D2A)),
          const SizedBox(width: 10),
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
          ),
          Expanded(
            child: Text(
              value.trim().isEmpty ? '-' : value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentDetailCol extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final bool hasButton;
  final VoidCallback? onButton;

  const _PaymentDetailCol({
    required this.icon, required this.label, required this.value, required this.sub,
    this.hasButton = false, this.onButton,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 11, color: const Color(0xFF888888)),
            const SizedBox(width: 4),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF888888)), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)), maxLines: 1, overflow: TextOverflow.ellipsis),
          if (sub.isNotEmpty)
            Text(sub, style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
          if (hasButton && onButton != null) ...[
            const SizedBox(height: 5),
            GestureDetector(
              onTap: onButton,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3EFFD),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility_outlined, size: 11, color: Color(0xFF1E5FAF)),
                    SizedBox(width: 3),
                    Text('Lihat', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1E5FAF))),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetaChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF8F1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEE0D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF8A6A48))),
          const SizedBox(height: 3),
          Text(value.trim().isEmpty ? '-' : value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF3A2B1F))),
        ],
      ),
    );
  }
}

class _ImgFallback extends StatelessWidget {
  final double width;
  final double height;

  const _ImgFallback({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width == double.infinity ? null : width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8C7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.home_work_rounded, color: Color(0xFF8F4E1E)),
    );
  }
}

// ── BUYER DETAIL BOTTOM SHEET ─────────────────────────────────────────────────
class _BuyerDetailSheet extends StatelessWidget {
  final PurchaseOrderModel order;
  final String total;

  const _BuyerDetailSheet({required this.order, required this.total});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        builder: (context, scrollController) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          decoration: const BoxDecoration(
            color: Color(0xFFFFF4E8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(18, 10, 18, 24 + MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: const Color(0xFF6D5540), borderRadius: BorderRadius.circular(999)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 46, height: 46,
                      decoration: const BoxDecoration(color: Color(0xFFFFD9B0), shape: BoxShape.circle),
                      child: const Icon(Icons.person_rounded, color: Color(0xFF8E4E16)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Detail Pemesan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF171717))),
                          Text('Data pemesan dan ringkasan pesanan', style: TextStyle(fontSize: 12, color: Color(0xFF8A735F))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SheetCard(
                  title: 'Data Pemesan',
                  icon: Icons.badge_outlined,
                  rows: [
                    _SheetRow('Nama', order.buyerNameSnapshot),
                    _SheetRow('WhatsApp', order.buyerPhoneSnapshot ?? '-'),
                    _SheetRow('Alamat', order.buyerAddressSnapshot ?? '-'),
                    _SheetRow('Catatan', order.notes ?? '-'),
                  ],
                ),
                const SizedBox(height: 10),
                _SheetCard(
                  title: 'Rincian Pesanan',
                  icon: Icons.receipt_long_rounded,
                  rows: [
                    _SheetRow('Properti', order.propertyTitle),
                    _SheetRow('Metode', order.paymentMethod),
                    _SheetRow('Total', total, emphasized: true),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B4513),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_SheetRow> rows;

  const _SheetCard({required this.title, required this.icon, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0DCC8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: const Color(0xFF8E4E16)),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF171717))),
          ]),
          const SizedBox(height: 10),
          ...rows,
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const _SheetRow(this.label, this.value, {this.emphasized = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF8A735F))),
          const SizedBox(height: 2),
          Text(
            value.trim().isEmpty ? '-' : value,
            style: TextStyle(
              fontSize: emphasized ? 15 : 13,
              fontWeight: emphasized ? FontWeight.w900 : FontWeight.w700,
              color: emphasized ? const Color(0xFF8E4E16) : const Color(0xFF303030),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}