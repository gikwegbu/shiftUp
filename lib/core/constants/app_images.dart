/// Central registry for all image/animation/icon asset paths.
///
/// Usage:
///   Image.asset(AppImages.appIcon)
///   Lottie.asset(AppImages.loadingAnimation)
///
/// Add every new asset here instead of hardcoding paths in widgets.
abstract final class AppImages {
  AppImages._();

  static const String _images = 'assets/images';

  // ── App Branding ─────────────────────────────────────────────────────────

  /// Main launcher / app icon (1024 × 1024 PNG).
  static const String appIcon = '$_images/app_icon.png';

  /// Dedicated splash-screen logo (transparent-bg PNG).
  static const String splashLogo = '$_images/splash_logo.png';

  // ── Placeholders — add new assets here as the project grows ──────────────
  //
  // static const String onboardingShift   = '$_images/onboarding_shift.png';
  // static const String avatarPlaceholder = '$_images/avatar_placeholder.png';

  // SVG icons   → 'assets/icons/<name>.svg'
  // Lottie JSON → 'assets/animations/<name>.json'
}
