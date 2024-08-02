import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../Base_Url/BaseUrl.dart';
import '../Home-pages/home.dart';
import '../single-product-view/single-prodect-view.dart';
import '../bottombar/bottombar.dart';

class CategoryDescription extends StatefulWidget {
  @override
  _CategoryDescriptionState createState() => _CategoryDescriptionState();
}

class _CategoryDescriptionState extends State<CategoryDescription> {
  List<dynamic> allProducts = [];
  List<dynamic> filteredProducts = [];
  dynamic about;
  bool isLoading = true;
  bool hasError = false;
  bool hasResults = true;
  List<dynamic> selectedBrands = []; // Correct initialization

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
        setState(() {
          allProducts = jsonResponse['data']['allProducts'];
          filteredProducts = allProducts;
          about = jsonResponse['data']['about'];
          isLoading = false;
          hasError = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> fetchFilteredProducts({
    required List<int> brandIds,
    required double minPrice,
    required double maxPrice,
  }) async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      // Construct the brand query parameters if there are any brand IDs
      final brandQueries = brandIds.isNotEmpty
          ? brandIds.map((id) => 'brand=$id').join('&')
          : '';

      // Construct the price query parameters
      final priceQuery = 'min_price=$minPrice&max_price=$maxPrice';

      // Construct the full URL with brand and price queries
      final url = '${ApiConfig.baseUrl}search'
          '${brandQueries.isNotEmpty ? '?$brandQueries' : ''}'
          '${brandQueries.isNotEmpty && priceQuery.isNotEmpty ? '&' : (brandQueries.isEmpty ? '?' : '')}$priceQuery';

      // Make the HTTP GET request
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        setState(() {
          allProducts = data;
          filteredProducts = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load filtered products');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> _showFilterDialog() async {
    List<int> selectedBrands = [];
    double minPrice = 0;
    double maxPrice = 10000;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Select Brands', style: GoogleFonts.montserrat()),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _buildBrandFilterItem(
                          brandId: 5,
                          brandName: 'Acer',
                          isSelected: selectedBrands.contains(5),
                          onTap: () {
                            setState(() {
                              if (selectedBrands.contains(5)) {
                                selectedBrands.remove(5);
                              } else {
                                selectedBrands.add(5);
                              }
                            });
                          },
                        ),
                        SizedBox(width: 10),
                        _buildBrandFilterItem(
                          brandId: 7,
                          brandName: 'Samsung',
                          isSelected: selectedBrands.contains(7),
                          onTap: () {
                            setState(() {
                              if (selectedBrands.contains(7)) {
                                selectedBrands.remove(7);
                              } else {
                                selectedBrands.add(7);
                              }
                            });
                          },
                        ),
                        // Repeat for other brands in the first row
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _buildBrandFilterItem(
                          brandId: 12,
                          brandName: 'Asus Vivobook',
                          isSelected: selectedBrands.contains(12),
                          onTap: () {
                            setState(() {
                              if (selectedBrands.contains(12)) {
                                selectedBrands.remove(12);
                              } else {
                                selectedBrands.add(12);
                              }
                            });
                          },
                        ),
                        SizedBox(width: 10),
                        _buildBrandFilterItem(
                          brandId: 6,
                          brandName: 'Hp',
                          isSelected: selectedBrands.contains(6),
                          onTap: () {
                            setState(() {
                              if (selectedBrands.contains(6)) {
                                selectedBrands.remove(6);
                              } else {
                                selectedBrands.add(6);
                              }
                            });
                          },
                        ),
                        // Repeat for other brands in the second row
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _buildBrandFilterItem(
                          brandId: 11,
                          brandName: 'Xiaomi',
                          isSelected: selectedBrands.contains(11),
                          onTap: () {
                            setState(() {
                              if (selectedBrands.contains(11)) {
                                selectedBrands.remove(11);
                              } else {
                                selectedBrands.add(11);
                              }
                            });
                          },
                        ),
                        SizedBox(width: 10),
                        _buildBrandFilterItem(
                          brandId: 17,
                          brandName: 'Samsung Galaxy',
                          isSelected: selectedBrands.contains(17),
                          onTap: () {
                            setState(() {
                              if (selectedBrands.contains(17)) {
                                selectedBrands.remove(17);
                              } else {
                                selectedBrands.add(17);
                              }
                            });
                          },
                        ),
                        // Repeat for other brands in the third row
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _buildBrandFilterItem(
                          brandId: 15,
                          brandName: 'Samsung Galaxy A11',
                          isSelected: selectedBrands.contains(15),
                          onTap: () {
                            setState(() {
                              if (selectedBrands.contains(15)) {
                                selectedBrands.remove(15);
                              } else {
                                selectedBrands.add(15);
                              }
                            });
                          },
                        ),
                        SizedBox(width: 10),
                        _buildBrandFilterItem(
                          brandId: 18,
                          brandName: 'IQOO',
                          isSelected: selectedBrands.contains(18),
                          onTap: () {
                            setState(() {
                              if (selectedBrands.contains(18)) {
                                selectedBrands.remove(18);
                              } else {
                                selectedBrands.add(18);
                              }
                            });
                          },
                        ),
                        // Repeat for other brands in the fourth row
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _buildBrandFilterItem(
                          brandId: 21,
                          brandName: 'OnePlus',
                          isSelected: selectedBrands.contains(21),
                          onTap: () {
                            setState(() {
                              if (selectedBrands.contains(21)) {
                                selectedBrands.remove(21);
                              } else {
                                selectedBrands.add(21);
                              }
                            });
                          },
                        ),
                        SizedBox(width: 10),
                        _buildBrandFilterItem(
                          brandId: 2,
                          brandName: 'Asus',
                          isSelected: selectedBrands.contains(2),
                          onTap: () {
                            setState(() {
                              if (selectedBrands.contains(2)) {
                                selectedBrands.remove(2);
                              } else {
                                selectedBrands.add(2);
                              }
                            });
                          },
                        ),
                        // Repeat for other brands in the fifth row
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancel',
                  style: GoogleFonts.montserrat(
                      color: Color(0xff0D6EFD), fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(color: Color(0xff0D6EFD)),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Filter',
                  style: GoogleFonts.montserrat(
                      color: Colors.white, fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff0D6EFD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                fetchFilteredProducts(
                  brandIds: selectedBrands,
                  minPrice: minPrice,
                  maxPrice: maxPrice,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBrandFilterItem({
    required int brandId,
    required String brandName,
    required bool isSelected,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          brandName,
          style: GoogleFonts.montserrat(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Future<void> _showFilterPrice() async {
    List<int> selectedBrands = [];
    double minPrice = 0;
    double maxPrice = 10000;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'Select Price Range',
                style: GoogleFonts.montserrat(),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RangeSlider(
                    activeColor: Color(0xff0D6EFD),
                    values: RangeValues(minPrice, maxPrice),
                    min: 0,
                    max: 10000,
                    divisions: 100,
                    onChanged: (RangeValues values) {
                      setState(() {
                        minPrice = values.start;
                        maxPrice = values.end;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Min: \$${minPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.montserrat(),
                      ),
                      Text(
                        'Max: \$${maxPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.montserrat(),
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: Text('Cancel',
                      style: GoogleFonts.montserrat(
                          color: Color(0xff0D6EFD), fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: BorderSide(color: Color(0xff0D6EFD)),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Filter',
                      style: GoogleFonts.montserrat(
                          color: Colors.white, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff0D6EFD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    fetchFilteredProducts(
                      brandIds: selectedBrands,
                      minPrice: minPrice,
                      maxPrice: maxPrice,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _searchProducts(String query) {
    setState(() {
      filteredProducts = allProducts
          .where((product) =>
      (product['title'] ?? '')
          .toLowerCase()
          .contains(query.toLowerCase()) ||
          (product['slug'] ?? '')
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();

      hasResults = filteredProducts.isNotEmpty;
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
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      _getItemCountText(),
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: _showFilterDialog,
                      child: SizedBox(
                        width: 90,
                        height: 40,
                        child: Card(
                          color: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                              child: Text(
                                'Brands',
                                style: GoogleFonts.montserrat(),
                              )),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: _showFilterPrice,
                      child: SizedBox(
                        width: 90,
                        height: 40,
                        child: Card(
                          color: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                              child: Text(
                                'Price',
                                style: GoogleFonts.montserrat(),
                              )),
                        ),
                      ),
                    ),
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
    final imagePaths = product['product'] != null &&
        product['product']['image'] != null &&
        (product['product']['image'] as List).isNotEmpty
        ? product['product']['image'] as List
        : [];

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
