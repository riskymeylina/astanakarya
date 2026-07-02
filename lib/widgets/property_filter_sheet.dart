import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PropertyFilterSheet extends StatefulWidget {
  final String? initialStatus;
  final int? initialMinPrice;
  final int? initialMaxPrice;
  final String? initialSortBy;

  const PropertyFilterSheet({
    super.key,
    this.initialStatus,
    this.initialMinPrice,
    this.initialMaxPrice,
    this.initialSortBy,
  });

  @override
  State<PropertyFilterSheet> createState() => _PropertyFilterSheetState();

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    String? initialStatus,
    int? initialMinPrice,
    int? initialMaxPrice,
    String? initialSortBy,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => PropertyFilterSheet(
          initialStatus: initialStatus,
          initialMinPrice: initialMinPrice,
          initialMaxPrice: initialMaxPrice,
          initialSortBy: initialSortBy,
        ),
      ),
    );
  }
}

class _PropertyFilterSheetState extends State<PropertyFilterSheet> {
  String? _status;
  late double _minPriceMillion;
  late double _maxPriceMillion;
  late String _sortBy;

  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;

  @override
  void initState() {
    super.initState();
    _resetToValues(
      status: widget.initialStatus,
      minPrice: widget.initialMinPrice,
      maxPrice: widget.initialMaxPrice,
      sortBy: widget.initialSortBy,
    );
  }

  void _resetToValues({
    String? status,
    int? minPrice,
    int? maxPrice,
    String? sortBy,
  }) {
    String? normStatus = status;
    if (normStatus == 'available') normStatus = 'Tersedia';
    if (normStatus == 'booking') normStatus = 'Sedang Dibooking';
    if (normStatus == 'sold') normStatus = 'Terjual';
    _status = normStatus;
    _sortBy = sortBy ?? 'latest';

    final minVal = minPrice ?? 100000000;
    _minPriceMillion = (minVal / 1000000).clamp(100.0, 2000.0);

    final maxVal = maxPrice ?? 2000000000;
    _maxPriceMillion = (maxVal / 1000000).clamp(100.0, 2000.0);

    _minPriceController = TextEditingController(text: _formatPrice(minVal));
    _maxPriceController = TextEditingController(text: _formatPrice(maxVal));
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  String _formatPrice(int price) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(price);
  }

  int _parsePrice(String text) {
    final clean = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 0;
  }

  void _handleMinPriceTextChanged(String text) {
    final price = _parsePrice(text);
    final million = (price / 1000000).clamp(100.0, _maxPriceMillion);
    setState(() {
      _minPriceMillion = million;
    });
  }

  void _handleMaxPriceTextChanged(String text) {
    final price = _parsePrice(text);
    final million = (price / 1000000).clamp(_minPriceMillion, 2000.0);
    setState(() {
      _maxPriceMillion = million;
    });
  }

  void _applyFilters() {
    final minPriceVal = (_minPriceMillion * 1000000).round();
    final maxPriceVal = (_maxPriceMillion * 1000000).round();

    Navigator.pop(context, {
      'status': _status,
      'minPrice': minPriceVal,
      'maxPrice': maxPriceVal,
      'sortBy': _sortBy,
    });
  }

  void _resetAll() {
    setState(() {
      _status = null;
      _sortBy = 'latest';
      _minPriceMillion = 100.0;
      _maxPriceMillion = 2000.0;
      _minPriceController.text = _formatPrice(100000000);
      _maxPriceController.text = _formatPrice(2000000000);
    });
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2EBE4)),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2F2318),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRadioOption<T>({
    required T value,
    required T groupValue,
    required String label,
    Widget? trailing,
    required ValueChanged<T> onChanged,
  }) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF6EC) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF8D4E18) : const Color(0xFFD0C0B0),
                  width: isSelected ? 5.5 : 2,
                ),
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF2F2318) : const Color(0xFF6D5540),
              ),
            ),
            if (trailing != null) ...[
              const Spacer(),
              trailing,
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBEF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF763C11),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.filter_alt_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Filter Properti',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Temukan properti sesuai kebutuhan Anda',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ],
            ),
          ),

          // Content Scroll Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 600;

                  final statusCard = _buildCard(
                    title: 'Status Properti',
                    children: [
                      _buildRadioOption<String?>(
                        value: null,
                        groupValue: _status,
                        label: 'Semua Status',
                        onChanged: (val) => setState(() => _status = val),
                      ),
                      _buildRadioOption<String?>(
                        value: 'Tersedia',
                        groupValue: _status,
                        label: 'Tersedia',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Tersedia',
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        onChanged: (val) => setState(() => _status = val),
                      ),
                      _buildRadioOption<String?>(
                        value: 'Sedang Dibooking',
                        groupValue: _status,
                        label: 'Dipesan',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Dipesan',
                            style: TextStyle(
                              color: Color(0xFFE65100),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        onChanged: (val) => setState(() => _status = val),
                      ),
                      _buildRadioOption<String?>(
                        value: 'Terjual',
                        groupValue: _status,
                        label: 'Terjual',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Terjual',
                            style: TextStyle(
                              color: Color(0xFFC62828),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        onChanged: (val) => setState(() => _status = val),
                      ),
                    ],
                  );

                  final priceCard = _buildCard(
                    title: 'Harga Properti',
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F3EE),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE8DFD8)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              (_minPriceMillion == 100.0 && _maxPriceMillion == 2000.0)
                                  ? 'Semua Harga'
                                  : '${(_minPriceMillion / 1000).toStringAsFixed(1)}M - ${(_maxPriceMillion / 1000).toStringAsFixed(1)}M',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2F2318),
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF6D5540),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Rp 100 Juta', style: TextStyle(fontSize: 11.5, color: Color(0xFF8A7560), fontWeight: FontWeight.bold)),
                          Text('Rp 2 Miliar', style: TextStyle(fontSize: 11.5, color: Color(0xFF8A7560), fontWeight: FontWeight.bold)),
                        ],
                      ),
                      RangeSlider(
                        values: RangeValues(_minPriceMillion, _maxPriceMillion),
                        min: 100,
                        max: 2000,
                        divisions: 19,
                        activeColor: const Color(0xFF8D4E18),
                        inactiveColor: const Color(0xFFE8DFD8),
                        onChanged: (values) {
                          setState(() {
                            _minPriceMillion = values.start;
                            _maxPriceMillion = values.end;
                            _minPriceController.text = _formatPrice((_minPriceMillion * 1000000).round());
                            _maxPriceController.text = _formatPrice((_maxPriceMillion * 1000000).round());
                          });
                        },
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 45,
                              child: TextField(
                                controller: _minPriceController,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFE8DFD8)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFE8DFD8)),
                                  ),
                                ),
                                onSubmitted: (val) {
                                  _handleMinPriceTextChanged(val);
                                  _minPriceController.text = _formatPrice((_minPriceMillion * 1000000).round());
                                },
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('-', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 45,
                              child: TextField(
                                controller: _maxPriceController,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFE8DFD8)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFE8DFD8)),
                                  ),
                                ),
                                onSubmitted: (val) {
                                  _handleMaxPriceTextChanged(val);
                                  _maxPriceController.text = _formatPrice((_maxPriceMillion * 1000000).round());
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );

                  final sortByCard = _buildCard(
                    title: 'Urutkan Berdasarkan',
                    children: [
                      _buildRadioOption<String>(
                        value: 'latest',
                        groupValue: _sortBy,
                        label: 'Terbaru',
                        onChanged: (val) => setState(() => _sortBy = val),
                      ),
                      _buildRadioOption<String>(
                        value: 'price_low',
                        groupValue: _sortBy,
                        label: 'Harga Terendah',
                        onChanged: (val) => setState(() => _sortBy = val),
                      ),
                      _buildRadioOption<String>(
                        value: 'price_high',
                        groupValue: _sortBy,
                        label: 'Harga Tertinggi',
                        onChanged: (val) => setState(() => _sortBy = val),
                      ),
                    ],
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              statusCard,
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              priceCard,
                              sortByCard,
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        statusCard,
                        priceCard,
                        sortByCard,
                      ],
                    );
                  }
                },
              ),
            ),
          ),

          // Bottom Bar
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: const Color(0xFFF2EBE4))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _resetAll,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Reset', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          foregroundColor: const Color(0xFF8D4E18),
                          side: const BorderSide(color: Color(0xFFD0C0B0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _applyFilters,
                        icon: const Icon(Icons.filter_alt_rounded, size: 18),
                        label: const Text('Terapkan Filter', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: const Color(0xFF8D4E18),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
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
}
