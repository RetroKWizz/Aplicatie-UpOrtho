import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../api/models/profile.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';

/// Cardul de membru Ortho Club din "Contul meu".
///
/// Datele vin intregi de la server (`/account/profile`, blocul `club`) si sunt doar
/// de citit: abonamentul se cumpara si se reinnoieste pe site. Starea `member` o
/// decide tot serverul - bifa din Odoo nu se stinge cand trece data, deci aplicatia
/// nu o interpreteaza singura si nu compara ea datele.
class OrthoClubCard extends StatelessWidget {
  const OrthoClubCard({super.key, required this.club});

  final OrthoClub club;

  @override
  Widget build(BuildContext context) =>
      club.member ? _ActiveCard(club: club) : _ExpiredCard(club: club);
}

/// Abonament valabil: card plin, cu data de expirare mare si lista de preturi.
class _ActiveCard extends StatelessWidget {
  const _ActiveCard({required this.club});

  final OrthoClub club;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF55306F),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _ClubMark(size: 26),
              const SizedBox(width: 10),
              const Text(
                'ORTHO CLUB',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF7BE0A0),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Activ',
                  style: TextStyle(
                    color: Color(0xFF55306F),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Un abonament bifat in Odoo fara data de sfarsit ramane valabil, dar n-are
          // ce termen sa afiseze - atunci cardul spune doar ca e activ.
          if (club.endDateLabel case final String label) ...[
            const Text('Membru pana la',
                style: TextStyle(color: Color(0xFFDCCCEA), fontSize: 13)),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
          ] else
            const Text(
              'Membru activ',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
            ),
          if (club.pricelist case final String pricelist) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFF70508A)),
            const SizedBox(height: 12),
            const Text('Lista ta de preturi',
                style: TextStyle(color: Color(0xFFDCCCEA), fontSize: 12)),
            const SizedBox(height: 2),
            Text(
              pricelist,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

/// Abonament expirat (sau bifa scoasa, cu data ramasa): acelasi card, stins, cu
/// motivul scris pe el. Clientul vede astfel de ce preturile nu mai sunt cele de club.
class _ExpiredCard extends StatelessWidget {
  const _ExpiredCard({required this.club});

  final OrthoClub club;

  @override
  Widget build(BuildContext context) {
    final label = club.endDateLabel;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7E1EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _ClubMark(size: 26, muted: true),
              const SizedBox(width: 10),
              const Text(
                'ORTHO CLUB',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBE3DC),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Expirat',
                  style:
                      TextStyle(color: Color(0xFF8A2C1B), fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label == null
                ? 'Abonamentul tau Ortho Club nu mai este valabil.'
                : 'Abonamentul tau Ortho Club a expirat la $label.',
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pana la reinnoire vezi preturile publice, nu pe cele de club.',
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}

/// Sigla Ortho Club: cercul impartit in sferturi, in culorile ei.
class _ClubMark extends StatelessWidget {
  const _ClubMark({required this.size, this.muted = false});

  final double size;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ClubMarkPainter(muted: muted)),
    );
  }
}

class _ClubMarkPainter extends CustomPainter {
  const _ClubMarkPainter({required this.muted});

  final bool muted;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final paint = Paint()..style = PaintingStyle.fill;

    void quarter(double startDegrees, Color color) {
      paint.color = color;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(rect, startDegrees * math.pi / 180, math.pi / 2, false)
        ..close();
      canvas.drawPath(path, paint);
    }

    quarter(180, muted ? const Color(0xFF9A9AA2) : const Color(0xFFB079D6));
    quarter(270, muted ? const Color(0xFFB9B9C0) : const Color(0xFFF02A79));
    quarter(90, muted ? const Color(0xFFD2D2D8) : const Color(0xFF45C2D6));
  }

  @override
  bool shouldRepaint(_ClubMarkPainter oldDelegate) => oldDelegate.muted != muted;
}
