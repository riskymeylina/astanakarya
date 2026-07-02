// lib/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox(
            height: height * 0.67,
            width: double.infinity,
            child: Image.asset(
              'assets/images/on boarding.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Image.asset('assets/images/2.jpg', fit: BoxFit.cover),
            ),
          ),

          Container(
            height: height * 0.67,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.45),
                ],
              ),
            ),
          ),

          // Panel bawah melengkung
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: _TopCurveClipper(),
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(minHeight: height * 0.40),
                padding: EdgeInsets.fromLTRB(
                  24,
                  52,
                  24,
                  MediaQuery.of(context).padding.bottom + 16,
                ),
                decoration: const BoxDecoration(color: Colors.white),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'SELAMAT DATANG',
                        style: TextStyle(
                          fontFamily: 'TomatoGrotesk',
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF3B3B3B),
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Temukan ruang nyaman untuk hidup dan berkembang.\nWujudkan properti impian Anda bersama kami.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'TomatoGrotesk',
                          fontSize: 16,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(
                            context,
                          ).pushReplacementNamed('/login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 20),
                              const Expanded(
                                child: Center(
                                  child: Text(
                                    'Mulai Membangun',
                                    style: TextStyle(
                                      fontFamily: 'TomatoGrotesk',
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 34,
                                height: 34,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFDD096),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 40);
    path.quadraticBezierTo(size.width * 0.5, -20, size.width, 40);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
