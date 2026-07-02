import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../services/admin_report_service.dart';
import '../../../../models/purchase_order_model.dart';
import '../../../../widgets/braga_page_header.dart';
import 'transaction_detail_page.dart';
import '../../utils/file_saver.dart'; // Perbaikan: menggunakan path internal folder yang sama

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  final AdminReportService _service = AdminReportService();

  AdminSalesReportResult? _result;
  bool _loading = true;
  String? _error;

  // Filter state
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _selectedStatus;
  String? _selectedPaymentMethod;
  String? _selectedProperty;

  // Pagination
  int _currentPage = 1;
  static const int _pageSize = 10;

  // Filtered/paged list
  List<PurchaseOrderModel> _filteredTransactions = [];

  static const _brown = Color(0xFF7A3B1E);
  static const _brownLight = Color(0xFF9A5A2E);
  static const _amber = Color(0xFFFDD096);
  static const _border = Color(0xFFE7CCAE);
  static const _bg = Color(0xFFFFF8F0);

  final List<String> _statusOptions = [
    'confirmed',
    'pending_payment',
    'payment_uploaded',
    'payment_review',
    'rejected',
    'cancelled',
  ];

  final Map<String, String> _statusLabels = {
    'confirmed': 'Terjual',
    'pending_payment': 'Pending',
    'payment_uploaded': 'Dipesan',
    'payment_review': 'Dipesan',
    'rejected': 'Ditolak',
    'cancelled': 'Dibatalkan',
  };

  final Map<String, Color> _statusColors = {
    'confirmed': const Color(0xFF1B874B),
    'pending_payment': const Color(0xFF1967D2),
    'payment_uploaded': const Color(0xFFCB7D2A),
    'payment_review': const Color(0xFFCB7D2A),
    'rejected': const Color(0xFFC74C4C),
    'cancelled': const Color(0xFF6C6C6C),
  };

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _service.getSalesReport();
      if (res.statusCode == 200) {
        final result = _service.parseSalesReport(res.body);
        setState(() {
          _result = result;
          _loading = false;
        });
        _applyFilters();
      } else {
        setState(() {
          _error = _service.parseMessage(res.body);
          _loading = false;
        });
      }
    } catch (_) {
      setState(() {
        _error = 'Tidak dapat terhubung ke server';
        _loading = false;
      });
    }
  }

  void _applyFilters() {
    if (_result == null) return;
    var list = List<PurchaseOrderModel>.from(_result!.transactions);

    if (_selectedStatus != null) {
      list = list.where((t) => t.status == _selectedStatus).toList();
    }
    if (_selectedPaymentMethod != null) {
      list = list
          .where((t) =>
              (t.paymentMethod ?? '').toLowerCase() ==
              _selectedPaymentMethod!.toLowerCase())
          .toList();
    }
    if (_fromDate != null) {
      list = list.where((t) {
        if (t.createdAt == null) return false;
        return DateTime.tryParse(t.createdAt!)?.isAfter(
                _fromDate!.subtract(const Duration(days: 1))) ??
            false;
      }).toList();
    }
    if (_toDate != null) {
      list = list.where((t) {
        if (t.createdAt == null) return false;
        return DateTime.tryParse(t.createdAt!)
                ?.isBefore(_toDate!.add(const Duration(days: 1))) ??
            false;
      }).toList();
    }

    setState(() {
      _filteredTransactions = list;
      _currentPage = 1;
    });
  }

  List<PurchaseOrderModel> get _pagedTransactions {
    final start = (_currentPage - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, _filteredTransactions.length);
    if (start >= _filteredTransactions.length) return [];
    return _filteredTransactions.sublist(start, end);
  }

  int get _totalPages =>
      (_filteredTransactions.length / _pageSize).ceil().clamp(1, 999);

  String _formatCurrency(double amount) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
          .format(amount);

  String _formatDate(String? raw, {bool withTime = false}) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final datePart = DateFormat('dd MMM yyyy', 'id_ID').format(dt);
      if (withTime) {
        return '$datePart, ${DateFormat('HH:mm').format(dt)} WIB';
      }
      return datePart;
    } catch (_) {
      return raw;
    }
  }

  // Summary stats
  int get _totalTransactions => _filteredTransactions.length;

  double get _totalRevenue => _filteredTransactions
      .where((t) => t.status == 'confirmed')
      .fold(0, (sum, t) => sum + (t.totalPrice ?? 0));

  int get _totalPropertiesSold => _filteredTransactions
      .where((t) => t.status == 'confirmed')
      .map((t) => t.propertyId)
      .toSet()
      .length;

  int get _totalBuyers => _filteredTransactions
      .map((t) => t.buyerUserId)
      .whereType<int>()
      .toSet()
      .length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          BragaPageHeader(
            title: 'Laporan Penjualan Properti',
            subtitle: 'Pantau seluruh transaksi penjualan properti yang telah berhasil diproses.',
            decorativeIcon: Icons.bar_chart_rounded,
            actions: [
              _HeaderButton(
                icon: Icons.table_chart_rounded,
                label: 'Export Excel',
                color: const Color(0xFF1D6F42),
                onTap: _exportToExcel,
              ),
              const SizedBox(width: 8),
              _HeaderButton(
                icon: Icons.picture_as_pdf_rounded,
                label: 'Export PDF',
                color: const Color(0xFFD93025),
                onTap: _exportToPdf,
              ),
              const SizedBox(width: 8),
              _HeaderButton(
                icon: Icons.print_rounded,
                label: 'Cetak Laporan',
                onTap: _printReport,
              ),
            ],
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildError()
                    : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loadReport,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
            style: FilledButton.styleFrom(backgroundColor: _brown),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadReport,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterBar(),
            const SizedBox(height: 20),
            _buildSummaryCards(),
            const SizedBox(height: 20),
            _buildTransactionTable(),
            const SizedBox(height: 16),
            _buildPagination(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _FilterField(
                  label: 'Tanggal Awal',
                  value: _fromDate != null
                      ? DateFormat('dd/MM/yyyy').format(_fromDate!)
                      : null,
                  placeholder: '01/05/2026',
                  icon: Icons.calendar_today_rounded,
                  onTap: () async {
                    final p = await showDatePicker(
                        context: context,
                        initialDate: _fromDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now());
                    if (p != null) {
                      setState(() => _fromDate = p);
                      _applyFilters();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FilterField(
                  label: 'Tanggal Akhir',
                  value: _toDate != null
                      ? DateFormat('dd/MM/yyyy').format(_toDate!)
                      : null,
                  placeholder: '12/06/2026',
                  icon: Icons.calendar_today_rounded,
                  onTap: () async {
                    final p = await showDatePicker(
                        context: context,
                        initialDate: _toDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now()
                            .add(const Duration(days: 365)));
                    if (p != null) {
                      setState(() => _toDate = p);
                      _applyFilters();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DropdownFilter<String>(
                  label: 'Status Transaksi',
                  value: _selectedStatus,
                  placeholder: 'Semua Status',
                  items: _statusOptions,
                  itemLabel: (s) => _statusLabels[s] ?? s,
                  onChanged: (v) {
                    setState(() => _selectedStatus = v);
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DropdownFilter<String>(
                  label: 'Metode Pembayaran',
                  value: _selectedPaymentMethod,
                  placeholder: 'Semua Metode',
                  items: const [
                    'Transfer Bank',
                  ],
                  itemLabel: (s) => s,
                  onChanged: (v) {
                    setState(() => _selectedPaymentMethod = v);
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DropdownFilter<String>(
                  label: 'Properti',
                  value: _selectedProperty,
                  placeholder: 'Semua Properti',
                  items: _result?.transactions
                          .map((t) => t.propertyTitle)
                          .where((t) => t.isNotEmpty)
                          .toSet()
                          .toList() ??
                      [],
                  itemLabel: (s) => s,
                  onChanged: (v) {
                    setState(() => _selectedProperty = v);
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  const Text('  ', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: _applyFilters,
                        icon: const Icon(Icons.tune_rounded, size: 16),
                        label: const Text('Terapkan'),
                        style: FilledButton.styleFrom(
                          backgroundColor: _brown,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _fromDate = null;
                            _toDate = null;
                            _selectedStatus = null;
                            _selectedPaymentMethod = null;
                            _selectedProperty = null;
                          });
                          _applyFilters();
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Reset'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        _SummaryCard(
          icon: Icons.shopping_cart_rounded,
          iconBg: const Color(0xFFE8F5E9),
          iconColor: Colors.green,
          label: 'Total Penjualan',
          value: '$_totalTransactions',
          sub: 'Transaksi',
        ),
        const SizedBox(width: 16),
        _SummaryCard(
          icon: Icons.home_work_rounded,
          iconBg: const Color(0xFFFFF3E0),
          iconColor: Colors.orange,
          label: 'Total Properti Terjual',
          value: '$_totalPropertiesSold',
          sub: 'Unit',
        ),
        const SizedBox(width: 16),
        _SummaryCard(
          icon: Icons.people_rounded,
          iconBg: const Color(0xFFFCE4EC),
          iconColor: Colors.pink,
          label: 'Total Pembeli',
          value: '$_totalBuyers',
          sub: 'Orang',
        ),
        const SizedBox(width: 16),
        _SummaryCard(
          icon: Icons.monetization_on_rounded,
          iconBg: const Color(0xFFE8F5E9),
          iconColor: Colors.green,
          label: 'Total Pendapatan',
          value: _formatCurrency(_totalRevenue),
          sub: null,
          large: true,
        ),
      ],
    );
  }

  Widget _buildTransactionTable() {
    final rows = _pagedTransactions;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _brown,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: const [
                _TableHeader(label: 'Tanggal', flex: 2),
                _TableHeader(label: 'Invoice', flex: 2),
                _TableHeader(label: 'Pembeli', flex: 3),
                _TableHeader(label: 'Properti', flex: 3),
                _TableHeader(label: 'Metode Pembayaran', flex: 3),
                _TableHeader(label: 'Nilai', flex: 2),
                _TableHeader(label: 'Status', flex: 2),
                _TableHeader(label: 'Aksi', flex: 2),
              ],
            ),
          ),

          if (rows.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Text(
                  'Tidak ada data transaksi',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...rows.asMap().entries.map((entry) {
              final i = entry.key;
              final tx = entry.value;
              return _TransactionRow(
                tx: tx,
                isEven: i.isEven,
                statusLabels: _statusLabels,
                statusColors: _statusColors,
                formatCurrency: _formatCurrency,
                formatDate: _formatDate,
                onViewDetail: () => _openDetail(tx),
              );
            }),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  'Menampilkan ${(_currentPage - 1) * _pageSize + 1}–'
                  '${((_currentPage - 1) * _pageSize + rows.length)} '
                  'dari ${_filteredTransactions.length} transaksi',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    if (_totalPages <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: _currentPage > 1
              ? () => setState(() => _currentPage--)
              : null,
        ),
        ...List.generate(_totalPages.clamp(0, 7), (i) {
          final page = i + 1;
          final isActive = page == _currentPage;
          return GestureDetector(
            onTap: () => setState(() => _currentPage = page),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isActive ? _brown : Colors.white,
                border: Border.all(color: isActive ? _brown : _border),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '$page',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        }),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: _currentPage < _totalPages
              ? () => setState(() => _currentPage++)
              : null,
        ),
      ],
    );
  }

  void _openDetail(PurchaseOrderModel tx) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetailPage(transaction: tx),
      ),
    );
  }

  Future<void> _exportToExcel() async {
    if (_filteredTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk diexport')),
      );
      return;
    }

    try {
      var excelObj = Excel.createExcel();
      String sheetName = 'Laporan Penjualan';
      excelObj.rename('Sheet1', sheetName);
      var sheet = excelObj[sheetName];

      // Add Headers
      sheet.appendRow([
        TextCellValue('Tanggal'),
        TextCellValue('Nomor Invoice'),
        TextCellValue('Nama Pembeli'),
        TextCellValue('WhatsApp'),
        TextCellValue('Email'),
        TextCellValue('Alamat'),
        TextCellValue('Properti'),
        TextCellValue('Tipe'),
        TextCellValue('Metode Pembayaran'),
        TextCellValue('Nilai'),
        TextCellValue('Status'),
      ]);

      // Add Rows
      for (var tx in _filteredTransactions) {
        final invoiceNum = _getInvoiceNumber(tx);
        final statusLabel = _statusLabels[tx.status] ?? tx.status;
        sheet.appendRow([
          TextCellValue(_formatDate(tx.createdAt)),
          TextCellValue(invoiceNum),
          TextCellValue(tx.buyerNameSnapshot),
          TextCellValue(tx.buyerPhoneSnapshot ?? ''),
          TextCellValue(tx.buyerEmail ?? ''),
          TextCellValue(tx.buyerAddress ?? ''),
          TextCellValue(tx.propertyTitle),
          TextCellValue(tx.propertyType ?? ''),
          TextCellValue(tx.paymentMethod),
          DoubleCellValue((tx.totalPrice ?? 0.0).toDouble()),
          TextCellValue(statusLabel),
        ]);
      }

      final bytes = excelObj.save();
      if (bytes != null) {
        await downloadFile(
          bytes: Uint8List.fromList(bytes),
          fileName: 'Laporan_Penjualan_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx',
          mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan Excel berhasil diunduh')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal export Excel: $e')),
      );
    }
  }

  Future<Uint8List> _generatePdfReport() async {
    final pdf = pw.Document(title: 'Laporan Penjualan Properti');
    
    final baseFont = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    final totalRevenueText = _formatCurrency(_totalRevenue);
    
    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(24),
          theme: pw.ThemeData.withFont(
            base: baseFont,
            bold: boldFont,
          ),
        ),
        header: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 20),
          child: pw.Text(
            'PT. ASTANA KARYA BANDAWASA - Laporan Penjualan',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 20),
          child: pw.Text(
            'Halaman ${context.pageNumber} dari ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
          ),
        ),
        build: (context) => [
          pw.Text(
            'Laporan Penjualan Properti',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#7A3B1E')),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Dicetak pada: ${DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now())} WIB',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
          pw.SizedBox(height: 16),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildPdfSummaryCard('Total Transaksi', '$_totalTransactions Transaksi'),
              _buildPdfSummaryCard('Unit Terjual', '$_totalPropertiesSold Unit'),
              _buildPdfSummaryCard('Total Pembeli', '$_totalBuyers Orang'),
              _buildPdfSummaryCard('Total Pendapatan', totalRevenueText, isLarge: true),
            ],
          ),
          pw.SizedBox(height: 20),

          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(2.5),
              2: pw.FlexColumnWidth(3),
              3: pw.FlexColumnWidth(3),
              4: pw.FlexColumnWidth(2.5),
              5: pw.FlexColumnWidth(2.5),
              6: pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColor.fromHex('#7A3B1E')),
                children: [
                  _pdfTh('Tanggal'),
                  _pdfTh('Invoice'),
                  _pdfTh('Pembeli'),
                  _pdfTh('Properti'),
                  _pdfTh('Pembayaran'),
                  _pdfTh('Nilai'),
                  _pdfTh('Status'),
                ],
              ),
              ..._filteredTransactions.map((tx) {
                final invoiceNum = 'INV/${DateTime.now().year}/${tx.id.toString().padLeft(4, '0')}';
                final statusLabel = _statusLabels[tx.status] ?? tx.status;
                return pw.TableRow(
                  children: [
                    _pdfTd(_formatDate(tx.createdAt)),
                    _pdfTd(invoiceNum),
                    _pdfTd(tx.buyerNameSnapshot),
                    _pdfTd(tx.propertyTitle),
                    _pdfTd(tx.paymentMethod),
                    _pdfTd(_formatCurrency((tx.totalPrice ?? 0).toDouble())),
                    _pdfTd(statusLabel),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfSummaryCard(String label, String value, {bool isLarge = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColor.fromHex('#E7CCAE'), width: 1),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: isLarge ? 11 : 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#7A3B1E'),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfTh(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 8),
      ),
    );
  }

  pw.Widget _pdfTd(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 8),
      ),
    );
  }

  Future<void> _exportToPdf() async {
    if (_filteredTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk diexport')),
      );
      return;
    }

    try {
      final bytes = await _generatePdfReport();
      await downloadFile(
        bytes: bytes,
        fileName: 'Laporan_Penjualan_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
        mimeType: 'application/pdf',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan PDF berhasil diunduh')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal export PDF: $e')),
      );
    }
  }

  Future<void> _printReport() async {
    if (_filteredTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk dicetak')),
      );
      return;
    }

    try {
      final bytes = await _generatePdfReport();
      await Printing.layoutPdf(
        name: 'Laporan_Penjualan_${DateFormat('yyyyMMdd').format(DateTime.now())}',
        onLayout: (_) async => bytes,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mencetak laporan: $e')),
      );
    }
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: color ?? Colors.white),
      label: Text(
        label,
        style: TextStyle(color: color ?? Colors.white, fontSize: 13),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: (color ?? Colors.white).withOpacity(0.6)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  final String label;
  final String? value;
  final String placeholder;
  final IconData icon;
  final VoidCallback onTap;

  const _FilterField({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black54)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              border:
                  Border.all(color: const Color(0xFFD9C4AE)),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? placeholder,
                    style: TextStyle(
                      fontSize: 13,
                      color: value != null ? Colors.black87 : Colors.black38,
                    ),
                  ),
                ),
                Icon(icon, size: 16, color: Colors.black45),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownFilter<T> extends StatelessWidget {
  final String label;
  final T? value;
  final String placeholder;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black54)),
        const SizedBox(height: 4),
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD9C4AE)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD9C4AE)),
            ),
            isDense: true,
          ),
          hint:
              Text(placeholder, style: const TextStyle(fontSize: 13)),
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          isExpanded: true,
          items: [
            DropdownMenuItem<T>(value: null, child: Text(placeholder)),
            ...items.map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item),
                      overflow: TextOverflow.ellipsis),
                )),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final String? sub;
  final bool large;

  const _SummaryCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    this.sub,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE7CCAE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: large ? 18 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (sub != null)
                    Text(sub!,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black45)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String label;
  final int flex;
  const _TableHeader({required this.label, required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final PurchaseOrderModel tx;
  final bool isEven;
  final Map<String, String> statusLabels;
  final Map<String, Color> statusColors;
  final String Function(double) formatCurrency;
  final String Function(String?, {bool withTime}) formatDate;
  final VoidCallback onViewDetail;

  const _TransactionRow({
    required this.tx,
    required this.isEven,
    required this.statusLabels,
    required this.statusColors,
    required this.formatCurrency,
    required this.formatDate,
    required this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    final status = tx.status;
    final statusLabel = statusLabels[status] ?? status;
    final statusColor = statusColors[status] ?? Colors.grey;
    final invoiceNum = _getInvoiceNumber(tx);

    return Container(
      color: isEven ? Colors.white : const Color(0xFFFFFBF6),
      child: InkWell(
        onTap: onViewDetail,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatDate(tx.createdAt),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    if (tx.createdAt != null)
                      Text(
                        _extractTime(tx.createdAt!),
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  invoiceNum,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFF5E0C8),
                      child: Text(
                        (tx.buyerNameSnapshot.isNotEmpty)
                            ? tx.buyerNameSnapshot[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7A3B1E)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.buyerNameSnapshot,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (tx.buyerPhoneSnapshot != null)
                            Text(
                              tx.buyerPhoneSnapshot!,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5E0C8),
                        borderRadius: BorderRadius.circular(6),
                        image: (tx.propertyImageUrl != null && tx.propertyImageUrl!.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(tx.propertyImageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (tx.propertyImageUrl == null || tx.propertyImageUrl!.isEmpty)
                          ? const Icon(Icons.home_rounded,
                              size: 18, color: Color(0xFF7A3B1E))
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.propertyTitle,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (tx.propertyType != null)
                            Text(
                              tx.propertyType!,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  tx.paymentMethod,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  formatCurrency((tx.totalPrice ?? 0).toDouble()),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: statusColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: TextButton.icon(
                  onPressed: onViewDetail,
                  icon: const Icon(Icons.visibility_rounded, size: 15),
                  label: const Text('Lihat Detail'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF7A3B1E),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _extractTime(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${DateFormat('HH:mm').format(dt)} WIB';
    } catch (_) {
      return '';
    }
  }
}

String _getInvoiceNumber(PurchaseOrderModel tx) {
  try {
    final dt = DateTime.parse(tx.createdAt ?? '').toLocal();
    final year = dt.year;
    final monthStr = dt.month.toString().padLeft(2, '0');
    final dayStr = dt.day.toString().padLeft(2, '0');
    final numStr = tx.id.toString().padLeft(4, '0');
    return 'INV/$year/$monthStr$dayStr/$numStr';
  } catch (_) {
    return 'INV/${DateTime.now().year}/${tx.id.toString().padLeft(4, '0')}';
  }
}