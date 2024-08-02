import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:convert';
import '../Base_Url/BaseUrl.dart';
import '../Responsive/responsive.dart';
import '../bottombar/bottombar.dart';
import 'home.dart';

class Wishlist extends StatefulWidget {
  const Wishlist({Key? key}) : super(key: key);

  @override
  State<Wishlist> createState() => _WishlistState();
}

class _WishlistState extends State<Wishlist> {
  List<dynamic> favoriteProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWishlistData();
  }

  Future<void> _fetchWishlistData() async {
    final url = Uri.parse('${ApiConfig.baseUrl}getwishlist');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          favoriteProducts = data['wishlist']['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load wishlist');
      }
    } catch (e) {
      print('Error fetching wishlist: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _removeFromWishlist(int productId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}removefromWishlist/$productId');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({'product_id': productId});

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        setState(() {
          favoriteProducts.removeWhere((product) => product['id'] == productId);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Item removed from wishlist'),
          duration: Duration(seconds: 2),
        ));
      } else if (response.statusCode == 404) {
        final responseBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseBody['error']),
          duration: Duration(seconds: 2),
        ));
      } else {
        throw Exception('Failed to remove from wishlist: ${response.statusCode}');
      }
    } catch (e) {
      print('Error removing from wishlist: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to remove item from wishlist'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Future<void> _addToCart(String slug) async {
    final url = Uri.parse('${ApiConfig.baseUrl}addToCart/$slug');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'quantity': 1,
      'shipTo': 1,
      'shippingZoneId': 1,
      'handling': 1
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Item added to cart'),
          duration: Duration(seconds: 2),
        ));
      } else if (response.statusCode == 402) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseBody['message'] ?? 'This item is already in the cart')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseBody['message'] ?? 'Failed to add product to cart')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An error occurred: $e')),
      );
    }
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
          'Favorite',
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                },
              ),
            );
          },
        ),
      ),
      body: isLoading
          ? Center(
        child: LoadingAnimationWidget.halfTriangleDot(
          size: responsive.textSize(10),
          color: Colors.redAccent,
        ),
      )
          : favoriteProducts.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/wishlist-empty.png',
              height: responsive.heightPercentage(20),
              width: responsive.widthPercentage(40),
            ),
            SizedBox(height: responsive.heightPercentage(1)),
            Text(
              'Your Wishlist is empty!',
              style: GoogleFonts.montserrat(
                fontSize: responsive.textSize(2.5),
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              'Seems like you don\'t have wishes here.',
              style: GoogleFonts.montserrat(
                fontSize: responsive.textSize(2.5),
                fontWeight: FontWeight.w400,
                color: Colors.grey[400],
              ),
            ),
            Text(
              'Make a wish!',
              style: GoogleFonts.montserrat(
                fontSize: responsive.textSize(2.5),
                fontWeight: FontWeight.w400,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: responsive.heightPercentage(2)),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
              },
              child: Text(
                'Start shopping',
                style: GoogleFonts.montserrat(color: Colors.white, fontSize: responsive.textSize(2.5)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff0D6EFD),
                shape: RoundedRectangleBorder(
                  borderRadius: responsive.borderRadiusPercentage(2),
                ),
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: favoriteProducts.length,
        itemBuilder: (context, index) {
          final product = favoriteProducts[index]['inventory'];
          final productId = favoriteProducts[index]['id'];
          final productSlug = product['slug'];

          // Check if there is an image list and get the first image path
          final imageList = favoriteProducts[index]['product']['image'];
          final imageUrl = imageList.isNotEmpty
              ? 'https://sgitjobs.com/MaseryShoppingNew/public/${imageList[0]['path']}'
              : '';

          return Container(
            padding: responsive.paddingPercentage(2, 2, 2, 2),
            child: Card(
              elevation: 4,
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: responsive.paddingPercentage(2, 2, 2, 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                            imageUrl,
                            width: responsive.widthPercentage(30),
                            height: responsive.heightPercentage(15),
                            fit: BoxFit.contain,
                          )
                              : Image.asset(
                            'assets/no-data.png',
                            height: responsive.heightPercentage(20),
                            width: responsive.widthPercentage(30),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            print('$productId');
                            _removeFromWishlist(productId);
                          },
                          icon: Icon(Icons.delete, color: Colors.orangeAccent),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: responsive.heightPercentage(1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: responsive.paddingPercentage(2, 2, 2, 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['title'] ?? '',
                              style: GoogleFonts.montserrat(
                                fontSize: responsive.textSize(3),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '\$${double.parse(product['sale_price']).toStringAsFixed(2)}',
                              style: GoogleFonts.montserrat(
                                fontSize: responsive.textSize(2.5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: responsive.paddingPercentage(2, 2, 2, 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                print('Adding to cart: $productSlug');
                                _addToCart(productSlug);
                              },
                              child: Text(
                                'Add to Cart',
                                style: GoogleFonts.montserrat(
                                  color: Color(0xff0D6EFD),
                                  fontSize: responsive.textSize(2.5),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: responsive.borderRadiusPercentage(2),
                                  side: BorderSide(color: Color(0xff0D6EFD)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomBar(
        onTap: (index) {},
      ),
    );
  }
}
