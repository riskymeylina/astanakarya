import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/admin_models.dart';
import '../../../../services/admin_property_service.dart';
import '../../../../services/admin_report_service.dart';
import '../../../../services/notification_service.dart';

import 'widgets/dashboard_summary_card.dart';
import 'widgets/dashboard_chart_section.dart';
import 'widgets/dashboard_donut_chart.dart';
import 'widgets/dashboard_list_section.dart';

class DashboardMainView extends StatefulWidget {
  final String userName;
  final String userRole;

  const DashboardMainView({
    super.key,
    required this.userName,
    required this.userRole,
  });

  @override
  State<DashboardMainView> createState() => _DashboardMainViewState();
}

class _DashboardMainViewState extends State<DashboardMainView> {
  final AdminPropertyService _propertyService = AdminPropertyService();
  final AdminReportService _reportService = AdminReportService();
  final NotificationService _notificationService = NotificationService();

  bool _isLoading = true;
  List<AdminPropertyModel> _properties = [];
  AdminGlobalReportModel? _globalReport;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _propertyService.getProperties(),
        _reportService.getGlobalReport(),
        _notificationService.getNotifications(),
      ]);

      final propRes = results[0];
      final reportRes = results[1];
      final notifRes = results[2];

      if (propRes.statusCode >= 200 && propRes.statusCode < 300) {
        final List<dynamic> data = _propertyService.parseProperties(propRes.body) as List<dynamic>;
        setState(() {
          _properties = data.cast<AdminPropertyModel>();
        });
      }

      if (reportRes.statusCode >= 200 && reportRes.statusCode < 300) {
        setState(() {
          _globalReport = _reportService.parseGlobalReport(reportRes.body);
        });
      }

      if (notifRes.statusCode >= 200 && notifRes.statusCode < 300) {
        final notifications = _notificationService.parseNotifications(notifRes.body);
        setState(() {
          _unreadNotifications = notifications.where((n) => !n.isRead).length;
        });
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now());

    // Statistik dari Global Report API
    final int totalProperti = _globalReport?.totalProperties ?? _properties.length;
    final int totalTersedia = _globalReport?.availableProperties ?? _properties.where((p) => p.status.toLowerCase() == 'available').length;
    final int totalBooking = _globalReport?.bookingProperties ?? _properties.where((p) => p.status.toLowerCase() == 'booking').length;
    final int totalTerjual = _globalReport?.soldProperties ?? _properties.where((p) => p.status.toLowerCase() == 'sold').length;
    final int totalPembeli = _globalReport?.totalBuyers ?? 0;
    final int totalTransaksi = _globalReport?.confirmedTransactions ?? 0;
    final double totalPendapatan = _globalReport?.totalRevenue ?? 0;

    List<DashboardPropertyListItem> recentProperties = [];

    if (_properties.isNotEmpty) {
      final sortedProps = List<AdminPropertyModel>.from(_properties);
      sortedProps.sort((a, b) => b.id.compareTo(a.id));
      final recent = sortedProps.take(4).toList();
      recentProperties = recent.map((p) {
        Color statusColor = const Color(0xFF4CAF50);
        String statusLabel = 'Tersedia';
        if (p.status.toLowerCase() == 'booking') {
          statusColor = const Color(0xFFFFC107);
          statusLabel = 'Booking';
        } else if (p.status.toLowerCase() == 'sold') {
          statusColor = const Color(0xFFF44336);
          statusLabel = 'Terjual';
        } else if (p.status.toLowerCase() == 'archived') {
          statusColor = Colors.grey;
          statusLabel = 'Arsip';
        }

        return DashboardPropertyListItem(
          imageUrl: p.imageUrl ?? '',
          title: p.title,
          subtitle: '${p.category} • Rp ${NumberFormat('#,###', 'id_ID').format(p.price)}',
          status: statusLabel,
          statusColor: statusColor,
          onTap: () {
            Navigator.pushNamed(context, '/property-detail', arguments: p.id);
          },
        );
      }).toList();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B3E0F)))
        : SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat datang, ${widget.userName} 👋',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Berikut adalah ringkasan aktivitas penjualan properti hari ini.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Notifications Icon
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/notifications').then((_) => _loadData());
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.notifications_none_rounded, color: Colors.grey, size: 24),
                            if (_unreadNotifications > 0)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    _unreadNotifications > 99 ? '99+' : '$_unreadNotifications',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Tanggal — read-only (non-clickable)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            today,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Summary Cards Row 1: Properti
            Row(
              children: [
                Expanded(
                  child: DashboardSummaryCard(
                    icon: Icons.home_rounded,
                    iconColor: const Color(0xFF8B3E0F),
                    iconBgColor: const Color(0xFFFFF0E6),
                    title: 'Total Properti',
                    value: '$totalProperti',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DashboardSummaryCard(
                    icon: Icons.check_circle_rounded,
                    iconColor: const Color(0xFF3F51B5),
                    iconBgColor: const Color(0xFFE8EAF6),
                    title: 'Tersedia',
                    value: '$totalTersedia',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DashboardSummaryCard(
                    icon: Icons.assignment_rounded,
                    iconColor: const Color(0xFFCC7A2E),
                    iconBgColor: const Color(0xFFFFF5EB),
                    title: 'Booking',
                    value: '$totalBooking',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DashboardSummaryCard(
                    icon: Icons.sell_rounded,
                    iconColor: const Color(0xFFF44336),
                    iconBgColor: const Color(0xFFFCE8E6),
                    title: 'Terjual',
                    value: '$totalTerjual',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Summary Cards Row 2: Bisnis
            Row(
              children: [
                Expanded(
                  child: DashboardSummaryCard(
                    icon: Icons.people_rounded,
                    iconColor: const Color(0xFF9C27B0),
                    iconBgColor: const Color(0xFFF3E5F5),
                    title: 'Total Pembeli',
                    value: '$totalPembeli',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DashboardSummaryCard(
                    icon: Icons.receipt_long_rounded,
                    iconColor: const Color(0xFF009688),
                    iconBgColor: const Color(0xFFE0F2F1),
                    title: 'Transaksi',
                    value: '$totalTransaksi',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: DashboardSummaryCard(
                    icon: Icons.attach_money_rounded,
                    iconColor: const Color(0xFF4CAF50),
                    iconBgColor: const Color(0xFFE8F5E9),
                    title: 'Total Pendapatan',
                    value: 'Rp ${NumberFormat('#,###', 'id_ID').format(totalPendapatan)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Middle Row: Chart & Recent Properties
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 360,
                    child: DashboardChartSection(),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 360,
                    child: DashboardListSection(
                      title: 'Properti Terbaru',
                      onSeeAll: () {
                        Navigator.pushNamed(context, '/admin/properties');
                      },
                      items: recentProperties.isEmpty ? const [
                        Center(child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Belum ada properti'),
                        ))
                      ] : recentProperties,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Statistics Donut (Activities removed)
            Center(
              child: SizedBox(
                height: 360,
                child: DashboardDonutChart(properties: _properties),
              ),
            ),
          ],
        ),
      ),
    );
  }
}