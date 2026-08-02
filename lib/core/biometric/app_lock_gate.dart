import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'biometric_auth_service.dart';
import 'biometric_lock_controller.dart';

const _unlockReason = 'Unlock CashStack';

/// Re-locking on *every* background/foreground flip is what made this
/// annoying — switching to a keyboard/autofill prompt, copying an OTP, or
/// glancing at a notification all momentarily background the app too.
/// Only re-lock if it was actually backgrounded for longer than this.
const _reLockGracePeriod = Duration(seconds: 30);

/// Wraps the whole app (see `app.dart`) with a biometric lock screen when
/// [biometricLockEnabledProvider] is on: locked at cold start, and
/// re-locked after the app has been backgrounded for longer than
/// [_reLockGracePeriod]. A no-op (renders [child] directly, unmodified)
/// while the setting is off.
///
/// The lock screen is layered *on top of* [child] rather than replacing
/// it — [child] must stay mounted the whole time. Swapping it out (as an
/// earlier version of this widget did) tears down GoRouter's entire
/// Navigator and every screen's state along with it, so unlocking would
/// come back to a blank slate — any form the user was mid-typing into
/// would lose everything.
class AppLockGate extends ConsumerStatefulWidget {
  final Widget child;

  const AppLockGate({super.key, required this.child});

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> with WidgetsBindingObserver {
  DateTime? _pausedAt;

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
      _pausedAt = DateTime.now();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      final pausedAt = _pausedAt;
      _pausedAt = null;
      if (pausedAt != null && DateTime.now().difference(pausedAt) >= _reLockGracePeriod) {
        ref.read(appUnlockedProvider.notifier).setUnlocked(false);
      }
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
    final isLocked = lockEnabled && !isUnlocked;

    return Stack(
      children: [
        widget.child,
        if (isLocked) Positioned.fill(child: _LockScreen(onUnlock: _unlock)),
      ],
    );
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
