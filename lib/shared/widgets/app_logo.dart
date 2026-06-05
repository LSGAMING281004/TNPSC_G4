import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_assets.dart';
import '../../shared/providers/app_providers.dart';

enum LogoVariant { mark, wordmark, compact }
enum LogoTheme { dark, light, auto }

class AppLogo extends ConsumerStatefulWidget {
  final LogoVariant variant;
  final double size;
  final LogoTheme theme;
  final bool showTagline;
  final bool animate;

  const AppLogo({
    super.key,
    this.variant = LogoVariant.mark,
    this.size = 48.0,
    this.theme = LogoTheme.auto,
    this.showTagline = true,
    this.animate = false,
  });

  @override
  ConsumerState<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends ConsumerState<AppLogo> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _animationController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      )..repeat(reverse: true);
      _scaleAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
        CurvedAnimation(
          parent: _animationController!,
          curve: Curves.easeInOut,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(AppLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _animationController ??= AnimationController(
          duration: const Duration(seconds: 2),
          vsync: this,
        );
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
          CurvedAnimation(
            parent: _animationController!,
            curve: Curves.easeInOut,
          ),
        );
        _animationController!.repeat(reverse: true);
      } else {
        _animationController?.stop();
        _animationController?.dispose();
        _animationController = null;
        _scaleAnimation = null;
      }
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine the active theme mode
    final isDark = ref.watch(isDarkModeProvider);
    final useDarkAsset = widget.theme == LogoTheme.dark ||
        (widget.theme == LogoTheme.auto && isDark);

    String assetPath;
    switch (widget.variant) {
      case LogoVariant.mark:
        assetPath = useDarkAsset ? AppAssets.logoMonoDark : AppAssets.logoMonoLight;
        // If we want full color for primary logo mark, we can also use AppAssets.logoMark
        // Standard full-color mark:
        assetPath = AppAssets.logoMark;
        break;
      case LogoVariant.wordmark:
        assetPath = AppAssets.logoWordmark;
        break;
      case LogoVariant.compact:
        assetPath = AppAssets.logoMark;
        break;
    }

    Widget logoWidget;

    // Use PNG for compact sizes below 32px to ensure raster crispness
    if (widget.variant == LogoVariant.compact && widget.size < 32.0) {
      logoWidget = Image.asset(
        AppAssets.logoMarkPng,
        height: widget.size,
        width: widget.size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to SVG if PNG doesn't exist yet
          return SvgPicture.asset(
            assetPath,
            height: widget.size,
            width: widget.size,
          );
        },
      );
    } else {
      logoWidget = SvgPicture.asset(
        assetPath,
        height: widget.size,
        width: widget.variant == LogoVariant.wordmark ? widget.size * 3 : widget.size,
        fit: BoxFit.contain,
      );
    }

    if (widget.animate && _scaleAnimation != null) {
      logoWidget = ScaleTransition(
        scale: _scaleAnimation!,
        child: logoWidget,
      );
    }

    return logoWidget;
  }
}
