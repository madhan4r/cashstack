import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/extensions/date_extensions.dart';
import '../../../core/extensions/num_extensions.dart';
import '../models/reports_data.dart';
import '../models/report_filter.dart';

/// Builds and shares a CSV or PDF export of the currently loaded
/// [ReportsData]. The backend has no export endpoint, so both formats are
/// generated entirely on-device from the same data already on screen.
class ReportExportService {
  const ReportExportService();

  Future<void> exportCsv(ReportsData data, ReportFilter filter) async {
    final buffer = StringBuffer()
      ..writeln('CashStack Report')
      ..writeln('Period,${filter.fromDate.toMediumDate()} - ${filter.toDate.toMediumDate()}')
      ..writeln()
      ..writeln('Summary')
      ..writeln('Total Income,${data.summary.totalIncome.toAmount()}')
      ..writeln('Total Expense,${data.summary.totalExpense.toAmount()}')
      ..writeln('Net Savings,${data.summary.netSavings.toAmount()}')
      ..writeln('Savings Rate,${data.summary.savingsRate.toStringAsFixed(1)}%')
      ..writeln()
      ..writeln('Category Breakdown')
      ..writeln('Category,Amount,Percentage,Transactions');
    for (final item in data.categoryBreakdown) {
      buffer.writeln(
        '${_escapeCsv(item.categoryName)},${item.amount.toAmount()},'
        '${item.percentage.toStringAsFixed(1)}%,${item.transactionCount}',
      );
    }
    buffer
      ..writeln()
      ..writeln('Account Breakdown')
      ..writeln('Account,Income,Expense,Transactions');
    for (final item in data.accountBreakdown) {
      buffer.writeln(
        '${_escapeCsv(item.accountName)},${item.income.toAmount()},'
        '${item.expense.toAmount()},${item.transactionCount}',
      );
    }

    final bytes = Uint8List.fromList(buffer.toString().codeUnits);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, name: 'cashstack_report.csv', mimeType: 'text/csv')],
        subject: 'CashStack Report',
      ),
    );
  }

  Future<void> exportPdf(ReportsData data, ReportFilter filter) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, text: 'CashStack Report'),
          pw.Text(
            '${filter.fromDate.toMediumDate()} - ${filter.toDate.toMediumDate()}',
            style: const pw.TextStyle(color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 16),
          pw.Header(level: 1, text: 'Summary'),
          _summaryTable(data),
          pw.SizedBox(height: 16),
          pw.Header(level: 1, text: 'Category Breakdown'),
          _table(
            headers: const ['Category', 'Amount', '%', 'Txns'],
            rows: [
              for (final item in data.categoryBreakdown)
                [
                  item.categoryName,
                  item.amount.toAmount(),
                  '${item.percentage.toStringAsFixed(1)}%',
                  '${item.transactionCount}',
                ],
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Header(level: 1, text: 'Account Breakdown'),
          _table(
            headers: const ['Account', 'Income', 'Expense', 'Txns'],
            rows: [
              for (final item in data.accountBreakdown)
                [
                  item.accountName,
                  item.income.toAmount(),
                  item.expense.toAmount(),
                  '${item.transactionCount}',
                ],
            ],
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'cashstack_report.pdf',
      subject: 'CashStack Report',
    );
  }

  pw.Widget _summaryTable(ReportsData data) {
    return _table(
      headers: const ['Metric', 'Value'],
      rows: [
        ['Total Income', data.summary.totalIncome.toAmount()],
        ['Total Expense', data.summary.totalExpense.toAmount()],
        ['Net Savings', data.summary.netSavings.toAmount()],
        ['Savings Rate', '${data.summary.savingsRate.toStringAsFixed(1)}%'],
      ],
    );
  }

  pw.Widget _table({required List<String> headers, required List<List<String>> rows}) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellAlignment: pw.Alignment.centerLeft,
      cellStyle: const pw.TextStyle(fontSize: 10),
    );
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}

final reportExportServiceProvider = Provider<ReportExportService>((ref) {
  return const ReportExportService();
});
