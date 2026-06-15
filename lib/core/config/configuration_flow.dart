import '../../presentation/providers/vfd_provider.dart';

/// Six-step VFD setup flow shown on the home screen.
class ConfigurationFlow {
  ConfigurationFlow._();

  static const int totalSteps = 6;

  /// Steps completed (0–6).
  static int completedSteps(VfdProvider provider) {
    if (provider.selectedVendor == null) return 0;
    if (provider.selectedModelName == null) return 1;
    if (provider.selectedPowerRating == null) return 2;
    if (provider.selectedVoltage == null) return 3;
    if (!_connectionStepComplete(provider)) return 4;
    if (!_parametersStepUnlocked(provider)) return 5;
    return 6;
  }

  /// Next step the user should work on (1–6), or 6 when done.
  static int activeStep(VfdProvider provider) {
    final done = completedSteps(provider);
    return done >= totalSteps ? totalSteps : done + 1;
  }

  static double progress(VfdProvider provider) =>
      completedSteps(provider) / totalSteps;

  static bool _connectionStepComplete(VfdProvider provider) {
    if (provider.selectedVoltage == null) return false;
    if (provider.connectionType == ConnectionType.hardWire) return true;
    final protocol = provider.selectedProtocol;
    if (protocol == null) return false;
    if (protocol.type == 'Direct') return true;
    return provider.selectedCommCard != null;
  }

  static bool _parametersStepUnlocked(VfdProvider provider) {
    if (provider.selectedVoltage == null) return false;
    if (provider.connectionType == ConnectionType.hardWire) return true;
    final protocol = provider.selectedProtocol;
    if (protocol == null) return false;
    return protocol.type == 'Direct' || provider.selectedCommCard != null;
  }

  static bool isStepComplete(VfdProvider provider, int step) {
    return completedSteps(provider) >= step;
  }

  static bool isStepActive(VfdProvider provider, int step) {
    return activeStep(provider) == step;
  }
}
