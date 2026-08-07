import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account.dart';
import '../repositories/accounts_repository.dart';

/// A household member's accounts — read-only peek, independent of the
/// caller's own combine/separate household view mode. Keyed by member id;
/// autoDispose since it's only ever watched by the one detail screen.
final memberAccountsProvider = FutureProvider.autoDispose
    .family<List<Account>, String>((ref, memberId) {
      return ref.watch(accountsRepositoryProvider).getAccountsForMember(memberId);
    });
