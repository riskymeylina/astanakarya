import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../models/property_model.dart';
import '../../models/survey_request_model.dart';
import '../../services/property_service.dart';
import '../../services/survey_service.dart';
import '../../widgets/braga_page_header.dart';
import 'survey_shared.dart';

// ═══════════════════════════════════════════════════════════════
// COLORS
// ═══════════════════════════════════════════════════════════════
const Color surveyBrown = Color(0xFF8B4513);
const Color surveyCreamBg = Color(0xFFF8F4EF);
const Color surveyInk = Color(0xFF2B2B2B);
const Color surveyMuted = Color(0xFF777777);
const Color surveyGreen = Color(0xFF1FA45B);

// ═══════════════════════════════════════════════════════════════
// SURVEY DETAIL PAGE
// ═══════════════════════════════════════════════════════════════
class SurveyDetailPage extends StatefulWidget {
  const SurveyDetailPage({
    super.key,
    required this.surveyId,
    required this.propertyId,
    required this.propertyTitle,
  });

  final int surveyId;
  final int propertyId;
  final String propertyTitle;

  @override
  State<SurveyDetailPage> createState() =>
      _SurveyDetailPageState();
}

class _SurveyDetailPageState
    extends State<SurveyDetailPage> {
  final SurveyService _svc = SurveyService();
  final PropertyService _propSvc =
      PropertyService();

  SurveyRequestModel? _survey;
  PropertyModel? _property;

  bool _isLoading = true;
  bool _localeReady = false;

  String? _error;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await initializeDateFormatting('id_ID');

    if (!mounted) return;

    setState(() {
      _localeReady = true;
    });

    await _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response =
          await _svc.getMySurveyRequests();

      if (!mounted) return;

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final list =
            _svc.parseSurveys(response.body);

        final match = list.where(
          (s) => s.id == widget.surveyId,
        );

        if (match.isNotEmpty) {
          setState(() {
            _survey = match.first;
            _isLoading = false;
          });

          try {
            final pr =
                await _propSvc.getPropertyDetail(
              widget.propertyId,
            );

            if (pr.statusCode >= 200 &&
                pr.statusCode < 300 &&
                mounted) {
              setState(() {
                _property = _propSvc
                    .parsePropertyDetail(pr.body);
              });
            }
          } catch (_) {}

          return;
        }
      }

      setState(() {
        _error =
            'Data survei tidak ditemukan.';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ═══════════════════════════════════════════════════════════
  // CANCEL SURVEY
  // ═══════════════════════════════════════════════════════════
  Future<void> _cancelSurvey() async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          backgroundColor:
              surveyCreamBg,
          title: const Text(
            'Batalkan Survei?',
            style: TextStyle(
              fontWeight:
                  FontWeight.w900,
              color: surveyInk,
            ),
          ),
          content: const Text(
            'Pengajuan survei akan dibatalkan.',
            style: TextStyle(
              color: surveyMuted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                    context, false);
              },
              child: const Text(
                'Tidak',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                    context, true);
              },
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFFB84040,
                ),
              ),
              child:
                  const Text('Ya'),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !mounted) return;

    try {
      final response =
          await _svc.cancelSurveyRequest(
        widget.surveyId,
      );

      if (!mounted) return;

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Survei berhasil dibatalkan',
            ),
            backgroundColor:
                surveyGreen,
          ),
        );

        await _load();
      }
    } catch (_) {}
  }

  // ═══════════════════════════════════════════════════════════
  // FORMATTER
  // ═══════════════════════════════════════════════════════════
  String _fmtLong(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Belum Ditentukan';
    }

    try {
      return _localeReady
          ? DateFormat(
              'd MMMM yyyy',
              'id_ID',
            ).format(
              DateTime.parse(
                  value.trim()),
            )
          : value;
    } catch (_) {
      return value;
    }
  }

  String _fmtTime(String? value, [String? notes]) {
    if (notes != null && notes.isNotEmpty) {
      final match = RegExp(
        r'Rentang kedatangan:\s*([0-9]{2}:[0-9]{2})\s*[-–]\s*([0-9]{2}:[0-9]{2})',
      ).firstMatch(notes);
      if (match != null) {
        final start = match.group(1);
        final end = match.group(2);
        return '$start - $end WIB';
      }
    }

    if (value == null || value.trim().isEmpty) {
      return 'Belum Ditentukan';
    }

    final raw = value.trim();
    final normalized = raw.length == 5 ? '$raw:00' : raw;
    try {
      final formatted = DateFormat('HH:mm').format(DateFormat('HH:mm:ss').parseStrict(normalized));
      return '$formatted WIB';
    } catch (_) {
      return '$raw WIB';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F4EF),

      body: Column(
          children: [
            const BragaPageHeader(
              title: 'Jadwal Survei Saya',
              subtitle: 'Pantau status pengajuan survei properti Anda',
              decorativeIcon: Icons.calendar_month_outlined,
            ),
            Expanded(
              child: RefreshIndicator(
                color: surveyBrown,
                onRefresh: _load,

                child: _isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(
                          color:
                              surveyBrown,
                        ),
                      )
                    : _error != null
                        ? ListView(
                            padding:
                                const EdgeInsets
                                    .all(20),
                            children: [
                              _DetailErrorCard(
                                message:
                                    _error!,
                                onRetry:
                                    _load,
                              ),
                            ],
                          )
                        : ListView(
                            padding:
                                const EdgeInsets
                                    .all(18),

                            children: [
                              // DETAIL CARD
                              Container(
                                padding:
                                    const EdgeInsets
                                        .all(22),

                                decoration: BoxDecoration(
                                  color: Colors.white,

                                  borderRadius: BorderRadius.circular(16),

                                  border:
                                      Border.all(
                                    color:
                                        const Color(
                                      0xFFE7D9CB,
                                    ),
                                  ),

                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors
                                          .black
                                          .withOpacity(
                                              0.03),
                                      blurRadius:
                                          20,
                                      offset:
                                          const Offset(
                                        0,
                                        8,
                                      ),
                                    ),
                                  ],
                                ),

                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [
                                    // TOP SECTION
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,

                                      children: [
                                        Expanded(
                                          child:
                                              Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,

                                            children: [
                                              Text(
                                                _survey!
                                                    .propertyTitle,

                                                style:
                                                    const TextStyle(
                                                  fontSize:
                                                      22,
                                                  fontWeight:
                                                      FontWeight
                                                          .w900,
                                                  color:
                                                      surveyInk,
                                                ),
                                              ),

                                              const SizedBox(
                                                  height:
                                                      10),

                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.location_on_outlined,
                                                    size:
                                                        17,
                                                    color:
                                                        surveyMuted,
                                                  ),

                                                  const SizedBox(
                                                      width:
                                                          6),

                                                  Expanded(
                                                    child:
                                                        Text(
                                                      _survey!.propertyLocation,
                                                      style:
                                                          const TextStyle(
                                                        color:
                                                            surveyMuted,
                                                        fontSize:
                                                            14,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                            horizontal:
                                                20,
                                            vertical:
                                                10,
                                          ),

                                          decoration:
                                              BoxDecoration(
                                            color:
                                                const Color(
                                              0xFFFFE9A9,
                                            ),

                                            borderRadius:
                                                BorderRadius.circular(
                                                    50),
                                          ),

                                          child: Text(
                                            surveyStatusLabel(
                                              _survey!
                                                  .status,
                                            ),

                                            style:
                                                const TextStyle(
                                              color:
                                                  Color(
                                                0xFF8A6500,
                                              ),
                                              fontWeight:
                                                  FontWeight
                                                      .w800,
                                              fontSize:
                                                  13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(
                                        height: 24),

                                    // DATE TIME
                                    Row(
                                      children: [
                                        Expanded(
                                          child:
                                              _newInfoCard(
                                            icon:
                                                Icons.calendar_today_outlined,
                                            title:
                                                'Tanggal',
                                            value:
                                                _fmtLong(
                                              (_survey!.isApproved || _survey!.isCompleted)
                                                  ? _survey!.approvedScheduleDate
                                                  : _survey!.requestedDate,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(
                                            width:
                                                16),

                                        Expanded(
                                          child:
                                              _newInfoCard(
                                            icon:
                                                Icons.schedule_outlined,
                                            title:
                                                'Jam',
                                            value:
                                                _fmtTime(
                                              (_survey!.isApproved || _survey!.isCompleted)
                                                  ? _survey!.approvedScheduleTime
                                                  : _survey!.requestedTime,
                                              _survey!.notes,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(
                                        height: 26),

                                    // PROGRESS
                                    Container(
                                      width: double
                                          .infinity,

                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal:
                                            18,
                                        vertical:
                                            22,
                                      ),

                                      decoration:
                                          BoxDecoration(
                                        color:
                                            const Color(
                                          0xFFFBF7F2,
                                        ),

                                        borderRadius:
                                            BorderRadius.circular(
                                                22),

                                        border:
                                            Border.all(
                                          color:
                                              const Color(
                                            0xFFE9DDD0,
                                          ),
                                        ),
                                      ),

                                      child:
                                          SurveyProgressTracker(
                                        currentStatus:
                                            parseSurveyStatus(_survey!.status),
                                        requestedDate: _survey!.requestedDate,
                                        requestedTime: _survey!.requestedTime,
                                        approvedScheduleDate: _survey!.approvedScheduleDate,
                                        approvedScheduleTime: _survey!.approvedScheduleTime,
                                      ),
                                    ),

                                    if (_survey!.status == 'rejected' &&
                                        _survey!.rejectionReason != null &&
                                        _survey!.rejectionReason!.trim().isNotEmpty) ...[
                                      const SizedBox(height: 20),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFDF2F2),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: const Color(0xFFF8D7DA),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: const [
                                                Icon(
                                                  Icons.error_outline_rounded,
                                                  color: Color(0xFFC93535),
                                                  size: 20,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Alasan Penolakan',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 14,
                                                    color: Color(0xFFC93535),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              _survey!.rejectionReason!,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF7D2424),
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],

                                    const SizedBox(
                                        height: 22),

                                    // BUTTONS
                                      Builder(
                                        builder: (context) {
                                          final currentStatus = parseSurveyStatus(_survey?.status);
                                          final isApproved = currentStatus == SurveyStatus.approved;
                                          final canCancel = currentStatus != SurveyStatus.cancelled && currentStatus != SurveyStatus.rejected && currentStatus != SurveyStatus.completed;
                                          final canEdit = currentStatus == SurveyStatus.pending || currentStatus == SurveyStatus.rejected;

                                          return Row(
                                            children: [
                                              Expanded(
                                                child: SizedBox(
                                                  height: 56,
                                                  child: OutlinedButton.icon(
                                                    onPressed: canEdit ? () {
                                                      if (_survey == null) return;
                                                      Navigator.pushNamed(
                                                        context,
                                                        '/survey-form',
                                                        arguments: {
                                                          'propertyId': _survey!.propertyId,
                                                          'propertyTitle': _survey!.propertyTitle,
                                                          'surveyId': _survey!.id,
                                                          'requestedDate': _survey!.requestedDate,
                                                          'requestedTime': _survey!.requestedTime,
                                                          'notes': _survey!.notes,
                                                        },
                                                      );
                                                    } : null,
                                                    icon: const Icon(
                                                      Icons.edit_calendar_outlined,
                                                      size: 20,
                                                    ),
                                                    label: Text(
                                                      currentStatus == SurveyStatus.rejected ? 'Ajukan Ulang' : 'Ubah Jadwal',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w800,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    style: OutlinedButton.styleFrom(
                                                      foregroundColor: canEdit ? surveyBrown : Colors.grey.shade400,
                                                      side: BorderSide(
                                                        color: canEdit ? surveyBrown : Colors.grey.shade300,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(16),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(width: 16),

                                              Expanded(
                                                child: SizedBox(
                                                  height: 56,
                                                  child: ElevatedButton.icon(
                                                    onPressed: canCancel ? _cancelSurvey : null,
                                                    icon: const Icon(
                                                      Icons.close_rounded,
                                                      size: 20,
                                                    ),
                                                    label: const Text(
                                                      'Batalkan',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w800,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: canCancel
                                                          ? const Color(0xFFC93535)
                                                          : Colors.grey.shade300,
                                                      foregroundColor: canCancel ? Colors.white : Colors.grey.shade500,
                                                      elevation: 0,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(16),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),

                              const SizedBox(
                                  height: 30),
                            ],
                          ),
              ),
            ),
          ],
        ),
      );
  }
}

// ═══════════════════════════════════════════════════════════════
// INFO CARD
// ═══════════════════════════════════════════════════════════════
Widget _newInfoCard({
  required IconData icon,
  required String title,
  required String value,
}) {
  return Container(
    padding:
        const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),

    decoration: BoxDecoration(
      color: const Color(0xFFFCF8F3),

      borderRadius:
          BorderRadius.circular(16),

      border: Border.all(
        color: const Color(0xFFE6D7C7),
      ),
    ),

    child: Row(
      children: [
        Icon(
          icon,
          size: 20,
          color:
              const Color(0xFFBF6D2A),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF777777),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
// STATUS LABEL
// ═══════════════════════════════════════════════════════════════
String surveyStatusLabel(dynamic status) {
  switch (parseSurveyStatus(status?.toString())) {
    case SurveyStatus.pending:
      return 'Menunggu Persetujuan';
    case SurveyStatus.approved:
      return 'Disetujui';
    case SurveyStatus.completed:
      return 'Selesai';
    case SurveyStatus.rejected:
      return 'Ditolak';
    case SurveyStatus.cancelled:
      return 'Dibatalkan';
    case SurveyStatus.unknown:
    default:
      return 'Tidak diketahui';
  }
}

// ═══════════════════════════════════════════════════════════════
// ERROR CARD
// ═══════════════════════════════════════════════════════════════
class _DetailErrorCard
    extends StatelessWidget {
  const _DetailErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: const Color(0xFFE6D7C7),
        ),
      ),

      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 54,
            color: Colors.red,
          ),

          const SizedBox(height: 18),

          Text(
            message,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 22),

          ElevatedButton(
            onPressed: onRetry,

            child:
                const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SURVEY PROGRESS TRACKER
// ═══════════════════════════════════════════════════════════════
class SurveyProgressTracker
    extends StatelessWidget {
  const SurveyProgressTracker({
    super.key,
    required this.currentStatus,
    this.requestedDate,
    this.requestedTime,
    this.approvedScheduleDate,
    this.approvedScheduleTime,
  });

  final SurveyStatus currentStatus;
  final String? requestedDate;
  final String? requestedTime;
  final String? approvedScheduleDate;
  final String? approvedScheduleTime;

  @override
  Widget build(BuildContext context) {
    int currentStep = 1;
    final isCancelled = currentStatus == SurveyStatus.cancelled;
    final isRejected = currentStatus == SurveyStatus.rejected;

    if (currentStatus == SurveyStatus.pending) {
      currentStep = 2;
    } else if (currentStatus == SurveyStatus.approved) {
      currentStep = 3; // Default is Dikonfirmasi
      
      // Sinkronisasi dengan Tanggal & Jam
      if (requestedDate != null) {
        try {
          final dateStr = (approvedScheduleDate ?? requestedDate)!.split('T')[0];
          final timeStr = approvedScheduleTime ?? requestedTime ?? "00:00:00";
          final surveyDateTime = DateTime.parse('${dateStr}T${timeStr}');
          final now = DateTime.now();
          
          if (now.isAfter(surveyDateTime)) {
            currentStep = 4; // Berlangsung jika waktu telah lewat, tetapi status belum selesai
          }
        } catch (_) {}
      }
    } else if (currentStatus == SurveyStatus.completed) {
      currentStep = 5; // Selesai
    } else if (isCancelled || isRejected) {
      currentStep = 2;
    }

    final steps = [
      'Pengajuan',
      isCancelled
          ? 'Dibatalkan'
          : (isRejected ? 'Ditolak' : 'Menunggu'),
      'Dikonfirmasi',
      'Berlangsung',
      'Selesai',
    ];

    return Row(
      children: List.generate(
        steps.length,
        (index) {
          final step = index + 1;
          final active = step <= currentStep;
          final isFailedStep = (isCancelled || isRejected) && step == 2;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active
                              ? (isFailedStep
                                  ? const Color(0xFFC93535)
                                  : const Color(0xFF23A35A))
                              : Colors.white,
                          border: Border.all(
                            color: active
                                ? (isFailedStep
                                    ? const Color(0xFFC93535)
                                    : const Color(0xFF23A35A))
                                : const Color(0xFFD8CEC3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          active
                              ? (isFailedStep ? Icons.close : Icons.check)
                              : Icons.circle,
                          size: active ? 16 : 8,
                          color: active
                              ? Colors.white
                              : const Color(0xFFD8CEC3),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        steps[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: active
                              ? (isFailedStep
                                  ? const Color(0xFFC93535)
                                  : const Color(0xFF16924C))
                              : const Color(0xFFA89C90),
                        ),
                      ),
                    ],
                  ),
                ),
                if (index != steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.only(bottom: 30),
                      decoration: BoxDecoration(
                        color: (active && !isFailedStep)
                            ? const Color(0xFF23A35A)
                            : const Color(0xFFE0D6CA),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}