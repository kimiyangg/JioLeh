import 'package:jio_leh/pages/auth/gate/auth_gate_model.dart';

class LoadingIntroGate{
  bool _completedAnimation = false;

  void reset() => _completedAnimation = false;

  void completed() => _completedAnimation = true;

  AuthGateScreen resolve(AuthGateScreen screen) {
    if (screen == AuthGateScreen.loading) {
      return screen;
    } else if (_completedAnimation) {
      return screen;
    } else {
      return AuthGateScreen.loading;
    }
  }
}