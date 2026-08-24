import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../accounts/models/account.dart';
import '../../accounts/repositories/accounts_repository.dart';
import '../../budget/repositories/budget_repository.dart';
import '../../budget/repositories/category_budget_repository.dart';
import '../../categories/models/category.dart';
import '../../categories/repositories/categories_repository.dart';
import '../../recurring/models/recurring_filter.dart';
import '../../recurring/repositories/recurring_repository.dart';
import '../../savings_goals/repositories/savings_goals_repository.dart';
import '../../transactions/models/transaction.dart';
import '../../transactions/models/transaction_filter.dart';
import '../../transactions/repositories/transactions_repository.dart';

const _maxPageSize = 100;
/// Safety cap on how many pages a single export will fetch — well past any
/// realistic personal transaction history, but prevents a runaway loop if
/// the backend's pagination `meta` were ever malformed.
const _maxPages = 500;

/// Builds and shares a CSV (transactions only) or JSON (everything: all
/// accounts, categories, transactions, budgets, recurring schedules, and
/// savings goals) export of the signed-in user's data. Generated entirely
/// on-device from the same endpoints every other screen already reads —
/// there's no dedicated backend export endpoint, same approach as
/// `ReportExportService`.
class DataExportService {
  final Ref _ref;

  const DataExportService(this._ref);

  Future<void> exportTransactionsCsv() async {
    final transactionsRepo = _ref.read(transactionsRepositoryProvider);
    final accountsRepo = _ref.read(accountsRepositoryProvider);
    final categoriesRepo = _ref.read(categoriesRepositoryProvider);

    final results = await Future.wait([
      _fetchAllTransactions(transactionsRepo),
      accountsRepo.getAccounts(),
      categoriesRepo.getCategories(),
    ]);
    final transactions = results[0] as List<Transaction>;
    final accountsById = {
      for (final a in results[1] as List<Account>) a.id: a,
    };
    final categoriesById = {
      for (final c in results[2] as List<Category>) c.id: c,
    };

    final buffer = StringBuffer()
      ..writeln('Date,Type,Amount,Currency,Account,Category,Notes,Owner');
    for (final t in transactions) {
      final account = accountsById[t.accountId ?? t.fromAccountId];
      final category = t.categoryId != null ? categoriesById[t.categoryId] : null;
      buffer.writeln(
        [
          t.transactionDate.toIso8601String(),
          t.kind.toJson(),
          t.amount.toStringAsFixed(2),
          account?.currency ?? '',
          _escapeCsv(account?.name ?? ''),
          _escapeCsv(category?.name ?? ''),
          _escapeCsv(t.notes ?? ''),
          _escapeCsv(t.ownerName),
        ].join(','),
      );
    }

    final bytes = Uint8List.fromList(utf8.encode(buffer.toString()));
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(bytes, name: 'cashstack_transactions.csv', mimeType: 'text/csv'),
        ],
        subject: 'CashStack Transactions Export',
      ),
    );
  }

  Future<void> exportFullBackupJson() async {
    final transactionsRepo = _ref.read(transactionsRepositoryProvider);
    final accountsRepo = _ref.read(accountsRepositoryProvider);
    final categoriesRepo = _ref.read(categoriesRepositoryProvider);
    final budgetRepo = _ref.read(budgetRepositoryProvider);
    final categoryBudgetRepo = _ref.read(categoryBudgetRepositoryProvider);
    final recurringRepo = _ref.read(recurringRepositoryProvider);
    final savingsGoalsRepo = _ref.read(savingsGoalsRepositoryProvider);

    final results = await Future.wait([
      accountsRepo.getAccounts(),
      categoriesRepo.getCategories(),
      _fetchAllTransactions(transactionsRepo),
      budgetRepo.getBudget(),
      categoryBudgetRepo.getAll(),
      recurringRepo.getRecurring(const RecurringFilter()),
      savingsGoalsRepo.getGoals(),
    ]);

    final backup = {
      'exportedAt': DateTime.now().toIso8601String(),
      'accounts': [
        for (final a in results[0] as List<Account>)
          {
            'name': a.name,
            'type': a.type.toJson(),
            'currency': a.currency,
            'openingBalance': a.openingBalance,
            'description': a.description,
            'isArchived': a.isArchived,
          },
      ],
      'categories': [
        for (final c in results[1] as List<Category>)
          {
            'name': c.name,
            'type': c.type.toJson(),
            'icon': c.icon,
            'color': c.color,
            'description': c.description,
            'isArchived': c.isArchived,
          },
      ],
      'transactions': [
        for (final t in results[2] as List<Transaction>)
          {
            'type': t.kind.toJson(),
            'amount': t.amount,
            'accountId': t.accountId,
            'categoryId': t.categoryId,
            'fromAccountId': t.fromAccountId,
            'toAccountId': t.toAccountId,
            'notes': t.notes,
            'transactionDate': t.transactionDate.toIso8601String(),
            'tags': t.tags,
          },
      ],
      'monthlyBudget': results[3],
      'categoryBudgets': [
        for (final b in results[4] as List)
          {
            'categoryId': b.categoryId,
            'categoryName': b.categoryName,
            'amount': b.amount,
          },
      ],
      'recurringTransactions': [
        for (final r in results[5] as List)
          {
            'name': r.name,
            'type': r.type.toJson(),
            'amount': r.amount,
            'categoryId': r.categoryId,
            'accountId': r.accountId,
            'frequency': r.frequency.toJson(),
            'startDate': r.startDate.toIso8601String(),
            'endDate': r.endDate?.toIso8601String(),
            'status': r.status.toJson(),
          },
      ],
      'savingsGoals': [
        for (final g in results[6] as List)
          {
            'name': g.name,
            'targetAmount': g.targetAmount,
            'currentAmount': g.currentAmount,
            'targetDate': g.targetDate?.toIso8601String(),
          },
      ],
    };

    final bytes = Uint8List.fromList(
      utf8.encode(const JsonEncoder.withIndent('  ').convert(backup)),
    );
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(bytes, name: 'cashstack_backup.json', mimeType: 'application/json'),
        ],
        subject: 'CashStack Full Backup',
      ),
    );
  }

  Future<List<Transaction>> _fetchAllTransactions(
    TransactionsRepository repo,
  ) async {
    final all = <Transaction>[];
    var page = 1;
    while (page <= _maxPages) {
      final result = await repo.getTransactions(
        filter: const TransactionFilter(),
        page: page,
        limit: _maxPageSize,
      );
      all.addAll(result.items);
      if (!result.meta.hasNextPage) break;
      page++;
    }
    return all;
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}

final dataExportServiceProvider = Provider<DataExportService>((ref) {
  return DataExportService(ref);
});
