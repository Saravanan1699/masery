import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../Base_Url/BaseUrl.dart';
import '../Home-pages/home.dart';
import '../single-product-view/single-prodect-view.dart';
import '../bottombar/bottombar.dart';

class OurbestproductList extends StatefulWidget {
  const OurbestproductList({Key? key}) : super(key: key);

  @override
  State<OurbestproductList> createState() => _OurbestproductListState();
}

class _OurbestproductListState extends State<OurbestproductList> {
  List<dynamic> ourbestproducts = [];
  List<dynamic> filteredProducts = [];
  dynamic about;
  bool isLoading = true;
  bool hasError = false;
  bool hasResults = true; // New variable to track search results

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final response =
          await http.get(Uri.parse('${ApiConfig.baseUrl}homescreen'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('JSON Response: $jsonResponse'); // Debugging line
        if (mounted) {
          setState(() {
            ourbestproducts = jsonResponse['data']['allProducts'] ?? [];
            filteredProducts = ourbestproducts; // Initialize filteredProducts
            about = jsonResponse['data']['about'];
            isLoading = false;
            hasError = false;
          });
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        if (mounted) {
          setState(() {
            isLoading = false;
            hasError = true;
          });
        }
      }
    } catch (e) {
      print('Error: $e'); // Debugging line
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    }
  }

  void _searchProducts(String query) {
    setState(() {
      filteredProducts = ourbestproducts
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
    return '$itemCount Items';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Our Best Collections',
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
          : hasError
              ? Center(child: Text('Failed to load data'))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    double screenWidth = constraints.maxWidth;
                    double screenHeight = constraints.maxHeight;

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _searchProducts,
                            focusNode: _focusNode,
                            decoration: InputDecoration(
                              hintText: 'Search any Product...',
                              hintStyle: GoogleFonts.montserrat(),
                              prefixIcon:
                                  Icon(Icons.search, color: Color(0xffBBBBBB)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Color(0xffF2F2F2),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              SizedBox(width: 10),
                              Text(
                                _getItemCountText(), // Use the method to get the item count
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
                              ? Center(
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
                                  itemCount:
                                      (filteredProducts.length / 2).ceil(),
                                  itemBuilder: (context, index) {
                                    final int firstProductIndex = index * 2;
                                    final int secondProductIndex =
                                        firstProductIndex + 1;

                                    return ResponsiveCardRow(
                                      screenWidth: screenWidth,
                                      screenHeight: screenHeight,
                                      product1:
                                          filteredProducts[firstProductIndex],
                                      product2: secondProductIndex <
                                              filteredProducts.length
                                          ? filteredProducts[secondProductIndex]
                                          : null,
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                ),
      bottomNavigationBar: BottomBar(
        onTap: (index) {},
      ),
    );
  }
}

class ResponsiveCardRow extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final dynamic product1;
  final dynamic product2;

  ResponsiveCardRow({
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

class ProductCard extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final dynamic product;

  ProductCard({
    required this.screenWidth,
    required this.screenHeight,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final imagePaths = product['product']?['image'] ?? [];
    final imageUrl = imagePaths.isNotEmpty
        ? 'https://sgitjobs.com/MaseryShoppingNew/public/${imagePaths[0]['path']}'
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
              child: Text(product['title'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                      fontSize: 17, fontWeight: FontWeight.bold)),
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
                '\$${(product['sale_price'] != null && product['offer_price'] != null) ? double.tryParse(product['offer_price'].toString())?.toStringAsFixed(2) ?? 'N/A' : 'N/A'}',
                style: GoogleFonts.montserrat(
                    fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
