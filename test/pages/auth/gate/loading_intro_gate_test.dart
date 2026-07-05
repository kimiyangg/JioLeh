import "package:flutter_test/flutter_test.dart";
import "package:jio_leh/pages/auth/gate/auth_gate_model.dart";
import "package:jio_leh/pages/auth/gate/loading_intro_gate.dart";

void main() {
  test('holds the screen on loading when animation is not complete', () {
    final gate = LoadingIntroGate();

    expect(gate.resolve(AuthGateScreen.map), AuthGateScreen.loading);
  });

  test('switches to target screen when loading is complete', () {
    final gate = LoadingIntroGate();
    gate.completed();

    // Checks all 4 screens, not just one — proves resolve() never special-cases a particular screen,
    // a guarantee only visible if more than one value is tested.
    expect(gate.resolve(AuthGateScreen.map), AuthGateScreen.map);
    expect(gate.resolve(AuthGateScreen.login), AuthGateScreen.login);
    expect(gate.resolve(AuthGateScreen.onboarding), AuthGateScreen.onboarding);
    expect(gate.resolve(AuthGateScreen.error), AuthGateScreen.error);
  });

  test('holds the screen on loading again after reset', () {
    final gate = LoadingIntroGate();
    gate.completed();

    expect(gate.resolve(AuthGateScreen.map), AuthGateScreen.map);

    gate.reset();

    expect(gate.resolve(AuthGateScreen.map), AuthGateScreen.loading);
  });

  test('returns loading when the screen is on loading', () {
    final gate = LoadingIntroGate();
    expect(gate.resolve(AuthGateScreen.loading), AuthGateScreen.loading);
  });
}