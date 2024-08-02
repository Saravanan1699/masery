import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

import '../my-order-list/myorderlist.dart';

Future<File> generatePdf(Order order) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Order No: ${order.orderNumber}', style: pw.TextStyle(fontSize: 18)),
          pw.SizedBox(height: 10),
          pw.Text('Items: ${order.itemcount}', style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 10),
          pw.Text('Total Amount: \$${(double.tryParse(order.total) ?? 0.0).toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.topRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Billing Address:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text(order.billingAddress, style: pw.TextStyle(fontSize: 14)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.topRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Shipping Address:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text(order.shippingAddress, style: pw.TextStyle(fontSize: 14)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Items Purchased:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          if (order.inventories.isNotEmpty) ...[
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blueGrey100,
                  ),
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text('Title', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text('Quantity', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text('Price', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                for (var inventory in order.inventories) pw.TableRow(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        inventory['title'] ?? 'No Title',
                        style: pw.TextStyle(fontSize: 14),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        '${inventory['pivot']['quantity'] ?? '0'}',
                        style: pw.TextStyle(fontSize: 14),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        '\$${(double.tryParse(inventory['pivot']['unit_price'] ?? '')?.toStringAsFixed(2)) ?? '0.00'}',
                        style: pw.TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blueGrey200,
                  ),
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        'Total',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(''),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        '\$${(double.tryParse(order.total) ?? 0.0).toStringAsFixed(2)}',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    ),
  );

  final outputFile = await _getOutputFile();
  await outputFile.writeAsBytes(await pdf.save());
  return outputFile;
}

Future<File> _getOutputFile() async {
  final directory = await getExternalStorageDirectory();
  final path = '${directory!.path}/invoice_${DateTime.now().toString()}.pdf';
  return File(path);
}
