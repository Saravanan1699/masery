import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../my-order-list/myorderlist.dart';
import '../my-order-list/order-details.dart';
import 'pdf_generator.dart';

class Invoice extends StatelessWidget {
  final Order order;

  const Invoice({super.key, required this.order});

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      final pdfFile = await generatePdf(order);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to ${pdfFile.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    }
  }

  String _getPaymentMethod(String paymentMethodId) {
    switch (paymentMethodId) {
      case '1':
        return 'Cash on Delivery';
      case '2':
        return 'Google Payment';
      default:
        return 'Unknown Payment Method';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Invoice',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return Container(
              margin: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Color(0xffF2F2F2),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_outlined,
                  size: 15,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png',
                  height: 60,
                  width: 60,),
                  Text('Masery Shop',
                      style: GoogleFonts.montserrat(fontSize: 16,
                      fontWeight: FontWeight.bold))

                ],
              ),
              Text('Order No: ${order.orderNumber}', style: GoogleFonts.montserrat(fontSize: 18)),
              SizedBox(height: 10),
              Text('Items: ${order.itemcount}', style: GoogleFonts.montserrat(fontSize: 16)),
              SizedBox(height: 10),
              Text('Payment Method: ${_getPaymentMethod(order.paymentMethodId)}', style: GoogleFonts.montserrat(fontSize: 16)),
              SizedBox(height: 10),
              Text('Total Amount: \$${(double.tryParse(order.total) ?? 0.0).toStringAsFixed(2)}', style: GoogleFonts.montserrat(fontSize: 16)),
              SizedBox(height: 20),
              Text('Billing Address:', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text(order.billingAddress, style: GoogleFonts.montserrat(fontSize: 14)),
              SizedBox(height: 20),
              Text('Shipping Address:', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text(order.shippingAddress, style: GoogleFonts.montserrat(fontSize: 14)),
              SizedBox(height: 20),
              Text('Items Purchased:', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              if (order.inventories.isNotEmpty) ...[
                Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[100],
                      ),
                      children: [
                        TableCell(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Title', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Quantity', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Price', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
                        )),
                      ],
                    ),
                    for (var inventory in order.inventories)
                      TableRow(
                        children: [
                          TableCell(child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              inventory['title'] ?? 'No Title',
                              style: GoogleFonts.montserrat(fontSize: 14),
                            ),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${inventory['pivot']['quantity'] ?? '0'}',
                              style: GoogleFonts.montserrat(fontSize: 14),
                            ),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '\$${(double.tryParse(inventory['pivot']['unit_price'] ?? '')?.toStringAsFixed(2)) ?? '0.00'}',
                              style: GoogleFonts.montserrat(fontSize: 14),
                            ),
                          )),
                        ],
                      ),
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[200],
                      ),
                      children: [
                        TableCell(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Total',
                            style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right,
                          ),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(''),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '\$${(double.tryParse(order.total) ?? 0.0).toStringAsFixed(2)}',
                            style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        )),
                      ],
                    ),
                  ],
                ),
              ],
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => _downloadPdf(context),
                  child: Text('Download PDF', style: GoogleFonts.montserrat(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
