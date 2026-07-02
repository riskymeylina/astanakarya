import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../models/admin_models.dart';

class DashboardDonutChart extends StatelessWidget {
  final List<AdminPropertyModel> properties;

  const DashboardDonutChart({
    super.key,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    int tersedia = properties.where((p) => p.status.toLowerCase() == 'available').length;
    int booking = properties.where((p) => p.status.toLowerCase() == 'booking').length;
    int terjual = properties.where((p) => p.status.toLowerCase() == 'sold').length;
    int arsip = properties.where((p) => p.status.toLowerCase() == 'archived' || p.status.toLowerCase() == 'draft').length;
    
    int total = properties.length;
    if (total == 0) total = 1;

    String formatPct(int val) {
      if (total == 0) return '0%';
      return '${((val / total) * 100).toStringAsFixed(1)}%';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ketersediaan Properti',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              color: const Color(0xFF4CAF50),
                              value: (tersedia / total) * 100,
                              title: '',
                              radius: 25,
                            ),
                            PieChartSectionData(
                              color: const Color(0xFFFFC107),
                              value: (booking / total) * 100,
                              title: '',
                              radius: 25,
                            ),
                            PieChartSectionData(
                              color: const Color(0xFFF44336),
                              value: (terjual / total) * 100,
                              title: '',
                              radius: 25,
                            ),
                            PieChartSectionData(
                              color: Colors.grey,
                              value: (arsip / total) * 100,
                              title: '',
                              radius: 25,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${properties.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const Text(
                            'Total Unit',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('Tersedia', const Color(0xFF4CAF50), '$tersedia', formatPct(tersedia)),
                      const SizedBox(height: 16),
                      _buildLegendItem('Booking', const Color(0xFFFFC107), '$booking', formatPct(booking)),
                      const SizedBox(height: 16),
                      _buildLegendItem('Terjual', const Color(0xFFF44336), '$terjual', formatPct(terjual)),
                      const SizedBox(height: 16),
                      _buildLegendItem('Arsip/Draft', Colors.grey, '$arsip', formatPct(arsip)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Tingkat penjualan',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Properti terjual dari total properti',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              Text(
                formatPct(terjual),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFFCC7A2E)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String value, String percentage) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
              ),
              Text(
                percentage,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
