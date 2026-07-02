import 'package:flutter/material.dart';

const Color _kBrown = Color(0xFF8B3E0F);
const Color _kBrownLight = Color(0xFFFFF0E6);
const Color _kBeige = Color(0xFFF5EDE0);

class AuthPageScaffold extends StatelessWidget {
  const AuthPageScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.headerImagePath,
    this.illustrationWidget,
    this.footer,
    this.showBackButton = false,
    this.onBack,
    this.topImageFraction = 0.38,
    this.panelTopFraction = 0.34,
    this.panelRadius = 28.0,
    this.header,
    this.titleAlignment = CrossAxisAlignment.start,
    this.titleTextAlign,
    this.overlayButtonColor,
    this.backgroundColor,
  });

  final String? headerImagePath;
  final Widget? illustrationWidget;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;
  final bool showBackButton;
  final VoidCallback? onBack;
  final double topImageFraction;
  final double panelTopFraction;
  final double panelRadius;
  final Widget? header;
  final CrossAxisAlignment titleAlignment;
  final TextAlign? titleTextAlign;
  final Color? overlayButtonColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final bool hasImage = headerImagePath != null;
    final bool hasIllustration = illustrationWidget != null;
    final Color bgColor = backgroundColor ?? _kBeige;

    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: const Color(0xFF1A1A1A),
      fontSize: 26,
      height: 1.2,
    );
    final subtitleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: const Color(0xFF7A7A7A),
      fontSize: 14,
      height: 1.5,
    );

    Widget topSection;
    double panelOffset;

    if (hasImage) {
      final imgH = height * topImageFraction;
      final imgFrac = panelTopFraction;
      panelOffset = height * imgFrac;

      topSection = SizedBox(
        height: imgH,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              headerImagePath!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5A2A0D), Color(0xFF8B3E0F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (hasIllustration) {
      final illustH = height * 0.30;
      panelOffset = illustH - 24;

      topSection = Container(
        height: illustH,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_kBeige, _kBrownLight],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: showBackButton ? 24.0 : 0),
              Expanded(child: Center(child: illustrationWidget!)),
            ],
          ),
        ),
      );
    } else {
      panelOffset = 0;
      topSection = const SizedBox.shrink();
    }

    Widget panelContent = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(panelRadius)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (header != null) ...[
            header!,
            const SizedBox(height: 20),
          ],
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: titleAlignment,
              children: [
                Text(
                  title,
                  textAlign: titleTextAlign,
                  style: titleStyle,
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: titleTextAlign,
                  style: subtitleStyle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          child,
          if (footer != null) ...[
            const SizedBox(height: 16),
            footer!,
          ],
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background colour behind the scroll area
          Positioned.fill(child: Container(color: bgColor)),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  topSection,
                  panelContent,
                ],
              ),
            ),
          ),
          // Back button overlay
          if (showBackButton)
            Positioned(
              top: 8,
              left: 8,
              child: SafeArea(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: onBack ?? () => Navigator.maybePop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (overlayButtonColor ?? Colors.white)
                            .withOpacity(0.92),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: overlayButtonColor == null
                            ? const Color(0xFF1A1A1A)
                            : Colors.white,
                      ),
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
