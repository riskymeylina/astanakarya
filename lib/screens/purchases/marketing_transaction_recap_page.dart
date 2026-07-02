import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../models/purchase_order_model.dart';
import '../../services/purchase_service.dart';
import 'widgets/staff_payment_summary_card.dart';
import 'purchase_detail_page.dart';

class MarketingTransactionRecapPage extends StatefulWidget {
  const MarketingTransactionRecapPage({super.key});

  @override
  State<MarketingTransactionRecapPage> createState() =>
      _MarketingTransactionRecapPageState();
}

class _MarketingTransactionRecapPageState
    extends State<MarketingTransactionRecapPage> {
  final PurchaseService _purchaseService = PurchaseService();
  final NumberFormat _priceFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

  bool _isLoading = true;
  bool _isLocaleReady = false;
  String? _errorMessage;
  List<PurchaseOrderModel> _orders = const [];
  List<int> _availableYears = [];
  DateTime? _filterFrom;
  DateTime? _filterTo;
  int? _filterMonth;
  int? _filterYear;

  // Pagination
  int _currentPage = 1;
  int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _preparePage();
  }

  Future<void> _preparePage() async {
    await initializeDateFormatting('id_ID');
    if (!mounted) return;
    setState(() => _isLocaleReady = true);
    await _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _purchaseService.getAllOrders(
      from: _filterFrom,
      to: _filterTo,
      month: _filterMonth,
      year: _filterYear,
    );
    if (!mounted) return;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      setState(() {
        _errorMessage = _purchaseService.parseMessage(response.body);
        _isLoading = false;
      });
      return;
    }

    final parsedOrders = _purchaseService.parseOrders(response.body);

    setState(() {
      _orders = parsedOrders;
      _currentPage = 1;
      _isLoading = false;

      if (_availableYears.isEmpty ||
          (_filterFrom == null &&
              _filterTo == null &&
              _filterMonth == null &&
              _filterYear == null)) {
        final yearsSet = <int>{};
        for (final order in parsedOrders) {
          if (order.createdAt != null) {
            final dt = DateTime.tryParse(order.createdAt!);
            if (dt != null) {
              yearsSet.add(dt.year);
            }
          }
        }
        yearsSet.add(DateTime.now().year);
        _availableYears = yearsSet.toList()..sort((a, b) => b.compareTo(a));
      }
    });
  }

  List<PurchaseOrderModel> get _pagedOrders {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, _orders.length);
    if (start >= _orders.length) return [];
    return _orders.sublist(start, end);
  }

  int get _totalPages => (_orders.length / _itemsPerPage).ceil().clamp(1, 9999);

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

  String _maskPhone(String phone) {
    if (phone.length <= 4) return phone;
    return '${phone.substring(0, 4)}-****-${phone.substring(phone.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: RefreshIndicator(onRefresh: _loadOrders, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // ── HERO BANNER COKLAT ────────────────────────────────────────────
        SliverToBoxAdapter(child: _buildHeroBanner()),

        // ── KONTEN UTAMA ──────────────────────────────────────────────────
        if (_isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_errorMessage != null)
          SliverFillRemaining(child: _buildErrorState())
        else ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(),
                  const SizedBox(height: 24),
                  _buildTransactionTable(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── HERO BANNER ──────────────────────────────────────────────────────────
  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7B3A10), Color(0xFF4A1E08)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Opacity(
              opacity: 0.08,
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withAlpha(70),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Rekap Data Transaksi',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Kelola dan pantau semua transaksi pemesanan properti',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withAlpha(210),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── FILTER SECTION ───────────────────────────────────────────────────────
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEFEFEF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.tune_rounded, size: 15, color: Color(0xFF8B4513)),
          const SizedBox(width: 8),
          const Text(
            'Filter:',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildDateField(
              'Tanggal awal',
              _filterFrom,
              () => _pickDate(isFrom: true),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildDateField(
              'Tanggal akhir',
              _filterTo,
              () => _pickDate(isFrom: false),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildDropdownField<int?>(
              icon: Icons.calendar_month_rounded,
              hint: 'Semua bulan',
              value: _filterMonth,
              items: [
                const DropdownMenuItem(value: null, child: Text('Semua bulan')),
                ...List.generate(
                  12,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text(
                      _isLocaleReady
                          ? DateFormat.MMMM(
                              'id_ID',
                            ).format(DateTime(2024, i + 1))
                          : '${i + 1}',
                    ),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _filterMonth = v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildDropdownField<int?>(
              icon: Icons.event_note_rounded,
              hint: 'Semua tahun',
              value: _filterYear,
              items: [
                const DropdownMenuItem(value: null, child: Text('Semua tahun')),
                ..._availableYears.map(
                  (y) => DropdownMenuItem(value: y, child: Text('$y')),
                ),
              ],
              onChanged: (v) => setState(() => _filterYear = v),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _filterFrom = null;
                _filterTo = null;
                _filterMonth = null;
                _filterYear = null;
              });
              _loadOrders();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF8B4513),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Reset',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: _loadOrders,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF8B4513),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.filter_alt_rounded, size: 14),
            label: const Text(
              'Terapkan',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? value, VoidCallback onTap) {
    final formatted = value == null
        ? null
        : (_isLocaleReady
              ? DateFormat('dd MMM yyyy', 'id_ID').format(value)
              : '${value.day}/${value.month}/${value.year}');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDDDDDD)),
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFFAFAFA),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.event_outlined,
              size: 14,
              color: Color(0xFF8B4513),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF999999),
                    ),
                  ),
                  Text(
                    formatted ?? 'Pilih tanggal',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: formatted != null
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFFBBBBBB),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: Color(0xFF999999),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required IconData icon,
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T?>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFFAFAFA),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF8B4513)),
          const SizedBox(width: 6),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T?>(
                value: value,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF999999),
                  size: 14,
                ),
                hint: Text(
                  hint,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFBBBBBB),
                  ),
                ),
                items: items,
                onChanged: onChanged,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _filterFrom : _filterTo) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isFrom)
        _filterFrom = picked;
      else
        _filterTo = picked;
    });
  }

  // ── TABEL TRANSAKSI TERBARU ───────────────────────────────────────────────
  Widget _buildTransactionTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEFEFEF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Row(
              children: [
                const Text(
                  'Transaksi Terbaru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Spacer(),
                if (_orders.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_orders.length} transaksi',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8B4513),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (_orders.isEmpty)
            _buildEmptyState()
          else ...[
            // Header tabel
            _buildTableHeader(),
            const Divider(height: 1, color: Color(0xFFEFEFEF)),
            // Rows
            ..._pagedOrders.map((order) => _buildTableRow(order)),
            // Footer pagination
            _buildPaginationFooter(),
          ],
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: const Color(0xFFFAFAFA),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: const Row(
        children: [
          Expanded(flex: 4, child: _TableHeaderCell('Properti')),
          Expanded(flex: 3, child: _TableHeaderCell('Buyer')),
          Expanded(flex: 2, child: _TableHeaderCell('Status')),
          Expanded(flex: 3, child: _TableHeaderCell('Tanggal Transaksi')),
          Expanded(flex: 3, child: _TableHeaderCell('Nilai Transaksi')),
          SizedBox(width: 110, child: _TableHeaderCell('Aksi')),
        ],
      ),
    );
  }

  Widget _buildTableRow(PurchaseOrderModel order) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              // Properti
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 48,
                        height: 48,
                        color: const Color(0xFFF0E6D8),
                        child: const Icon(
                          Icons.home_outlined,
                          color: Color(0xFF8B4513),
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.propertyTitle,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A1A),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 11,
                                color: Color(0xFF999999),
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  order.propertyLocation,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF999999),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Buyer
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.buyerNameSnapshot,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((order.buyerPhoneSnapshot ?? '').isNotEmpty)
                      Text(
                        _maskPhone(order.buyerPhoneSnapshot!),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF888888),
                        ),
                      ),
                  ],
                ),
              ),
              // Status
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: StaffStatusBadge(status: order.status),
                ),
              ),
              // Tanggal
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: Color(0xFF888888),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateShort(order.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        _formatTime(order.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Nilai
              Expanded(
                flex: 3,
                child: Text(
                  _priceFormat.format(order.propertyPrice),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF8B4513),
                  ),
                ),
              ),
              // Aksi
              SizedBox(
                width: 110,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PurchaseDetailPage(purchaseId: order.id),
                      ),
                    );
                    _loadOrders();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: const Color(0xFF8B4513),
                    side: const BorderSide(color: Color(0xFF8B4513)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 12),
                  label: const Text(
                    'Lihat Detail',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF5F5F5)),
      ],
    );
  }

  Widget _buildPaginationFooter() {
    final startItem = (_currentPage - 1) * _itemsPerPage + 1;
    final endItem = (_currentPage * _itemsPerPage).clamp(0, _orders.length);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEFEFEF))),
        color: Color(0xFFFAFAFA),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Menampilkan $startItem – $endItem dari ${_orders.length} transaksi',
            style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
          ),
          const Spacer(),
          // Prev
          _PaginationButton(
            icon: Icons.chevron_left_rounded,
            enabled: _currentPage > 1,
            onTap: () => setState(() => _currentPage--),
          ),
          const SizedBox(width: 4),
          // Page number
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF8B4513),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$_currentPage',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Next
          _PaginationButton(
            icon: Icons.chevron_right_rounded,
            enabled: _currentPage < _totalPages,
            onTap: () => setState(() => _currentPage++),
          ),
          const SizedBox(width: 16),
          // Items per page
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _itemsPerPage,
              items: [5, 10, 20, 50]
                  .map(
                    (v) => DropdownMenuItem(
                      value: v,
                      child: Text(
                        '$v / halaman',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _itemsPerPage = v;
                  _currentPage = 1;
                });
              },
              style: const TextStyle(fontSize: 12, color: Color(0xFF1A1A1A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: const [
            Icon(Icons.inbox_outlined, size: 48, color: Color(0xFFCCCCCC)),
            SizedBox(height: 12),
            Text(
              'Belum ada transaksi',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF555555),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Rekap akan muncul setelah ada pemesanan.',
              style: TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Color(0xFFCC3333),
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF555555)),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loadOrders,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF8B4513),
            ),
            child: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}

// ── HELPER WIDGETS ────────────────────────────────────────────────────────────
class _TableHeaderCell extends StatelessWidget {
  final String text;
  const _TableHeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF888888),
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _PaginationButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled ? const Color(0xFFDDDDDD) : const Color(0xFFEEEEEE),
          ),
          borderRadius: BorderRadius.circular(8),
          color: enabled ? Colors.white : const Color(0xFFF9F9F9),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? const Color(0xFF1A1A1A) : const Color(0xFFCCCCCC),
        ),
      ),
    );
  }
}
