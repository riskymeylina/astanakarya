import 'package:flutter/material.dart';

import '../../services/consultation_service.dart';
import '../../widgets/braga_page_header.dart';
import 'consultation_detail_page.dart';

class BuyerConsultationRoomPage extends StatefulWidget {
  const BuyerConsultationRoomPage({super.key});

  @override
  State<BuyerConsultationRoomPage> createState() =>
      _BuyerConsultationRoomPageState();
}

class _BuyerConsultationRoomPageState extends State<BuyerConsultationRoomPage> {
  final ConsultationService _service = ConsultationService();

  bool _isLoading = true;
  String? _errorMessage;
  int? _consultationId;

  @override
  void initState() {
    super.initState();
    _loadRoom();
  }

  Future<void> _loadRoom() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _service.getMyConsultationRoom();
    if (!mounted) return;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      setState(() {
        _errorMessage = _service.parseMessage(response.body);
        _isLoading = false;
      });
      return;
    }

    final room = _service.parseConsultation(response.body);
    setState(() {
      _consultationId = room.id;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF7ED),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _consultationId == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF7ED),
        body: Column(
          children: [
            const BragaPageHeader(
              title: 'Chat Konsultasi',
              subtitle: 'Room konsultasi.',
              decorativeIcon: Icons.forum_rounded,
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.forum_rounded,
                        size: 48,
                        color: Color(0xFF8F4E1E),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage ?? 'Room konsultasi belum tersedia.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _loadRoom,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ConsultationDetailPage(consultationId: _consultationId!);
  }
}
