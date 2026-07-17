import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Decouples the network layer from the auth feature.
///
/// [RefreshTokenInterceptor] needs to announce "the session is no longer
/// valid" without depending on the auth controller directly (that would
/// create a provider cycle, since the auth controller's repository depends
/// on Dio). Instead, both sides depend on this bus.
class AuthEventBus {
  final _sessionExpiredController = StreamController<void>.broadcast();

  Stream<void> get onSessionExpired => _sessionExpiredController.stream;

  void emitSessionExpired() => _sessionExpiredController.add(null);

  void dispose() => _sessionExpiredController.close();
}

final authEventBusProvider = Provider<AuthEventBus>((ref) {
  final bus = AuthEventBus();
  ref.onDispose(bus.dispose);
  return bus;
});
