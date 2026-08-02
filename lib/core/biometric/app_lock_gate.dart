import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'biometric_auth_service.dart';
import 'biometric_lock_controller.dart';

const _unlockReason = 'Unlock CashStack';

/// Wraps the whole app (see `app.dart`) with a biometric lock screen when
/// [biometricLockEnabledProvider] is on: locked at cold start, and
/// re-locked every time the app is backgrounded and resumed. A no-op
/// (renders [child] directly) while the setting is off.
class AppLockGate extends ConsumerStatefulWidget {
  final Widget child;

  const AppLockGate({super.key, required this.child});

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!ref.read(biometricLockEnabledProvider)) return;
    if (state == AppLifecycleState.paused) {
      ref.read(appUnlockedProvider.notifier).setUnlocked(false);
    }
  }

  Future<void> _unlock() async {
    final verified = await ref
        .read(biometricAuthServiceProvider)
        .authenticate(reason: _unlockReason);
    if (!mounted || !verified) return;
    ref.read(appUnlockedProvider.notifier).setUnlocked(true);
  }

  @override
  Widget build(BuildContext context) {
    final lockEnabled = ref.watch(biometricLockEnabledProvider);
    final isUnlocked = ref.watch(appUnlockedProvider);

    if (!lockEnabled || isUnlocked) return widget.child;

    return _LockScreen(onUnlock: _unlock);
  }
}

class _LockScreen extends StatefulWidget {
  final VoidCallback onUnlock;

  const _LockScreen({required this.onUnlock});

  @override
  State<_LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<_LockScreen> {
  @override
  void initState() {
    super.initState();
    // Prompt immediately on first show, without waiting for the user to
    // tap the button — the button is the fallback for a cancelled prompt.
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onUnlock());
  }

  @override
  Widget build(BuildContext context) {
    // This sits inside the outer MaterialApp.router's `builder` (see
    // app.dart), so Theme/Directionality/Localizations already come from
    // there — no need for (and actively wrong to nest) another MaterialApp.
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fingerprint_rounded, size: 72),
              const SizedBox(height: 24),
              Text(
                'CashStack is locked',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: widget.onUnlock,
                icon: const Icon(Icons.lock_open_rounded),
                label: const Text('Unlock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
