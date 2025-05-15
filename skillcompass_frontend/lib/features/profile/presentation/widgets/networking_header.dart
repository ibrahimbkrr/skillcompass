import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NetworkingHeader extends StatelessWidget {
  final Color mainBlue;
  final Color gold;
  final Color cloudGrey;
  final VoidCallback? onGuide;
  const NetworkingHeader({
    super.key,
    required this.mainBlue,
    required this.gold,
    required this.cloudGrey,
    this.onGuide,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: 'Networking icon',
              container: true,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [mainBlue, gold],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.handshake, color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    label: 'Networking title',
                    child: Text(
                      'Ağınızı Güçlendirin',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: mainBlue,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Semantics(
                    label: 'Networking description',
                    child: Text(
                      'Bilişim dünyasında kiminle bağlantı kuruyorsunuz? Mentorluk ve networking hedeflerinizi paylaşın, profesyonel yolculuğunuzu zenginleştirin.',
                      style: GoogleFonts.inter(fontSize: 16, color: cloudGrey),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (onGuide != null)
              Semantics(
                label: 'Guide',
                button: true,
                child: IconButton(
                  icon: Icon(Icons.explore, color: gold, size: 28),
                  onPressed: onGuide,
                  tooltip: 'Guide',
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Semantics(
          label: 'Networking motivational',
          child: Text(
            'Doğru bağlantılarla kariyerinizi bir üst seviyeye taşıyın!',
            style: GoogleFonts.inter(fontSize: 15, color: mainBlue, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
} 