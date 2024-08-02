import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../Settings/My_Profile.dart';
import '../bottombar/bottombar.dart';
import 'order-details.dart';

// Model class representing an Order
class Order {
  final String orderId;
  final String orderNumber;
  final String quantity;
  final String total;
  final String itemcount;
  final String billingAddress;
  final String shippingAddress;
  final String paymentMethodId;
  final List<dynamic> inventories;
  final String createdAt;
  final String orderStatusId;

  Order({
    required this.orderId,
    required this.orderNumber,
    required this.quantity,
    required this.total,
    required this.itemcount,
    required this.billingAddress,
    required this.shippingAddress,
    required this.paymentMethodId,
    required this.inventories,
    required this.createdAt,
    required this.orderStatusId,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['id'].toString(),
      orderNumber: json['order_number'],
      quantity: json['quantity'] ?? '0',
      total: json['total'] ?? '0.00',
      itemcount: json['item_count'] ?? '0.00',
      billingAddress: json['billing_address'] ?? '',
      shippingAddress: json['shipping_address'] ?? '',
      paymentMethodId: json['payment_method_id'] ?? '',
      inventories: json['inventories'] ?? [],
      createdAt: json['created_at'].toString(),
      orderStatusId: json['order_status_id'] ?? '',
    );
  }
}

// Stateful widget displaying the list of orders
class Orderlist extends StatefulWidget {
  const Orderlist({super.key});

  @override
  State<Orderlist> createState() => _OrderlistState();
}

class _OrderlistState extends State<Orderlist> {
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = fetchOrders();
  }

  Future<String?> _getIdFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('id');
  }

  Future<String?> _getTokenFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<Order>> fetchOrders() async {
    final id = await _getIdFromLocalStorage();
    if (id == null) {
      throw Exception('User ID not found in local storage');
    }

    final token = await _getTokenFromLocalStorage();
    final response = await http.get(
      Uri.parse(
          'https://sgitjobs.com/MaseryShoppingNew/public/api/orders/customer/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> ordersList = data['data'] ?? [];
      return ordersList.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders');
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

  String _getOrderStatus(String orderStatusId) {
    switch (orderStatusId) {
      case '1':
        return 'Confirmed';
      case '2':
        return 'Processing';
      case '3':
        return 'Rejected';
      default:
        return 'Unknown Status';
    }
  }

  Color _getStatusColor(String orderStatusId) {
    switch (orderStatusId) {
      case '1':
        return Colors.green;
      case '2':
        return Colors.yellow;
      case '3':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateTime) {
    DateTime date = DateTime.parse(dateTime);
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Order History',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Profile()));
                },
              ),
            );
          },
        ),
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.halfTriangleDot(
                size: 50.0,
                color: Colors.redAccent,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Orders Found'));
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final paymentMethod = _getPaymentMethod(order.paymentMethodId);
                final orderStatus = _getOrderStatus(order.orderStatusId);
                final statusColor = _getStatusColor(order.orderStatusId);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetails(order: order),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Order Id -',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    ' ${order.orderNumber}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                ' ${_formatDate(order.createdAt)}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Quantity: ${order.itemcount}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Total:',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  Text(
                                    ' \$${(double.tryParse(order.total)?.toStringAsFixed(2) ?? '0.00')}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                'Order Status: ',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(
                                height: 15,
                                child: CircleAvatar(
                                  radius: 10,
                                  backgroundColor: statusColor,
                                ),
                              ),
                              Text(
                                ' $orderStatus',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomBar(
        onTap: (index) {},
      ),
    );
  }
}
