// survey_shared.dart
import 'package:flutter/material.dart';

// ─── THEME COLORS (BROWN & CREAM PREMIUM) ───────────────────────────────────
const Color surveyHdrDark   = Color(0xFF633A18);
const Color surveyHdrMid    = Color(0xFF8B5A2B);
const Color surveyBrown    = Color(0xFF5D3614);
const Color surveyBrownMid = Color(0xFFB57C3A);
const Color surveyBrownDeep= Color(0xFF4A2508);
const Color surveyCream    = Color(0xFFFDD096);
const Color surveyCreamBg  = Color(0xFFFAF6F0);
const Color surveyCreamCard= Color(0xFFFFFDFB);
const Color surveyBorder   = Color(0xFFEFE6DC);
const Color surveyInk      = Color(0xFF2E2A26);
const Color surveyMuted    = Color(0xFF8A7565);
const Color surveyLight    = Color(0xFFBAA695);
const Color surveyGreen    = Color(0xFF27AE60);
const Color surveyGreenBg  = Color(0xFFE8F8F0);
const Color surveyRed      = Color(0xFFC0392B);
const Color surveyRedBg    = Color(0xFFFADBD8);

// ─── STATUS ENUM ─────────────────────────────────────────────────────────────
enum SurveyStatus {
  pending,      // Menunggu Persetujuan
  approved,     // Disetujui
  completed,    // Selesai
  rejected,     // Ditolak
  cancelled,    // Dibatalkan
  unknown
}

SurveyStatus parseSurveyStatus(String? statusStr) {
  if (statusStr == null) return SurveyStatus.unknown;
  switch (statusStr.toLowerCase().trim()) {
    case 'pending':
    case 'menunggu':
    case 'menunggu persetujuan':
    case 'pending_confirmation':
    case 'submitted':
    case 'pengajuan':
      return SurveyStatus.pending;
    case 'approved':
    case 'confirmed':
    case 'dijadwalkan':
    case 'disetujui':
    case 'ongoing':
      return SurveyStatus.approved;
    case 'completed':
    case 'survei selesai':
    case 'selesai':
      return SurveyStatus.completed;
    case 'rejected':
    case 'ditolak':
      return SurveyStatus.rejected;
    case 'cancelled':
    case 'dibatalkan':
      return SurveyStatus.cancelled;
    default:
      return SurveyStatus.unknown;
  }
}

// ─── CUSTOM PREMIUM HEADER COMPONENT ─────────────────────────────────────────
class SurveyHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBackPressed;

  const SurveyHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [surveyHdrDark, surveyHdrMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (onBackPressed != null) ...[
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onBackPressed,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded, 
                    color: Colors.white, 
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 24, 
                    fontWeight: FontWeight.bold, 
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8), 
                    fontSize: 13, 
                    fontWeight: FontWeight.w400,
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

// ─── PROGRESS TRACKER ────────────────────────────────────────────────────────
class SurveyProgressTracker extends StatelessWidget {
  final SurveyStatus currentStatus;
  const SurveyProgressTracker({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    // Hanya tampilkan tracker untuk pending dan approved
    if (currentStatus == SurveyStatus.cancelled ||
        currentStatus == SurveyStatus.rejected ||
        currentStatus == SurveyStatus.unknown) {
      final isCancelled = currentStatus == SurveyStatus.cancelled;
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCancelled ? Icons.cancel_rounded : Icons.do_not_disturb_on_rounded,
              color: isCancelled ? surveyRed : const Color(0xFFBB5500),
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              isCancelled ? 'Survei Dibatalkan' : 'Survei Ditolak',
              style: TextStyle(
                color: isCancelled ? surveyRed : const Color(0xFFBB5500),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // steps: Pengajuan Dikirim → Menunggu Konfirmasi → Disetujui
    final steps = [
      'Pengajuan\nDikirim',
      'Menunggu\nKonfirmasi',
      'Disetujui\nStaf',
    ];
    final currentStep = currentStatus == SurveyStatus.approved ? 2 : 1;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      decoration: BoxDecoration(
        color: surveyCreamCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: surveyBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length, (index) {
          final isDone = index < currentStep;
          final isActive = index == currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDone
                              ? surveyGreenBg
                              : (isActive ? const Color(0xFFFCEFE0) : Colors.white),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDone
                                ? surveyGreen
                                : (isActive ? surveyBrown : const Color(0xFFDDD2C4)),
                            width: isActive ? 2.5 : 1.5,
                          ),
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(Icons.check_rounded, size: 16, color: surveyGreen)
                              : (isActive
                                  ? Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: surveyBrown,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : null),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        steps[index],
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 9.5,
                          height: 1.2,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                          color: isDone
                              ? surveyGreen
                              : (isActive ? surveyBrown : surveyLight),
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < steps.length - 1)
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 2,
                      color: index < currentStep ? surveyGreen : surveyBorder,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── STATUS BADGE ────────────────────────────────────────────────────────────
class SurveyStatusBadge extends StatelessWidget {
  final SurveyStatus status;

  const SurveyStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case SurveyStatus.pending:
        bg = const Color(0xFFFFF4D6);
        fg = const Color(0xFFB7791F);
        label = 'Menunggu';
        break;

      case SurveyStatus.approved:
        bg = surveyGreenBg;
        fg = surveyGreen;
        label = 'Disetujui';
        break;

      case SurveyStatus.completed:
        bg = const Color(0xFFE3F2FD);
        fg = const Color(0xFF1E88E5);
        label = 'Selesai';
        break;

      case SurveyStatus.rejected:
        bg = surveyRedBg;
        fg = surveyRed;
        label = 'Ditolak';
        break;

      case SurveyStatus.cancelled:
        bg = const Color(0xFFF5F5F5);
        fg = const Color(0xFF757575);
        label = 'Dibatalkan';
        break;

      default:
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade700;
        label = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ─── INFO CHIP ───────────────────────────────────────────────────────────────
class SurveyInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const SurveyInfoChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surveyCreamBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: surveyBrownDeep),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: surveyMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: surveyInk,
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

// ─── PHOTO PLACEHOLDER ───────────────────────────────────────────────────────
class SurveyPhotoPlaceholder extends StatelessWidget {
  const SurveyPhotoPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEFE4D5),
      child: const Center(
        child: Icon(
          Icons.home_outlined,
          size: 48,
          color: Color(0xFFCAB39B),
        ),
      ),
    );
  }
}