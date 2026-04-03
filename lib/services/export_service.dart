import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../models/task_model.dart';
import 'web_download_helper.dart';

class ExportService {
  Future<void> exportToPDF(List<Task> tasks, String reportTitle) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(reportTitle, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              context: context,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headers: ['Title', 'Category', 'Time', 'Date', 'Status'],
              data: tasks.map((task) => [
                task.title,
                task.category,
                '${task.time.hour}:${task.time.minute}',
                task.dueDate.toIso8601String().split('T')[0],
                task.isCompleted ? 'Completed' : 'Active'
              ]).toList(),
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();

    if (kIsWeb) {
      // Handle Web download using conditional export helper
      saveFileWeb(bytes, "timekeeper_report.pdf");
    } else {
      // Handle Mobile share/download
      final directory = await getTemporaryDirectory();
      final path = "${directory.path}/timekeeper_report.pdf";
      final file = File(path);
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(path)],
        text: 'Sharing my Task Management Report from TimeKeeper',
      );
    }
  }
}
