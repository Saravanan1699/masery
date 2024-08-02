import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../Authentication/Sing-in.dart';  // Make sure this import path is correct
import '../Base_Url/BaseUrl.dart';
import '../Multiple_stepform/step_form.dart';
import '../Responsive/responsive.dart';
import 'home.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> carts = [];
  bool isLoading = true;
  double totalItems = 0;

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}carts'));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          if (data.isNotEmpty) {
            setState(() {
              carts = data.map((cart) {
                cart['inventories'] = cart['inventories'].map((inventory) {
                  inventory['quantity'] = inventory['quantity'] ?? 1;
                  return inventory;
                }).toList();
                return cart;
              }).toList();
            });
          }
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateCartItemQuantity(BuildContext context, int cartId, int itemId, int newQuantity) async {
    final String url = '${ApiConfig.baseUrl}cart/$cartId/update?item=$itemId&quantity=$newQuantity';

    try {
      final response = await http.put(Uri.parse(url));

      if (response.statusCode == 200) {
        await fetchData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Item quantity updated successfully',
              style: GoogleFonts.montserrat(),
            ),
          ),
        );
      } else {
        print('Failed to update item quantity: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update item quantity: ${response.statusCode}',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error occurred: $e',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> removeItemFromCart(int cartId, int itemId) async {
    final String url = '${ApiConfig.baseUrl}cart/removeItem?cart=$cartId&item=$itemId';
    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Item removed successfully');
        await fetchData();
        setState(() {
          carts.forEach((cart) {
            cart['inventories'].removeWhere((inventory) => inventory['id'] == itemId);
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Item removed successfully',
              style: GoogleFonts.montserrat(),
            ),
          ),
        );
      } else {
        print('Failed to remove item: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to remove item: ${response.statusCode}',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error occurred: $e',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return token != null;
  }

  Future<void> loginUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
  }

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('isLoggedIn');
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'My Cart',
          style: GoogleFonts.montserrat(fontSize: responsive.textSize(3.5)),
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                },
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          isLoading
              ? Center(
            child: Container(
              child: LoadingAnimationWidget.halfTriangleDot(
                size: responsive.widthPercentage(15),
                color: Colors.redAccent,
              ),
            ),
          )
              : carts.isEmpty
              ? Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Image(
                        image: AssetImage(
                          'assets/emptycart-masery.png',
                        ),
                        height: responsive.heightPercentage(30),
                        width: responsive.widthPercentage(50),
                      ),
                      SizedBox(
                        height: responsive.heightPercentage(2),
                      ),
                      Text(
                        'Your cart is empty',
                        style: GoogleFonts.montserrat(
                            fontSize: responsive.textSize(2.2), fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: responsive.heightPercentage(2),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => HomePage()));
                        },
                        child: Text('Start shopping',
                            style: GoogleFonts.montserrat(
                                color: Colors.white, fontSize: responsive.textSize(2.2))),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff0D6EFD),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(responsive.widthPercentage(3)),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ))
              : ListView.builder(
            itemCount: carts.length,
            itemBuilder: (BuildContext context, int index) {
              final cart = carts[index];
              final List<dynamic> inventories = cart['inventories'];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: inventories.map((inventory) {
                  String imageUrl = inventory['product']['images'].isNotEmpty
                      ? 'https://sgitjobs.com/MaseryShoppingNew/public/${inventory['product']['images'][0]['path']}'
                      : 'assets/products/images/default_image.png';
                  double minPrice = double.tryParse(inventory['product']['min_price']) ?? 0.0;
                  double unitPrice = double.tryParse(inventory['pivot']['unit_price']) ?? 0.0;
                  int quantity = int.tryParse(inventory['pivot']['quantity'].toString()) ?? 0;
                  int itemId = int.tryParse(inventory['pivot']['inventory_id'].toString()) ?? 0;

                  double totalPrice = unitPrice * quantity.toDouble();

                  return Center(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(responsive.widthPercentage(3)),
                      ),
                      color: Colors.white,
                      child: Container(
                        width: responsive.widthPercentage(90),
                        margin: EdgeInsets.symmetric(
                            vertical: responsive.heightPercentage(2),
                            horizontal: responsive.widthPercentage(2)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: responsive.widthPercentage(40),
                                  height: responsive.heightPercentage(20),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        responsive.widthPercentage(3)),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                SizedBox(width: responsive.widthPercentage(4)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        inventory['product']['name'] ?? 'Unknown',
                                        style: GoogleFonts.montserrat(
                                            fontSize: responsive.textSize(2.2),
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Price: \$${minPrice.toStringAsFixed(2)}',
                                        style: GoogleFonts.montserrat(
                                            fontSize: responsive.textSize(2)),
                                      ),
                                      Text(
                                        'Total Price: \$${totalPrice.toStringAsFixed(2)}',
                                        style: GoogleFonts.montserrat(
                                            fontSize: responsive.textSize(2)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: responsive.heightPercentage(2),
                                  horizontal: responsive.widthPercentage(2)),
                              child: Row(
                                children: [
                                  Text(
                                    'Quantity:',
                                    style: GoogleFonts.montserrat(
                                        fontSize: responsive.textSize(2)),
                                  ),
                                  SizedBox(width: responsive.widthPercentage(2)),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          if (quantity > 1) {
                                            setState(() {
                                              quantity--;
                                              updateCartItemQuantity(context, cart['id'],
                                                  itemId, quantity);
                                            });
                                          }
                                        },
                                        icon: Icon(Icons.remove),
                                        iconSize: responsive.textSize(2.2),
                                      ),
                                      Text(
                                        quantity.toString(),
                                        style: GoogleFonts.montserrat(
                                            fontSize: responsive.textSize(2.2),
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            quantity++;
                                            updateCartItemQuantity(context, cart['id'],
                                                itemId, quantity);
                                          });
                                        },
                                        icon: Icon(Icons.add),
                                        iconSize: responsive.textSize(2.2),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      removeItemFromCart(cart['id'], itemId);
                                    },
                                    icon: Icon(Icons.delete_outline),
                                    color:Colors.orangeAccent,
                                    iconSize: responsive.textSize(3.2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: carts.isNotEmpty
          ? Padding(
        padding: EdgeInsets.all(responsive.widthPercentage(2)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                Text(
                  'Grand Total:',
                  style: GoogleFonts.montserrat(
                    fontSize: responsive.textSize(2.2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: responsive.widthPercentage(2)),
                Text(
                  '\$${calculateGrandTotal().toStringAsFixed(2)}',
                  style: GoogleFonts.montserrat(
                    fontSize: responsive.textSize(2.2),
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: carts.isEmpty
                  ? null
                  : () async {
                bool isLoggedIn = await _checkLoginStatus();
                if (isLoggedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultistepForm(product: {}, userDetails: {},),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Signin(),
                    ),
                  );
                }
              },
              child: Text(
                'Checkout',
                style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: responsive.textSize(2.2),
                    fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: carts.isEmpty ? Colors.grey : Color(0xff0D6EFD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.widthPercentage(2)),
                ),
              ),
            ),
          ],
        ),
      )
          : Padding(
        padding: EdgeInsets.all(responsive.widthPercentage(2)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                Text(
                  'Grand Total:',
                  style: GoogleFonts.montserrat(
                    fontSize: responsive.textSize(2.2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: responsive.widthPercentage(2)),
                Text(
                  '\$${calculateGrandTotal().toStringAsFixed(2)}',
                  style: GoogleFonts.montserrat(
                    fontSize: responsive.textSize(2.2),
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: carts.isEmpty
                  ? null
                  : () async {
                bool isLoggedIn = await _checkLoginStatus();
                if (isLoggedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultistepForm(product: {}, userDetails: {},
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Signin(),
                    ),
                  );
                }
              },
              child: Text(
                'Checkout',
                style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: responsive.textSize(2.2),
                    fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: carts.isEmpty ? Colors.grey : Color(0xff0D6EFD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.widthPercentage(2)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  double calculateGrandTotal() {
    double grandTotal = 0.0;

    for (var cart in carts) {
      for (var inventory in cart['inventories']) {
        // Safely get quantity and unit price, ensuring correct types
        var quantityValue = inventory['pivot']['quantity'];
        int quantity = 1; // Default value
        if (quantityValue is int) {
          quantity = quantityValue;
        } else if (quantityValue is String) {
          quantity = int.tryParse(quantityValue) ?? 1;
        }

        var unitPriceValue = inventory['pivot']['unit_price'];
        double unitPrice = 0.0; // Default value
        if (unitPriceValue is double) {
          unitPrice = unitPriceValue;
        } else if (unitPriceValue is String) {
          unitPrice = double.tryParse(unitPriceValue) ?? 0.0;
        }

        grandTotal += unitPrice * quantity;
      }
    }

    return grandTotal;
  }

}
