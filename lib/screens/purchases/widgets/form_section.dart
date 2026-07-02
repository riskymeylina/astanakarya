import 'package:flutter/material.dart';
import 'purchase_theme.dart';

class FormSection extends StatefulWidget {
  const FormSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.isCompleted = false,
    this.showDivider = true,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final bool isCompleted;
  final bool showDivider;

  @override
  State<FormSection> createState() => _FormSectionState();
}

class _FormSectionState extends State<FormSection>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: PurchaseTheme.durationLong,
      vsync: this,
    );

    _slideController = AnimationController(
      duration: PurchaseTheme.durationLong,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: double.infinity,
              decoration: PurchaseTheme.cardDecoration(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(PurchaseTheme.radiusXL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with icon and title
                    Container(
                      padding: const EdgeInsets.all(PurchaseTheme.spacing16),
                      child: Row(
                        children: [
                          // Icon background
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: PurchaseTheme.orangeBg,
                              borderRadius: BorderRadius.circular(
                                PurchaseTheme.radiusSmall,
                              ),
                            ),
                            child: Icon(
                              widget.icon,
                              color: PurchaseTheme.brown,
                              size: PurchaseTheme.iconMedium,
                            ),
                          ),
                          const SizedBox(width: PurchaseTheme.spacing12),
                          // Title and completion badge
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: PurchaseTheme.heading2,
                                ),
                              ],
                            ),
                          ),
                          // Completion indicator
                          if (widget.isCompleted)
                            Icon(
                              Icons.check_circle_rounded,
                              color: PurchaseTheme.success,
                              size: PurchaseTheme.iconStandard,
                            ),
                        ],
                      ),
                    ),
                    // Divider
                    Container(height: 1, color: PurchaseTheme.lightBorder),
                    // Content
                    Container(
                      padding: const EdgeInsets.all(PurchaseTheme.spacing16),
                      child: widget.child,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (widget.showDivider) const SizedBox(height: PurchaseTheme.spacing16),
      ],
    );
  }
}
