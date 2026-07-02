import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/purchase_order_model.dart';
import '../../services/admin_purchase_service.dart';
import '../../widgets/braga_page_header.dart';

class ManageBookingsPage extends StatefulWidget {
  const ManageBookingsPage({Key? key}) : super(key: key);

  @override
  State<ManageBookingsPage> createState() => _ManageBookingsPageState();
}

class _ManageBookingsPageState extends State<ManageBookingsPage> {
  final AdminPurchaseService _service = AdminPurchaseService();

  List<PurchaseOrderModel> _bookings = [];
  bool _isLoading = false;
  String? _selectedStatus;
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _errorMessage;

  final List<String> _statusOptions = [
    'pending_payment',
    'payment_uploaded',
    'payment_review',
    'confirmed',
    'rejected',
    'cancelled',
  ];

  final Map<String, String> _statusLabels = {
    'pending_payment': 'Menunggu Pembayaran',
    'payment_uploaded': 'Pembayaran Diunggah',
    'payment_review': 'Pembayaran Diverifikasi',
    'confirmed': 'Terkonfirmasi',
    'rejected': 'Ditolak',
    'cancelled': 'Dibatalkan',
  };

  final Map<String, Color> _statusColors = {
    'pending_payment': Colors.orange,
    'payment_uploaded': Colors.blue,
    'payment_review': Colors.indigo,
    'confirmed': Colors.green,
    'rejected': Colors.red,
    'cancelled': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final response = await _service.getBookings(
        status: _selectedStatus,
        from: _fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : null,
        to: _toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : null,
      );

      if (response.statusCode == 200) {
        setState(() {
          _bookings = _service.parseBookings(response.body);
          _errorMessage = null;
        });
      } else {
        setState(() => _errorMessage = 'Gagal memuat data pemesanan');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmBooking(PurchaseOrderModel booking) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pemesanan'),
        content: Text('Konfirmasi pemesanan untuk ${booking.propertyTitle}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _performConfirm(booking);
            },
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }

  Future<void> _performConfirm(PurchaseOrderModel booking) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final response = await _service.confirmBooking(booking.id);
      if (response.statusCode == 200) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Pemesanan berhasil dikonfirmasi')),
        );
        _loadBookings();
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text(_service.parseMessage(response.body))),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _rejectBooking(PurchaseOrderModel booking) async {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Pemesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tolak pemesanan untuk ${booking.propertyTitle}?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Alasan penolakan',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _performReject(booking, reasonController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  Future<void> _performReject(PurchaseOrderModel booking, String reason) async {
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alasan penolakan wajib diisi')),
      );
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    try {
      final response = await _service.rejectBooking(booking.id, reason);
      if (response.statusCode == 200) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Pemesanan berhasil ditolak')),
        );
        _loadBookings();
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text(_service.parseMessage(response.body))),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: Column(
        children: [
          BragaPageHeader(
            title: 'Kelola Pemesanan',
            subtitle: 'Kelola dan pantau seluruh pemesanan.',
            decorativeIcon: Icons.shopping_bag_rounded,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadBookings,
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
          else if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_bookings.isEmpty)
            const Expanded(
              child: Center(
                child: Text('Tidak ada pemesanan'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _bookings.length,
                itemBuilder: (context, index) => _buildBookingCard(_bookings[index]),
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
            value: _selectedStatus,
            hint: const Text('Pilih Status'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Semua Status')),
              ..._statusOptions.map((status) => DropdownMenuItem(
                value: status,
                child: Text(_statusLabels[status] ?? status),
              )),
            ],
            onChanged: (value) {
              setState(() => _selectedStatus = value);
              _loadBookings();
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
                _loadBookings();
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
      _loadBookings();
    }
  }

  Widget _buildBookingCard(PurchaseOrderModel booking) {
    final statusLabel = _statusLabels[booking.status] ?? booking.status;
    final statusColor = _statusColors[booking.status] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        booking.buyerNameSnapshot,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        booking.propertyTitle,
                        style: const TextStyle(fontSize: 14),
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
                      fontSize: 12,
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
                        'Harga Properti',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        _formatPrice(booking.propertyPrice),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
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
                        'Metode Pembayaran',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        booking.paymentMethod,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (booking.paymentProofUrl != null && booking.paymentProofUrl!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.image, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bukti Pembayaran Diunggah',
                        style: TextStyle(color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),
            if (booking.notes != null && booking.notes!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    const Text(
                      'Catatan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      booking.notes!,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: booking.status == 'payment_uploaded' || booking.status == 'payment_review'
                        ? () => _confirmBooking(booking)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: const Text('Konfirmasi'),
                  ),
                ),
                Expanded(
                  child: OutlinedButton(
                    onPressed: booking.status == 'pending_payment' || booking.status == 'payment_uploaded'
                        ? () => _rejectBooking(booking)
                        : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      disabledForegroundColor: Colors.grey,
                    ),
                    child: const Text('Tolak'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return formatter.format(price);
  }
}
