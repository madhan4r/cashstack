import 'package:equatable/equatable.dart';

/// Client-side search + archived-visibility state for the Accounts list.
/// The backend's `GET /accounts` has no query params, so filtering happens
/// entirely against the cached list — see `filteredAccountsProvider`.
class AccountsFilter extends Equatable {
  final String search;
  final bool showArchived;

  const AccountsFilter({this.search = '', this.showArchived = false});

  AccountsFilter copyWith({String? search, bool? showArchived}) {
    return AccountsFilter(
      search: search ?? this.search,
      showArchived: showArchived ?? this.showArchived,
    );
  }

  @override
  List<Object?> get props => [search, showArchived];
}
