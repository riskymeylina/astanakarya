import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/admin_invoice_service.dart';
import '../../widgets/braga_page_header.dart';

class InvoiceManagementPage extends StatefulWidget {
  const InvoiceManagementPage({Key? key}) : super(key: key);

  @override
  State<InvoiceManagementPage> createState() => _InvoiceManagementPageState();
}

class _InvoiceManagementPageState extends State<InvoiceManagementPage> {
  final AdminInvoiceService _service = AdminInvoiceService();

  List<InvoiceModel> _invoices = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentOffset = 0;
  bool _hasMore = true;
  String? _selectedPaymentStatus;
  DateTime? _fromDate;
  DateTime? _toDate;

  final List<String> _paymentStatuses = ['pending', 'paid', 'overdue', 'cancelled'];

  final Map<String, String> _statusLabels = {
    'pending': 'Menunggu Pembayaran',
    'paid': 'Lunas',
    'overdue': 'Jatuh Tempo',
    'cancelled': 'Dibatalkan',
  };

  final Map<String, Color> _statusColors = {
    'pending': Colors.orange,
    'paid': Colors.green,
    'overdue': Colors.red,
    'cancelled': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices({bool reset = false}) async {
    if (reset) {
      setState(() => _currentOffset = 0);
    }

    setState(() => _isLoading = true);
    try {
      final response = await _service.getInvoices(
        paymentStatus: _selectedPaymentStatus,
        from: _fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : null,
        to: _toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : null,
        limit: 20,
        offset: _currentOffset,
      );

      if (response.statusCode == 200) {
        final newInvoices = _service.parseInvoices(response.body);
        setState(() {
          if (reset) {
            _invoices = newInvoices;
          } else {
            _invoices.addAll(newInvoices);
          }
          _hasMore = newInvoices.length == 20;
          _errorMessage = null;
        });
      } else {
        setState(() => _errorMessage = 'Gagal memuat data invoice');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadMore() {
    if (_hasMore && !_isLoading) {
      _currentOffset += 20;
      _loadInvoices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: Column(
        children: [
          BragaPageHeader(
            title: 'Kelola Invoice',
            subtitle: 'Kelola dan pantau seluruh invoice.',
            decorativeIcon: Icons.receipt_rounded,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => _loadInvoices(reset: true),
              ),
            ],
          ),
          _buildFilterBar(),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          else if (_isLoading && _invoices.isEmpty)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_invoices.isEmpty)
            const Expanded(
              child: Center(
                child: Text('Tidak ada invoice'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _invoices.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _invoices.length) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _loadMore,
                                child: const Text('Muat Lebih Banyak'),
                              ),
                      ),
                    );
                  }
                  return _buildInvoiceCard(_invoices[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 12,
        children: [
          DropdownButton<String>(
            isExpanded: true,
            value: _selectedPaymentStatus,
            hint: const Text('Pilih Status Pembayaran'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Semua Status')),
              ..._paymentStatuses.map((status) => DropdownMenuItem(
                value: status,
                child: Text(_statusLabels[status] ?? status),
              )),
            ],
            onChanged: (value) {
              setState(() => _selectedPaymentStatus = value);
              _loadInvoices(reset: true);
            },
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickDate(true),
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_fromDate == null
                      ? 'Dari'
                      : DateFormat('dd/MM/yyyy').format(_fromDate!)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickDate(false),
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_toDate == null
                      ? 'Sampai'
                      : DateFormat('dd/MM/yyyy').format(_toDate!)),
                ),
              ),
            ],
          ),
          if (_fromDate != null || _toDate != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _fromDate = null;
                  _toDate = null;
                });
                _loadInvoices(reset: true);
              },
              child: const Text('Bersihkan Filter Tanggal'),
            ),
        ],
      ),
    );
  }

  Future<void> _pickDate(bool isFromDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? _fromDate ?? DateTime.now() : _toDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
      _loadInvoices(reset: true);
    }
  }

  Widget _buildInvoiceCard(InvoiceModel invoice) {
    final statusLabel = _statusLabels[invoice.paymentStatus] ?? invoice.paymentStatus;
    final statusColor = _statusColors[invoice.paymentStatus] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showInvoiceDetail(invoice),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(
                          'INV-${invoice.invoiceNumber}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          invoice.propertyName,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      border: Border.all(color: statusColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        const Text(
                          'Pembeli',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          invoice.propertyPrice.toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        const Text(
                          'Jumlah',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          _formatPrice(invoice.propertyPrice),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        const Text(
                          'Tanggal Terbit',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          invoice.issuedAt != null
                              ? DateFormat('dd/MM/yyyy').format(DateTime.parse(invoice.issuedAt!))
                              : '-',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        const Text(
                          'Jatuh Tempo',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          invoice.dueDate != null
                              ? DateFormat('dd/MM/yyyy').format(DateTime.parse(invoice.dueDate!))
                              : '-',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Tap untuk detail',
                  style: TextStyle(fontSize: 11, color: Colors.blue[700]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInvoiceDetail(InvoiceModel invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        builder: (ctx, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                const Text(
                  'Detail Invoice',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _detailRow('Nomor Invoice', 'INV-${invoice.invoiceNumber}'),
                _detailRow('Properti', invoice.propertyName),
                _detailRow('Pembeli', 'ID: ${invoice.buyerId}'),
                _detailRow('Harga', _formatPrice(invoice.propertyPrice)),
                _detailRow('Status Pembayaran', invoice.paymentStatus),
                if (invoice.paymentMethod != null)
                  _detailRow('Metode Pembayaran', invoice.paymentMethod!),
                if (invoice.issuedAt != null)
                  _detailRow('Tanggal Terbit', DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(invoice.issuedAt!))),
                if (invoice.dueDate != null)
                  _detailRow('Jatuh Tempo', DateFormat('dd/MM/yyyy').format(DateTime.parse(invoice.dueDate!))),
                _detailRow('Dibuat', DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(invoice.createdAt))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return formatter.format(price);
  }
}