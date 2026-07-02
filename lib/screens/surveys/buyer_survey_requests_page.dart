import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../models/survey_request_model.dart';
import '../../models/purchase_order_model.dart';
import '../../services/survey_service.dart';
import '../../services/purchase_service.dart';
import '../../widgets/braga_page_header.dart';
import 'survey_shared.dart';

// ═════════════════════════════════════════════════════════════════════════════
// BUYER SURVEY REQUESTS PAGE
// ═════════════════════════════════════════════════════════════════════════════
class BuyerSurveyRequestsPage extends StatefulWidget {
  const BuyerSurveyRequestsPage({super.key});

  @override
  State<BuyerSurveyRequestsPage> createState() =>
      _BuyerSurveyRequestsPageState();
}

class _BuyerSurveyRequestsPageState
    extends State<BuyerSurveyRequestsPage> {
  final SurveyService _svc = SurveyService();

  bool _isLoading = true;
  bool _localeReady = false;

  String? _error;

  List<SurveyRequestModel> _surveys =
      const [];

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await initializeDateFormatting(
      'id_ID',
    );

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

    final r =
        await _svc.getMySurveyRequests();

    if (!mounted) return;

    if (r.statusCode >= 200 &&
        r.statusCode < 300) {
      final list =
          _svc.parseSurveys(r.body);

      list.sort((a, b) {
        try {
          final da = DateTime.parse(
            a.requestedDate ??
                '2000-01-01',
          );

          final db = DateTime.parse(
            b.requestedDate ??
                '2000-01-01',
          );

          return db.compareTo(da);
        } catch (_) {
          return 0;
        }
      });

      setState(() {
        _surveys = list;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error =
            _svc.parseMessage(r.body);

        _isLoading = false;
      });
    }
  }

  // ═══════════════════════════════════════════════════════════
  // OPEN FORM
  // ═══════════════════════════════════════════════════════════
  void _goToForm() {
    Navigator.pushNamed(
      context,
      '/survey/new',
    );
  }

  // ═══════════════════════════════════════════════════════════
  // OPEN DETAIL
  // ═══════════════════════════════════════════════════════════
  void _openDetail(
    SurveyRequestModel survey,
  ) {
    Navigator.pushNamed(
      context,
      '/survey-detail',
      arguments: {
        'surveyId': survey.id,
        'propertyId':
            survey.propertyId,
        'propertyTitle':
            survey.propertyTitle,
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // FORMATTERS
  // ═══════════════════════════════════════════════════════════
  String _fmtShort(String? v) {
    if (v == null ||
        v.trim().isEmpty) {
      return 'Belum Ditentukan';
    }

    try {
      return _localeReady
          ? DateFormat(
              'd MMM yyyy',
              'id_ID',
            ).format(
              DateTime.parse(
                v.trim(),
              ),
            )
          : v.trim();
    } catch (_) {
      return v.trim();
    }
  }

  String _fmtTime(String? v, [String? notes]) {
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

    if (v == null ||
        v.trim().isEmpty) {
      return 'Belum Ditentukan';
    }

    final n = v.trim().length == 5
        ? '${v.trim()}:00'
        : v.trim();

    try {
      return '${DateFormat('HH:mm').format(DateFormat('HH:mm:ss').parseStrict(n))} WIB';
    } catch (_) {
      return v.trim();
    }
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          surveyCreamBg,

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _goToForm,

        backgroundColor:
            surveyBrownDeep,

        foregroundColor:
            Colors.white,

        elevation: 3,

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            18,
          ),
        ),

        icon: const Icon(
          Icons.add_rounded,
          size: 20,
        ),

        label: const Text(
          'Ajukan Survei',
          style: TextStyle(
            fontWeight:
                FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),

      body: Column(
        children: [
          const BragaPageHeader(
            title: 'Pengajuan Survei',
            subtitle: 'Riwayat pengajuan survei properti Anda',
            decorativeIcon: Icons.assignment_outlined,
          ),
          // ═════════ BODY ═════════
          Expanded(
            child:
                RefreshIndicator(
              onRefresh: _load,
              color:
                  surveyBrown,

              child: _body(),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BODY
  // ═══════════════════════════════════════════════════════════
  Widget _body() {
    if (!_localeReady ||
        _isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(
          color: surveyBrown,
        ),
      );
    }

    if (_error != null) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),

        padding:
            const EdgeInsets.all(
          20,
        ),

        children: [
          _RequestsErrorCard(
            message: _error!,
            onRetry: _load,
          ),
        ],
      );
    }

    if (_surveys.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),

        padding:
            const EdgeInsets.fromLTRB(
          18,
          6,
          18,
          120,
        ),

        children: const [
          _RequestsEmptyCard(),
        ],
      );
    }

    return ListView.separated(
      physics:
          const AlwaysScrollableScrollPhysics(),

      padding:
          const EdgeInsets.fromLTRB(
        18,
        6,
        18,
        120,
      ),

      itemCount:
          _surveys.length,

      separatorBuilder:
          (_, __) =>
              const SizedBox(
        height: 16,
      ),

      itemBuilder: (_, i) {
        return _SurveyListCard(
          survey:
              _surveys[i],
          fmtShort:
              _fmtShort,
          fmtTime:
              _fmtTime,
          onTap: () {
            _openDetail(
              _surveys[i],
            );
          },
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SURVEY LIST CARD
// ═════════════════════════════════════════════════════════════════════════════
class _SurveyListCard
    extends StatelessWidget {
  const _SurveyListCard({
    required this.survey,
    required this.fmtShort,
    required this.fmtTime,
    required this.onTap,
  });

  final SurveyRequestModel survey;

  final String Function(
    String?,
  ) fmtShort;

  final String Function(
    String?, [String?]
  ) fmtTime;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = parseSurveyStatus(survey.status);

    final isApproved = status == SurveyStatus.approved;

    return InkWell(
      borderRadius:
          BorderRadius.circular(
        26,
      ),

      onTap: onTap,

      child: Container(
        padding:
            const EdgeInsets.all(
          22,
        ),

        decoration:
            BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(
            26,
          ),

          border: Border.all(
            color:
                surveyBorder,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(
                0.03,
              ),
              blurRadius: 18,
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
            // TOP
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [
                      Text(
                        survey
                            .propertyTitle,
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,

                        style:
                            const TextStyle(
                          fontSize:
                              18,
                          fontWeight:
                              FontWeight
                                  .w900,
                          color:
                              surveyInk,
                          height:
                              1.3,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Row(
                        children: [
                          const Icon(
                            Icons
                                .location_on_outlined,
                            size: 16,
                            color:
                                surveyMuted,
                          ),

                          const SizedBox(
                            width: 6,
                          ),

                          Expanded(
                            child: Text(
                              survey
                                  .propertyLocation,

                              maxLines:
                                  1,

                              overflow:
                                  TextOverflow
                                      .ellipsis,

                              style:
                                  const TextStyle(
                                fontSize:
                                    13,
                                color:
                                    surveyMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal:
                        14,
                    vertical: 8,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFFFE9A9,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      50,
                    ),
                  ),

                  child:
                      SurveyStatusBadge(
                    status:
                        status,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 22,
            ),

            // DATE TIME
            Row(
              children: [
                Expanded(
                  child:
                      _InfoMiniCard(
                    icon:
                        Icons.calendar_today_outlined,
                    title:
                        'Tanggal',
                    value:
                        fmtShort(
                      (survey.isApproved || survey.isCompleted)
                          ? survey.approvedScheduleDate
                          : survey.requestedDate,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 14,
                ),

                Expanded(
                  child:
                      _InfoMiniCard(
                    icon:
                        Icons.access_time_rounded,
                    title:
                        'Jam',
                    value:
                        fmtTime(
                      (survey.isApproved || survey.isCompleted)
                          ? survey.approvedScheduleTime
                          : survey.requestedTime,
                      survey.notes,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 18,
            ),

            Text(
              _statusDesc(
                status,
              ),

              style:
                  const TextStyle(
                fontSize: 13,
                color:
                    surveyMuted,
                height: 1.5,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            // BUTTON
            Row(
              children: [
                Expanded(
                  child:
                      ElevatedButton(
                    onPressed:
                        onTap,

                    style:
                        ElevatedButton.styleFrom(
                      elevation:
                          0,

                      backgroundColor:
                          surveyBrownDeep,

                      foregroundColor:
                          Colors.white,

                      padding:
                          const EdgeInsets.symmetric(
                        vertical:
                            16,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),

                    child: Text(
                      isApproved
                          ? 'Lihat Detail'
                          : 'Lihat Detail',

                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight
                                .w800,
                        fontSize:
                            14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusDesc(SurveyStatus s) {
    switch (s) {
      case SurveyStatus.pending:
        return 'Menunggu konfirmasi dari staf kami.';
      case SurveyStatus.approved:
        return 'Survei telah disetujui dan dijadwalkan.';
      case SurveyStatus.completed:
        return 'Survei telah selesai dilaksanakan.';
      case SurveyStatus.rejected:
        return 'Survei telah ditolak oleh staf.';
      case SurveyStatus.cancelled:
        return 'Pengajuan survei telah dibatalkan.';
      case SurveyStatus.unknown:
      default:
        return 'Status tidak diketahui.';
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// INFO MINI CARD
// ═════════════════════════════════════════════════════════════════════════════
class _InfoMiniCard
    extends StatelessWidget {
  const _InfoMiniCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFFCF8F3,
        ),

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        border: Border.all(
          color:
              const Color(
            0xFFE6D7C7,
          ),
        ),
      ),

      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color:
                const Color(
              0xFFBF6D2A,
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize:
                        11,
                    color:
                        surveyMuted,
                    fontWeight:
                        FontWeight
                            .w600,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,

                  style:
                      const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight
                            .w900,
                    color:
                        surveyInk,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// EMPTY CARD
// ═════════════════════════════════════════════════════════════════════════════
class _RequestsEmptyCard
    extends StatelessWidget {
  const _RequestsEmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 40,
      ),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          24,
        ),

        border: Border.all(
          color:
              surveyBorder,
        ),
      ),

      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,

            decoration:
                BoxDecoration(
              color:
                  surveyCream
                      .withOpacity(
                0.5,
              ),

              shape:
                  BoxShape.circle,
            ),

            child: const Icon(
              Icons
                  .event_note_rounded,
              size: 40,
              color:
                  surveyBrown,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          const Text(
            'Belum Ada Pengajuan',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w900,
              color: surveyInk,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          const Text(
            'Ajukan survei properti Anda dengan menekan tombol di bawah.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color:
                  surveyMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ERROR CARD
// ═════════════════════════════════════════════════════════════════════════════
class _RequestsErrorCard
    extends StatelessWidget {
  const _RequestsErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(
        24,
      ),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          24,
        ),

        border: Border.all(
          color:
              surveyBorder,
        ),
      ),

      child: Column(
        children: [
          const Icon(
            Icons
                .error_outline_rounded,
            size: 54,
            color:
                Color(0xFFB84040),
          ),

          const SizedBox(
            height: 18,
          ),

          const Text(
            'Gagal Memuat Data',
            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w900,
              color: surveyInk,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            message,
            textAlign:
                TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color:
                  surveyMuted,
              height: 1.5,
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          ElevatedButton.icon(
            onPressed: onRetry,

            icon: const Icon(
              Icons.refresh_rounded,
              size: 18,
            ),

            label:
                const Text(
              'Coba Lagi',
            ),

            style:
                ElevatedButton.styleFrom(
              elevation: 0,

              backgroundColor:
                  surveyBrown,

              foregroundColor:
                  Colors.white,

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}