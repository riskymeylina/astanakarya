import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/purchase_order_model.dart';

class InvoicePdfService {
  InvoicePdfService()
    : _currency = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );

  final NumberFormat _currency;

  Future<Uint8List> buildInvoice(PurchaseOrderModel order) async {
    final document = pw.Document(title: 'Invoice #${order.id}');

    // Load Fonts
    final baseFont = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();
    final italicFont = await PdfGoogleFonts.robotoItalic();

    // Load logo image
    pw.ImageProvider? logoImage;
    try {
      logoImage = await imageFromAssetBundle('assets/images/logo.jpg');
    } catch (_) {}

    // Load property thumbnail image if possible
    pw.ImageProvider? propImage;
    if (order.propertyImageUrl != null && order.propertyImageUrl!.isNotEmpty) {
      try {
        propImage = await networkImage(order.propertyImageUrl!);
      } catch (_) {}
    }

    final invoiceNum = _getInvoiceNumber(order);
    final invoiceDate = _formatInvoiceDate(order.createdAt);

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(32),
          theme: pw.ThemeData.withFont(
            base: baseFont,
            bold: boldFont,
            italic: italicFont,
          ),
        ),
        build: (context) => [
          // 1. HEADER ROW
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // Company Logo & Info
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (logoImage != null)
                    pw.Container(
                      width: 50,
                      height: 50,
                      margin: const pw.EdgeInsets.only(right: 12),
                      child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                    )
                  else
                    pw.Container(
                      width: 50,
                      height: 50,
                      margin: const pw.EdgeInsets.only(right: 12),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#7A3B1E'),
                        shape: pw.BoxShape.circle,
                      ),
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        'P',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PT. ASTANA KARYA BANDAWASA',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#7A3B1E'),
                        ),
                      ),
                      pw.Text(
                        'Jl. Raya Jogja - Solo Km 15',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        'Klaten, Jawa Tengah 57454',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        'Telp. (0272) 123456 | info@penjualanproperti.co.id',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                ],
              ),
              // Invoice Title & Info
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'INVOICE',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#171717'),
                      letterSpacing: 1,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    children: [
                      pw.Text(
                        'Nomor Invoice : ',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        invoiceNum,
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                  pw.Row(
                    children: [
                      pw.Text(
                        'Tanggal : ',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        invoiceDate,
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          // 2. TWO-COLUMN BUYER AND PROPERTY SECTION
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Left: Buyer Info Card
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#FFFBF7'),
                    border: pw.Border.all(color: PdfColor.fromHex('#E7CCAE'), width: 1),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Informasi Pembeli',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#7A3B1E'),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      _buildInfoRow('Nama', order.buyerNameSnapshot),
                      _buildInfoRow('No. HP', order.buyerPhoneSnapshot ?? '-'),
                      _buildInfoRow(
                        'Email',
                        order.buyerEmail ??
                            '${order.buyerNameSnapshot.toLowerCase().replaceAll(' ', '')}@gmail.com',
                      ),
                      _buildInfoRow('Alamat', order.buyerAddressSnapshot ?? '-'),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 16),
              // Right: Property Info Card
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#FFFBF7'),
                    border: pw.Border.all(color: PdfColor.fromHex('#E7CCAE'), width: 1),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Informasi Properti',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#7A3B1E'),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Thumbnail Image Box
                          if (propImage != null)
                            pw.Container(
                              width: 50,
                              height: 50,
                              margin: const pw.EdgeInsets.only(right: 10),
                              child: pw.ClipRRect(
                                horizontalRadius: 4,
                                verticalRadius: 4,
                                child: pw.Image(propImage, fit: pw.BoxFit.cover),
                              ),
                            )
                          else
                            pw.Container(
                              width: 50,
                              height: 50,
                              margin: const pw.EdgeInsets.only(right: 10),
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromHex('#F5E0C8'),
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                              alignment: pw.Alignment.center,
                              child: pw.Text(
                                '🏡',
                                style: const pw.TextStyle(fontSize: 20),
                              ),
                            ),
                          // Property Text Info
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  order.propertyTitle,
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.Text(
                                  order.propertyType ?? 'Tipe 120 | 2 Lantai',
                                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                                ),
                                pw.Text(
                                  'Luas Tanah: ${order.propertyLandArea ?? '120'} m²',
                                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
                                ),
                                pw.Text(
                                  'Luas Bangunan: ${order.propertyBuildingArea ?? '120'} m²',
                                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
                                ),
                                pw.Text(
                                  'Lokasi: ${order.propertyLocation}',
                                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          // 3. TABLE & PAYMENT DETAILS ROW
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Left: Cost breakdown table + Terbilang (flex 3)
              pw.Expanded(
                flex: 3,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Itemized Table
                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColor.fromHex('#E7CCAE'), width: 0.5),
                      columnWidths: const {
                        0: pw.FlexColumnWidth(3),
                        1: pw.FlexColumnWidth(2),
                        2: pw.FlexColumnWidth(2.5),
                      },
                      children: [
                        // Table Header
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#7A3B1E')),
                          children: [
                            _buildTableHeaderCell('Deskripsi', alignLeft: true),
                            _buildTableHeaderCell('Keterangan'),
                            _buildTableHeaderCell('Jumlah', alignRight: true),
                          ],
                        ),
                        // Row 1: Harga Properti
                        pw.TableRow(
                          children: [
                            _buildTableCell('Harga Properti', alignLeft: true),
                            _buildTableCell('-'),
                            _buildTableCell(_currency.format(order.propertyPrice), alignRight: true),
                          ],
                        ),
                        // Row 2: Biaya Administrasi
                        pw.TableRow(
                          children: [
                            _buildTableCell('Biaya Administrasi', alignLeft: true),
                            _buildTableCell('-'),
                            _buildTableCell('Rp 0', alignRight: true),
                          ],
                        ),
                        // Row 3: Diskon
                        pw.TableRow(
                          children: [
                            _buildTableCell('Diskon', alignLeft: true),
                            _buildTableCell('-'),
                            _buildTableCell('Rp 0', alignRight: true),
                          ],
                        ),
                        // Row 4: Total Pembayaran
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#FFF8F0')),
                          children: [
                            _buildTableCell('Total Pembayaran', bold: true, alignLeft: true),
                            _buildTableCell('-', bold: true),
                            _buildTableCell(_currency.format(order.payableAmount), bold: true, alignRight: true),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 12),
                    // Terbilang
                    pw.Text(
                      'Terbilang',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#7A3B1E'),
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      _terbilang(order.payableAmount),
                      style: pw.TextStyle(
                        fontSize: 8.5,
                        fontStyle: pw.FontStyle.italic,
                        color: PdfColor.fromHex('#171717'),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 16),
              // Right: Payment Card (flex 2)
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    border: pw.Border.all(color: PdfColor.fromHex('#E7CCAE'), width: 1),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Informasi Pembayaran',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#7A3B1E'),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      _buildPaymentKV('Metode Pembayaran', order.paymentMethod),
                      _buildPaymentKV('Bank Tujuan', order.paymentBankNote ?? 'Bank BCA'),
                      _buildPaymentKV('No. Rekening', order.paymentAccountNumber ?? '-'),
                      _buildPaymentKV('Atas Nama', order.paymentAccountName ?? '-'),
                      _buildPaymentKV('Nominal Transfer', _currency.format(order.payableAmount), boldValue: true),
                      _buildPaymentKV('No. Referensi', order.id.toString().padLeft(12, '0')),
                    ],
                  ),
                ),
              ),
            ],
          ),

          pw.Spacer(),

          // 4. FOOTER ROW
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              // Left: Info
              pw.Text(
                '* Invoice ini sah dan diproses secara komputerisasi',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
              ),
              // Right: Signature
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'Klaten, $invoiceDate',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Hormat kami,',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.SizedBox(height: 36),
                  pw.Text(
                    'PT. ASTANA KARYA BANDAWASA',
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return document.save();
  }

  Future<void> printInvoice(PurchaseOrderModel order) async {
    await Printing.layoutPdf(
      name: _fileName(order),
      onLayout: (_) => buildInvoice(order),
    );
  }

  Future<void> shareInvoice(PurchaseOrderModel order) async {
    await Printing.sharePdf(
      bytes: await buildInvoice(order),
      filename: _fileName(order),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 45,
            child: pw.Text(
              '$label : ',
              style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 8.5),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPaymentKV(String label, String value, {bool boldValue = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
          ),
          pw.Text(
            ' : ',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: boldValue ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTableHeaderCell(String text, {bool alignLeft = false, bool alignRight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(
        text,
        textAlign: alignLeft
            ? pw.TextAlign.left
            : alignRight
                ? pw.TextAlign.right
                : pw.TextAlign.center,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 8.5,
        ),
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {bool bold = false, bool alignLeft = false, bool alignRight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(
        text,
        textAlign: alignLeft
            ? pw.TextAlign.left
            : alignRight
                ? pw.TextAlign.right
                : pw.TextAlign.center,
        style: pw.TextStyle(
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: 8,
        ),
      ),
    );
  }

  String _getInvoiceNumber(PurchaseOrderModel order) {
    try {
      final dt = DateTime.parse(order.createdAt ?? '').toLocal();
      final year = dt.year;
      final monthStr = dt.month.toString().padLeft(2, '0');
      final dayStr = dt.day.toString().padLeft(2, '0');
      final numStr = order.id.toString().padLeft(4, '0');
      return 'INV/$year/$monthStr$dayStr/$numStr';
    } catch (_) {
      return 'INV/${DateTime.now().year}/${order.id.toString().padLeft(4, '0')}';
    }
  }

  String _formatInvoiceDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '-';
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      return DateFormat('dd MMMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return rawDate;
    }
  }

  String _terbilang(double number) {
    final n = number.toInt();
    if (n == 0) return 'nol rupiah';
    final units = ['', 'satu', 'dua', 'tiga', 'empat', 'lima', 'enam', 'tujuh', 'delapan', 'sembilan', 'sepuluh', 'sebelas'];
    String helper(int val) {
      if (val < 12) return units[val];
      if (val < 20) return '${helper(val - 10)} belas';
      if (val < 100) return '${helper(val ~/ 10)} puluh ${helper(val % 10)}';
      if (val < 200) return 'seratus ${helper(val - 100)}';
      if (val < 1000) return '${helper(val ~/ 100)} ratus ${helper(val % 100)}';
      if (val < 2000) return 'seribu ${helper(val - 1000)}';
      if (val < 1000000) return '${helper(val ~/ 1000)} ribu ${helper(val % 1000)}';
      if (val < 1000000000) return '${helper(val ~/ 1000000)} juta ${helper(val % 1000000)}';
      if (val < 1000000000000) return '${helper(val ~/ 1000000000)} milyar ${helper(val % 1000000000)}';
      return '';
    }
    final res = helper(n).trim().replaceAll(RegExp(r'\s+'), ' ');
    if (res.isEmpty) return '';
    return '${res[0].toUpperCase()}${res.substring(1)} rupiah';
  }

  String _fileName(PurchaseOrderModel order) => 'invoice-${order.id}.pdf';
}
