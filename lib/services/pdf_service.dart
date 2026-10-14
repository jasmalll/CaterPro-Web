import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/catering_models.dart';

class PdfService {
  // 1. MONTHLY FINANCE & WORK REPORT GENERATOR
  static Future<void> exportMonthlyReport({
    required String monthLabel,
    required double totalIncome,
    required double totalExpenses,
    required double netSavings,
    required List<WorkItem> works,
    required List<ExpenseItem> expenses,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return [
            // Header Section
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'CaterPro',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey900,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Catering Work & Monthly Finance Report',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Text(
                    monthLabel,
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
                  ),
                ),
              ],
            ),
            pw.Divider(thickness: 1, color: PdfColors.grey300, height: 20),

            // Financial Summary Cards
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem('Total Income', 'Rs ${totalIncome.toStringAsFixed(0)}', PdfColors.green800),
                  _buildSummaryItem('Total Expenses', 'Rs ${totalExpenses.toStringAsFixed(0)}', PdfColors.red800),
                  _buildSummaryItem('Net Savings', 'Rs ${netSavings.toStringAsFixed(0)}', PdfColors.blue800),
                  _buildSummaryItem('Total Works', '${works.length}', PdfColors.black),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Catering Works Table
            pw.Text(
              'Catering Works List ($monthLabel)',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
            ),
            pw.SizedBox(height: 8),
            if (works.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 10),
                child: pw.Text(
                  'No works recorded for this month.',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              )
            else
              pw.TableHelper.fromTextArray(
                headers: ['#', 'Date', 'Venue & Location', 'Type', 'Amount', 'Status'],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
                data: works.map((w) => [
                  w.number,
                  w.dateText,
                  '${w.venue} (${w.location})',
                  w.eventType,
                  'Rs ${w.amount.toStringAsFixed(0)}',
                  w.status,
                ]).toList(),
              ),
            pw.SizedBox(height: 22),

            // Monthly Expenses Table
            pw.Text(
              'Monthly Expenses List ($monthLabel)',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
            ),
            pw.SizedBox(height: 8),
            if (expenses.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 10),
                child: pw.Text(
                  'No expenses recorded for this month.',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              )
            else
              pw.TableHelper.fromTextArray(
                headers: ['#', 'Date', 'Description / Shop', 'Category', 'Amount'],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
                data: expenses.map((e) => [
                  e.number,
                  e.dateText,
                  '${e.title} (${e.subNote})',
                  e.category,
                  'Rs ${e.amount.toStringAsFixed(0)}',
                ]).toList(),
              ),

            pw.SizedBox(height: 25),
            pw.Divider(thickness: 0.5, color: PdfColors.grey300),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Generated via CaterPro App',
                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
              ),
            ),
          ];
        },
      ),
    );

    final Uint8List bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'CaterPro_${monthLabel.replaceAll(" ", "_")}_Report.pdf',
    );
  }

  // 2. SINGLE WORK RECEIPT / INVOICE GENERATOR (For individual work sharing)
  static Future<void> exportWorkInvoice(WorkItem work) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'CaterPro Catering Invoice',
                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text('Booking Confirmation & Bill', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Text('Work #${work.number}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Divider(thickness: 1, color: PdfColors.grey300, height: 24),
              pw.SizedBox(height: 10),

              pw.Text('Event Details', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              _buildInvoiceRow('Venue / Auditorium:', work.venue),
              _buildInvoiceRow('Location:', work.location),
              _buildInvoiceRow('Event Date:', work.dateText),
              _buildInvoiceRow('Reporting Time:', work.reportingTime),
              _buildInvoiceRow('Event Type:', work.eventType),
              _buildInvoiceRow('Plates / Pax:', work.paxCount),
              if (work.note.isNotEmpty) _buildInvoiceRow('Note / Contact:', work.note),

              pw.SizedBox(height: 20),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 10),

              pw.Text('Payment Summary', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              _buildInvoiceRow('Total Amount:', 'Rs ${work.amount.toStringAsFixed(0)}'),
              _buildInvoiceRow('Advance Received:', 'Rs ${(work.amount - work.balance).toStringAsFixed(0)}'),
              _buildInvoiceRow('Balance Pending:', 'Rs ${work.balance.toStringAsFixed(0)}'),
              _buildInvoiceRow('Payment Status:', work.status),
            ],
          );
        },
      ),
    );

    final Uint8List bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Work_${work.number}_${work.venue.replaceAll(" ", "_")}.pdf',
    );
  }

  static pw.Widget _buildSummaryItem(String title, String val, PdfColor valColor) {
    return pw.Column(
      children: [
        pw.Text(title, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(val, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: valColor)),
      ],
    );
  }

  static pw.Widget _buildInvoiceRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}