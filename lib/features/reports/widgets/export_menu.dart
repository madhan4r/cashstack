import 'package:flutter/material.dart';

/// AppBar action offering "Export as PDF" / "Export as CSV". Kept as a
/// plain `PopupMenuButton` (not a custom sheet) since it's just two
/// actions — matches how other AppBar overflow menus already behave in
/// Material apps without inventing new chrome.
class ExportMenu extends StatelessWidget {
  final VoidCallback onExportPdf;
  final VoidCallback onExportCsv;
  final bool isExporting;

  const ExportMenu({
    super.key,
    required this.onExportPdf,
    required this.onExportCsv,
    this.isExporting = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isExporting) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return PopupMenuButton<void>(
      icon: const Icon(Icons.ios_share_rounded),
      tooltip: 'Export',
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: onExportPdf,
          child: const Row(
            children: [
              Icon(Icons.picture_as_pdf_outlined, size: 20),
              SizedBox(width: 12),
              Text('Export as PDF'),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: onExportCsv,
          child: const Row(
            children: [
              Icon(Icons.table_chart_outlined, size: 20),
              SizedBox(width: 12),
              Text('Export as CSV'),
            ],
          ),
        ),
      ],
    );
  }
}
