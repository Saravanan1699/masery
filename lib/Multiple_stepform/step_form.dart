import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Base_Url/BaseUrl.dart';
import '../Home-pages/home.dart';
import '../my-order-list/myorderlist.dart';

class MultistepForm extends StatefulWidget {
  final Map<String, dynamic> product;
  final Map<String, String> userDetails;

  const MultistepForm(
      {Key? key, required this.product, required this.userDetails})
      : super(key: key);

  @override
  _MultistepFormState createState() => _MultistepFormState();
}

class _MultistepFormState extends State<MultistepForm> {
  int _activeStepIndex = 0;
  bool _isClicked = false;
  bool _autoValidateMode = false;

  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> product;
  List<Map<String, dynamic>>? productData;
  List<Map<String, dynamic>>? total;
  List<Map<String, dynamic>> quatityData = [];
  bool _sameAsShipping = false;
  bool _isPaymentMethodSelected = false;

  TextEditingController _shippingFirstNameController = TextEditingController();
  TextEditingController _shippingLastNameController = TextEditingController();
  TextEditingController _shippingEmailController = TextEditingController();
  TextEditingController _shippingPhoneNumberController =
      TextEditingController();
  TextEditingController _shippingCountryController = TextEditingController();
  TextEditingController _shippingAddressController = TextEditingController();
  TextEditingController _shippingCityController = TextEditingController();
  TextEditingController _shippingZipController = TextEditingController();
  TextEditingController _billingFirstNameController = TextEditingController();
  TextEditingController _billingLastNameController = TextEditingController();
  TextEditingController _billingEmailController = TextEditingController();
  TextEditingController _billingPhoneNumberController = TextEditingController();
  TextEditingController _billingCountryController = TextEditingController();
  TextEditingController _billingAddressController = TextEditingController();
  TextEditingController _billingCityController = TextEditingController();
  TextEditingController _billingZipController = TextEditingController();

  @override
  void dispose() {
    _shippingFirstNameController.dispose();
    _shippingLastNameController.dispose();
    _shippingEmailController.dispose();
    _shippingPhoneNumberController.dispose();
    _shippingCountryController.dispose();
    _shippingAddressController.dispose();
    _shippingCityController.dispose();
    _shippingZipController.dispose();
    _billingFirstNameController.dispose();
    _billingLastNameController.dispose();
    _billingEmailController.dispose();
    _billingPhoneNumberController.dispose();
    _billingCountryController.dispose();
    _billingAddressController.dispose();
    _billingCityController.dispose();
    _billingZipController.dispose();
    super.dispose();
  }

  void _toggleSameAsShipping(bool? value) {
    setState(() {
      _sameAsShipping = value ?? false;
      if (_sameAsShipping) {
        _billingFirstNameController.text = _shippingFirstNameController.text;
        _billingLastNameController.text = _shippingLastNameController.text;
        _billingEmailController.text = _shippingEmailController.text;
        _billingPhoneNumberController.text =
            _shippingPhoneNumberController.text;
        _billingCountryController.text = _shippingCountryController.text;
        _billingAddressController.text = _shippingAddressController.text;
        _billingCityController.text = _shippingCityController.text;
        _billingZipController.text = _shippingZipController.text;
      } else {
        _billingFirstNameController.clear();
        _billingLastNameController.clear();
        _billingEmailController.clear();
        _billingPhoneNumberController.clear();
        _billingCountryController.clear();
        _billingAddressController.clear();
        _billingCityController.clear();
        _billingZipController.clear();
      }
    });
  }

  void _populateUserDetails() {
    final userDetails = widget.userDetails;

    // Populate shipping address fields
    _shippingFirstNameController.text = userDetails['shippingFirstName'] ?? '';
    _shippingLastNameController.text = userDetails['shippingLastName'] ?? '';
    _shippingEmailController.text = userDetails['shippingEmail'] ?? '';
    _shippingPhoneNumberController.text = userDetails['shippingPhoneNumber'] ?? '';
    _shippingCountryController.text = userDetails['shippingCountry'] ?? '';
    _shippingAddressController.text = userDetails['shippingAddress'] ?? '';
    _shippingCityController.text = userDetails['shippingCity'] ?? '';
    _shippingZipController.text = userDetails['shippingZip'] ?? '';

    // Populate billing address fields
    _billingFirstNameController.text = userDetails['billingFirstName'] ?? '';
    _billingLastNameController.text = userDetails['billingLastName'] ?? '';
    _billingEmailController.text = userDetails['billingEmail'] ?? '';
    _billingPhoneNumberController.text = userDetails['billingPhoneNumber'] ?? '';
    _billingCountryController.text = userDetails['billingCountry'] ?? '';
    _billingAddressController.text = userDetails['billingAddress'] ?? '';
    _billingCityController.text = userDetails['billingCity'] ?? '';
    _billingZipController.text = userDetails['billingZip'] ?? '';
  }

  @override
  void initState() {
    super.initState();
    product = widget.product;
    fetchData();
    orderData();
    _getToken();
    _populateUserDetails();
  }

  Future<void> fetchData() async {
    try {
      String cartId = await fetchCartId();
      String url = '${ApiConfig.baseUrl}cart/$cartId/checkout';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          productData = List<Map<String, dynamic>>.from(
              json.decode(response.body)['data'][0]['inventories']);
        });
      } else {
        throw Exception('Failed to load product data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> orderData() async {
    try {
      String cartId = await fetchCartId();
      String url = '${ApiConfig.baseUrl}cart/$cartId/checkout';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          quatityData = List<Map<String, dynamic>>.from(
              jsonDecode(response.body)['data']);
        });
      } else {
        throw Exception('Failed to load product data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<String> fetchCartId() async {
    final response =
        await http.get(Uri.parse('${ApiConfig.baseUrl}totalitems'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      String cartId = data['cart_id'].toString();
      return cartId;
    } else {
      throw Exception('Failed to fetch cart_id');
    }
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _handleCheckout() async {
    if (!_isPaymentMethodSelected) {
      _showSnackBar("Please select a payment method");
      return;
    }

    if (!_formKey.currentState!.validate()) {
      _showSnackBar("Please fill in all required fields");
      return;
    }

    final token = await _getToken();
    if (token == null) {
      print("No token found");
      _showSnackBar("No authentication token found.");
      return;
    }

    // Prepare shipping and billing details
    final shippingFirstName = _shippingFirstNameController.text;
    final shippingLastName = _shippingLastNameController.text;
    final shippingEmail = _shippingEmailController.text;
    final shippingPhoneNumber = _shippingPhoneNumberController.text;
    final shippingCountry = _shippingCountryController.text;
    final shippingAddress = _shippingAddressController.text;
    final shippingCity = _shippingCityController.text;
    final shippingZip = _shippingZipController.text;

    final billingFirstName = _billingFirstNameController.text;
    final billingLastName = _billingLastNameController.text;
    final billingEmail = _billingEmailController.text;
    final billingPhoneNumber = _billingPhoneNumberController.text;
    final billingCountry = _billingCountryController.text;
    final billingAddress = _billingAddressController.text;
    final billingCity = _billingCityController.text;
    final billingZip = _billingZipController.text;

    // Format the user details string
    final shippingDetails = '$shippingFirstName,$shippingLastName,$shippingEmail,$shippingPhoneNumber,$shippingCountry,$shippingAddress,$shippingCity,$shippingZip';
    final billingDetails = '$billingFirstName,$billingLastName,$billingEmail,$billingPhoneNumber,$billingCountry,$billingAddress,$billingCity,$billingZip';

    try {
      final cartId = await fetchCartId();
      if (cartId == null) {
        print("Cart ID is null");
        _showSnackBar("Failed to retrieve cart ID.");
        return;
      }

      final url = '${ApiConfig.baseUrl}cart/$cartId/checkout';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = jsonEncode({
        'payment_method_id': 1,
        'shipping_address': shippingDetails, // Pass the formatted string here
        'billing_address': billingDetails, // Pass the formatted string here
      });

      print("Request URL: $url");
      print("Request Headers: $headers");
      print("Request Body: $body");

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        print("Checkout successful");
        _showSuccessDialog(); // Show success dialog
      } else {
        print("Checkout failed: ${response.statusCode}");
        print("Response body: ${response.body}");
        _showSnackBar("Checkout failed: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred: $e");
      _showSnackBar("An error occurred during checkout. Please try again.");
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/tick.png',
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          content: Text(
            'Your order has been placed successfully',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w500,
              fontSize: 17,
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Orderlist(),
                    ),
                  );
                },
                child: Text(
                  'Order History',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff0D6EFD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Step> stepList() => [
        Step(
          state: _activeStepIndex <= 0 ? StepState.editing : StepState.complete,
          isActive: _activeStepIndex >= 0,
          title: Text(
            'Address',
            style: GoogleFonts.montserrat(),
          ),
          content: Column(
            children: [
              Form(
                  key: _formKey,
                  autovalidateMode: _autoValidateMode
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(children: [
                      Row(
                        children: [
                          Text(
                            'Shipping Address Details',
                            style: GoogleFonts.raleway(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      _buildTextField(
                        'First Name',
                        _shippingFirstNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your First Name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      _buildTextField(
                        'Last Name',
                        _shippingLastNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Last Name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      _buildTextField(
                        'Email',
                        _shippingEmailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid Email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      _buildTextField(
                        'Phone Number',
                        _shippingPhoneNumberController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Phone Number';
                          }
                          if (!RegExp(r'^\+?1?\d{9,15}$').hasMatch(value)) {
                            return 'Please enter a valid Phone Number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      _buildTextField(
                        'Country',
                        _shippingCountryController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Country';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      _buildTextField(
                        'Address',
                        _shippingAddressController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      _buildTextField(
                        'Town / City',
                        _shippingCityController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Town or City';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      _buildTextField(
                        'Postcode / ZIP',
                        _shippingZipController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Postcode or ZIP';
                          }
                          if (!RegExp(r'^\d{6}(-\d{6})?$').hasMatch(value)) {
                            return 'Please enter a valid Postcode or ZIP';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      CheckboxListTile(
                        title: Text(
                          'Billing address same as shipping address',
                          style: GoogleFonts.raleway(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                        value: _sameAsShipping,
                        onChanged: _toggleSameAsShipping,
                      ),
                      if (!_sameAsShipping) ...[
                        SizedBox(height: 20),
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Billing Address Details',
                                  style: GoogleFonts.raleway(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontSize: 18),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            _buildTextField(
                              'First Name',
                              _billingFirstNameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your First Name';
                                }
                                return null;
                              },
                              enabled: !_sameAsShipping,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            _buildTextField(
                              'Last Name',
                              _billingLastNameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your Last Name';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            _buildTextField(
                              'Email',
                              _billingEmailController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your Email';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid Email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            _buildTextField(
                              'Phone Number',
                              _billingPhoneNumberController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your Phone Number';
                                }
                                if (!RegExp(r'^\+?1?\d{9,15}$')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid Phone Number';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            _buildTextField(
                              'Country',
                              _billingCountryController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your Country';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            _buildTextField(
                              'Address',
                              _billingAddressController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your Address';
                                }
                                return null;
                              },
                              enabled: !_sameAsShipping,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            _buildTextField(
                              'Town / City',
                              _billingCityController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your Town or City';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            _buildTextField(
                              'Postcode / ZIP',
                              _billingZipController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your Postcode or ZIP';
                                }
                                if (!RegExp(r'^\d{6}(-\d{6})?$')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid Postcode or ZIP';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ],
                    ]),
                  ))
            ],
          ),
        ),
        Step(
          state: _activeStepIndex <= 1 ? StepState.editing : StepState.complete,
          isActive: _activeStepIndex >= 1,
          title: Text(
            'Order',
            style: GoogleFonts.montserrat(),
          ),
          content: productData == null
              ? Center(
                  child: Container(
                    child: LoadingAnimationWidget.halfTriangleDot(
                      size: 50.0,
                      color: Colors.redAccent,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: productData!.map((product) {
                      return Card(
                        elevation: 4,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: SizedBox(
                          height: 215,
                          width: 340,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    product['product'] != null &&
                                            product['product']['images'] != null
                                        ? Image.network(
                                            'https://sgitjobs.com/MaseryShoppingNew/public/${product['product']['images'][0]['path']}',
                                            height: 120,
                                            width: 140,
                                            fit: BoxFit.contain,
                                          )
                                        : SizedBox(
                                            height: 120,
                                            width: 140,
                                            child: Center(
                                                child: Text(
                                              'Image not available',
                                              style: GoogleFonts.montserrat(),
                                            )),
                                          ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product['title'] ??
                                                'Title not available',
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            'Price: \$${product['sale_price'] != null ? double.tryParse(product['offer_price'])?.toStringAsFixed(2) ?? 'N/A' : 'N/A'}',
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Divider(color: Colors.grey[300]),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      'Total Order:',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      product['pivot']['quantity'],
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      '\$${(product['pivot']?['quantity'] != null && product['sale_price'] != null) ? (int.tryParse(product['pivot']['quantity'].toString())! * double.tryParse(product['offer_price'])!).toStringAsFixed(2) : 'N/A'}',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ),
        Step(
          state: StepState.complete,
          isActive: _activeStepIndex >= 2,
          title: Text(
            'Payment',
            style: GoogleFonts.montserrat(),
          ),
          content: Container(
            child: SingleChildScrollView(
              child: Column(
                children: quatityData.map((product) {
                  String quantity = product['item_count'] ?? 'N/A';
                  String total;
                  if (product['total'] != null) {
                    total = double.tryParse(product['total'].toString())
                            ?.toStringAsFixed(2) ??
                        'N/A';
                  } else {
                    total = 'N/A';
                  }

                  return Column(
                    children: [
                      Divider(color: Colors.grey[300]),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          SizedBox(width: 20),
                          Text(
                            'Price',
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '($quantity)item',
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          Spacer(),
                          Text(
                            '\$$total', // Display total here
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 20)
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          SizedBox(width: 20),
                          Text(
                            'Delivery Charges',
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: Color(0XFFA8A8A9),
                            ),
                          ),
                          Spacer(),
                          Text(
                            '\$40',
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: Color(0XFFA8A8A9),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'FREE', // Display total here
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(width: 20)
                        ],
                      ),
                      SizedBox(height: 15),
                      Divider(
                        color: Colors.grey[600],
                        indent: 15,
                        endIndent: 15,
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          SizedBox(width: 20),
                          Text(
                            'Total',
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          Spacer(),
                          Text(
                            '\$$total',
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 20)
                        ],
                      ),
                      SizedBox(height: 15),
                      Divider(
                        color: Colors.grey[300],
                        indent: 15,
                        endIndent: 15,
                      ),
                      Row(
                        children: [
                          SizedBox(width: 20),
                          Text(
                            'Payment',
                            style: GoogleFonts.montserrat(fontSize: 20),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isClicked =
                                !_isClicked; // Toggle the state on each tap
                            _isPaymentMethodSelected =
                                true; // Mark payment method as selected
                          });
                        },
                        child: Container(
                          height: 60,
                          width: 340,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color:
                                  _isClicked ? Colors.green : Color(0XFFA8A8A9),
                            ), // Apply border color only if clicked
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/cash.png',
                                height: 45,
                                // width: 250,
                              ),
                              Text(
                                'Cash on Delivery',
                                style: GoogleFonts.montserrat(
                                  color: Color(0XFF6E7179),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Checkout',
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
                      MaterialPageRoute(builder: (context) => HomePage()));
                },
              ),
            );
          },
        ),
      ),
      body: productData == null
          ? Center(
              child: Container(
                child: LoadingAnimationWidget.halfTriangleDot(
                  size: 50.0,
                  color: Colors.redAccent,
                ),
              ),
            )
          : Container(
              color: Colors.white,
              child: Stepper(
                type: StepperType.horizontal,
                currentStep: _activeStepIndex,
                steps: stepList(),
                connectorColor: MaterialStateProperty.all(Color(0xff0D6EFD)),
                onStepContinue: () {
                  if (_activeStepIndex == 0) {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _activeStepIndex += 1;
                      });
                    }
                  } else if (_activeStepIndex < (stepList().length - 1)) {
                    setState(() {
                      _autoValidateMode = true;
                      _activeStepIndex += 1;
                    });
                  } else {
                    _handleCheckout();
                  }
                },
                onStepCancel: () {
                  if (_activeStepIndex > 0) {
                    setState(() {
                      _activeStepIndex -= 1;
                    });
                  }
                },
                onStepTapped: (int index) {
                  setState(() {
                    _activeStepIndex = index;
                  });
                },
                controlsBuilder:
                    (BuildContext context, ControlsDetails details) {
                  final isLastStep = _activeStepIndex == stepList().length - 1;

                  return Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (!isLastStep) {
                              details.onStepContinue!();
                            } else {
                              setState(() {
                                _activeStepIndex -= 1;
                              });
                            }
                          },
                          child: Text(
                            isLastStep ? 'Back' : 'Save',
                            style: GoogleFonts.montserrat(
                              color: Color(0xff0D6EFD),
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Color(0xff0D6EFD)),
                            ),
                            minimumSize: Size(150, 50),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            print(
                                'User Details when button pressed: ${widget.userDetails}');
                            if (isLastStep) {
                              _handleCheckout();
                            } else if (_activeStepIndex > 0) {
                              setState(() {
                                _activeStepIndex -= 1;
                              });
                            }
                          },
                          child: Text(
                            isLastStep ? 'Pay Now' : 'Back',
                            style: GoogleFonts.montserrat(
                              color:
                                  isLastStep ? Colors.white : Color(0xff0D6EFD),
                              fontSize: 17,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isLastStep ? Color(0xff0D6EFD) : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Color(0xff0D6EFD)),
                            ),
                            minimumSize: Size(150, 50),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    FormFieldValidator<String>? validator,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: (_) {
        setState(() {
          _autoValidateMode = true;
        });
      },
      validator: validator,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Color(0xFFC4C4C4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Color(0xFFC4C4C4)),
        ),
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 10.0,
        ),
      ),
      enabled: enabled,
    );
  }
}
