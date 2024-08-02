import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bottombar/bottombar.dart';
import '../invoice/invoice.dart';
import 'myorderlist.dart';

class OrderDetails extends StatelessWidget {
  final Order order;

  const OrderDetails({super.key, required this.order});

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
          'Order Details',
          style: GoogleFonts.montserrat(),
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Orderlist()));
                },
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order No ${order.orderNumber}',
                    style: GoogleFonts.montserrat(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Row(
                children: [
                  Text(
                    '${order.itemcount} items',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            if (order.inventories.isNotEmpty) ...[
              for (var inventory in order.inventories)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Container(
                            constraints: BoxConstraints(maxWidth: 150),
                            child: Image.network(
                              'https://sgitjobs.com/MaseryShoppingNew/public/${inventory['product']['images'][0]['path']}',
                              height: 100,
                              width: 150,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.network(
                                  'https://example.com/placeholder.png',
                                  height: 100,
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  inventory['title'] ?? '--',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Quantity:',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      '${(inventory['pivot']['quantity'] ?? '') ?? '0.00'}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Price:',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      '\$${(double.tryParse(inventory['pivot']['unit_price'] ?? '')?.toStringAsFixed(2)) ?? '0.00'}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Text(
                'Order Information',
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 15),
            _buildOrderInfo('Billing Address:', order.billingAddress),
            _buildOrderInfo('Shipping Address:', order.shippingAddress),
            _buildOrderInfo(
                'Payment Method:', _getPaymentMethod(order.paymentMethodId)),
            _buildOrderInfo('Total Amount:', '\$${(double.tryParse(order.total) ?? 0.0).toStringAsFixed(2)}'),
            SizedBox(height: 15),
            Center(
                child: ElevatedButton(
                  onPressed: () {
                    print(order.toString()); // Print the order data to the console
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Invoice(order: order), // Pass the order object here
                      ),
                    );
                  },
                  child: Text(
                    'View Invoice',
                    style: GoogleFonts.montserrat(
                      color: Color(0xff0D6EFD),
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Color(0xff0D6EFD)),
                    ),
                  ),
                )
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(
        onTap: (index) {},
      ),
    );
  }

  Widget _buildOrderInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[400]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
