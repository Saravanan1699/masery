import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Base_Url/BaseUrl.dart';
import '../Home-pages/home.dart';
import '../Product-pages/categorylistview.dart';
import '../Home-pages/cartpage.dart';

class BottomBar extends StatefulWidget {
  final Function(int) onTap;

  BottomBar({required this.onTap});

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int totalItems = 0;
  int totalWishItems = 0;

  @override
  void initState() {
    super.initState();
    fetchTotalItems();
    fetchTotalWishlistItems();
  }

  Future<void> fetchTotalItems() async {
    try {
      final response =
          await http.get(Uri.parse('${ApiConfig.baseUrl}totalitems'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Response Data: $responseData');
        int items = await fetchTotalWishlistItems();
        setState(() {
          totalWishItems = items;
          totalItems = responseData['total_items'] ?? 0;
        });
      } else {
        throw Exception('Failed to load total items');
      }
    } catch (e) {
      print('Error fetching total items: $e');
      setState(() {
        totalItems = 0;
      });
    }
  }

  Future<int> fetchTotalWishlistItems() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}totalwishlistitems'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Response Data: $responseData');

        return responseData['total_items'] ?? 0;
      } else {
        throw Exception('Failed to load total items');
      }
    } catch (e) {
      print('Error fetching total items: $e');
      return 0;
    }
  }

  // Future<void> fetchTotalItems() async {
  //   try {
  //     final response = await http.get(Uri.parse('${ApiConfig.baseUrl}totalitems'));
  //     print('Status Code: ${response.statusCode}'); // Debug print
  //
  //     if (response.statusCode == 200) {
  //       final responseData = json.decode(response.body);
  //       print('Response Data: $responseData'); // Debug print
  //
  //       if (responseData.containsKey('total_items')) {
  //         setState(() {
  //           totalItems = responseData['total_items'];
  //         });
  //         print('Total Items Updated: $totalItems'); // Debug print
  //       } else {
  //         print('total_items key not found in response'); // Debug print
  //         setState(() {
  //           totalItems = 0;
  //         });
  //       }
  //     } else {
  //       throw Exception('Failed to load total items');
  //     }
  //   } catch (e) {
  //     print('Error fetching total items: $e');
  //     setState(() {
  //       totalItems = 0;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        // BottomNavigationBarItem(
        //   icon: Stack(
        //     children: [
        //       Icon(Icons.favorite_border),
        //       if (totalWishItems > 0)
        //         Positioned(
        //           right: 0,
        //           child: Container(
        //             padding: EdgeInsets.all(2),
        //             decoration: BoxDecoration(
        //               color: Colors.blue,
        //               borderRadius: BorderRadius.circular(10),
        //             ),
        //             constraints: BoxConstraints(
        //               minWidth: 16,
        //               minHeight: 16,
        //             ),
        //             child: Text(
        //               '$totalWishItems',
        //               style: TextStyle(
        //                 color: Colors.white,
        //                 fontSize: 10,
        //                 fontWeight: FontWeight.bold,
        //               ),
        //               textAlign: TextAlign.center,
        //             ),
        //           ),
        //         ),
        //     ],
        //   ),
        //   label: 'Wishlist',
        // ), // BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: 'Notification'),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              Icon(Icons.shopping_cart_outlined),
              if (totalItems > 0)
                Positioned(
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$totalItems',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined), label: 'Category'),
      ],
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      onTap: (index) {
        widget.onTap(index);
        switch (index) {
          case 0:
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomePage()));
            break;
          // case 1:
          //   Navigator.push(
          //       context, MaterialPageRoute(builder: (context) => Wishlist()));
          //   break;
          // case 2:
          //   Navigator.push(context, MaterialPageRoute(builder: (context) => notification(favoriteProducts: [],)));
          //   break;
          case 1:
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => CartPage()));
            break;
          case 2:
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CategoryDescription()));
            break;
          default:
            break;
        }
      },
    );
  }
}
