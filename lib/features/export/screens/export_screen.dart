import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/cards/app_list_tile.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../services/snackbar_service.dart';
import '../services/data_export_service.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool _isExportingCsv = false;
  bool _isExportingJson = false;

  Future<void> _exportCsv() async {
    setState(() => _isExportingCsv = true);
    try {
      await ref.read(dataExportServiceProvider).exportTransactionsCsv();
    } catch (_) {
      if (mounted) {
        ref
            .read(snackbarServiceProvider)
            .showError("Couldn't export transactions — try again");
      }
    } finally {
      if (mounted) setState(() => _isExportingCsv = false);
    }
  }

  Future<void> _exportJson() async {
    setState(() => _isExportingJson = true);
    try {
      await ref.read(dataExportServiceProvider).exportFullBackupJson();
    } catch (_) {
      if (mounted) {
        ref.read(snackbarServiceProvider).showError("Couldn't create backup — try again");
      }
    } finally {
      if (mounted) setState(() => _isExportingJson = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CashStackAppBar(title: 'Export & Backup'),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          AppListTile(
            leading: const Icon(Icons.table_chart_outlined),
            title: 'Export Transactions (CSV)',
            subtitle: 'Your full transaction history, spreadsheet-friendly',
            trailing: _isExportingCsv
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right_rounded),
            onTap: _isExportingCsv ? null : _exportCsv,
          ),
          AppListTile(
            leading: const Icon(Icons.backup_outlined),
            title: 'Full Backup (JSON)',
            subtitle: 'Accounts, categories, budgets, recurring, and savings goals',
            trailing: _isExportingJson
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right_rounded),
            onTap: _isExportingJson ? null : _exportJson,
          ),
        ],
      ),
    );
  }
}
