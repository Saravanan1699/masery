import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../Home-pages/home.dart';
import '../single-product-view/single-prodect-view.dart';

class FilterCategory extends StatefulWidget {
  final String slug;

  const FilterCategory({Key? key, required this.slug}) : super(key: key);

  @override
  State<FilterCategory> createState() => _FilterCategoryState();
}

class _FilterCategoryState extends State<FilterCategory> {
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  bool isLoading = true;
  bool hasResults = true; // Track if there are search results

  late TextEditingController _searchController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();
    fetchProductsBySlug(widget.slug);
  }

  Future<void> fetchProductsBySlug(String slug) async {
    final url =
        'https://sgitjobs.com/MaseryShoppingNew/public/api/search?q=$slug';

    try {
      final response = await http.get(Uri.parse(url));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          products = data['data'] ?? [];
          filteredProducts = products; // Initialize filteredProducts
          isLoading = false;
          hasResults = filteredProducts.isNotEmpty; // Update hasResults
        });
      } else {
        print('Error: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _searchProducts(String query) {
    setState(() {
      filteredProducts = products
          .where((product) =>
      (product['title'] ?? '')
          .toLowerCase()
          .contains(query.toLowerCase()) ||
          (product['slug'] ?? '')
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();

      hasResults = filteredProducts.isNotEmpty; // Update hasResults
    });
  }

  String _getItemCountText() {
    final itemCount = filteredProducts.length;
    return '$itemCount ${itemCount == 1 ? 'Item' : 'Items'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Category',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            color: Color(0xFF2B2B2B),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
            );
          },
        ),
      ),
      body: isLoading
          ? Center(
        child: LoadingAnimationWidget.halfTriangleDot(
          size: 50.0,
          color: Colors.redAccent,
        ),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _searchProducts,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Search any Product...',
                    hintStyle: GoogleFonts.montserrat(),
                    prefixIcon: Icon(Icons.search, color: Color(0xffBBBBBB)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Color(0xffF2F2F2),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),

              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(width: 10),
                Text(
                  _getItemCountText(),
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
              ],
            ),
          ),

          Expanded(
            child: filteredProducts.isEmpty
                ?  Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/search-no-data.png',
                      height: 300,
                      width: 300,
                    ),
                    Text('No Result!',
                        style: GoogleFonts.montserrat(
                            fontSize: 15)),
                  ],
                ))
                : ListView.builder(
              itemCount: (filteredProducts.length + 1) ~/ 2, // Adjust count for pairs
              itemBuilder: (context, index) {
                final int firstIndex = index * 2;
                final product1 = filteredProducts[firstIndex];
                final product2 = (firstIndex + 1 < filteredProducts.length)
                    ? filteredProducts[firstIndex + 1]
                    : null;

                return ResponsiveCardRow(
                  screenWidth: MediaQuery.of(context).size.width,
                  screenHeight: MediaQuery.of(context).size.height,
                  product1: product1,
                  product2: product2,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final Map<String, dynamic> product;

  const ProductCard({
    required this.screenWidth,
    required this.screenHeight,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final images = product['product']['image'] ?? [];
    final imageUrl = images.isNotEmpty
        ? 'https://sgitjobs.com/MaseryShoppingNew/public/${images[0]['path']}'
        : '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetail(product: product),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  imageUrl,
                  height: screenHeight * 0.25,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Placeholder(fallbackHeight: screenHeight * 0.25);
                  },
                ),
              )
            else
              Placeholder(fallbackHeight: screenHeight * 0.25),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product['title'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                    fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product['description'] ?? '',
                style: GoogleFonts.montserrat(fontSize: 15),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '\$${product['sale_price'] != null ? double.tryParse(product['sale_price'].toString())?.toStringAsFixed(2) ?? 'N/A' : 'N/A'}',
                style: GoogleFonts.montserrat(
                    fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResponsiveCardRow extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final dynamic product1;
  final dynamic? product2;

  const ResponsiveCardRow({
    required this.screenWidth,
    required this.screenHeight,
    required this.product1,
    this.product2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ProductCard(
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            product: product1,
          ),
        ),
        if (product2 != null)
          Expanded(
            child: ProductCard(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              product: product2!,
            ),
          ),
      ],
    );
  }
}
