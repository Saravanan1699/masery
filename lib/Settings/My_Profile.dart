import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Authentication/Sing-in.dart';
import '../Base_Url/BaseUrl.dart';
import '../Home-pages/home.dart';
import '../bottombar/bottombar.dart';
import '../my-order-list/myorderlist.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late SharedPreferences _prefs;
  String? authToken;
  bool isSignedIn = false;

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
  }

  Future<void> initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    authToken = _prefs.getString('authToken');
    setState(() {
      isSignedIn = _prefs.getBool('isSignedIn') ?? false;
    });
  }

  Future<void> logoutAndClearStorage(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String token = prefs.getString('token') ?? '';
    String username = prefs.getString('email') ?? '';

    await prefs.remove('token');
    await prefs.remove('email');

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logged out successfully')),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log out')),
        );
      }
    } catch (e) {
      print('Error logging out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out')),
      );
    }
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return token != null;
  }

  Future<Map<String, String>> _getFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('name') ?? '';
    String email = prefs.getString('email') ?? '';
    return {'name': name, 'email': email};
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'My Profile',
          style: GoogleFonts.raleway(
            fontSize: screenWidth * 0.07,
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
                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  });
                },
              ),
            );
          },
        ),
      ),
      body: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            bool isLoggedIn = snapshot.data ?? false;
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage('assets/avatar.png'),
                        ),
                        SizedBox(width: 16),
                      ],
                    ),
                    isLoggedIn
                        ? FutureBuilder<Map<String, String>>(
                      future: _getFromLocalStorage(),
                      builder: (BuildContext context,
                          AsyncSnapshot<Map<String, String>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Container(
                              child:
                              LoadingAnimationWidget.halfTriangleDot(
                                size: 50.0,
                                color: Colors.redAccent,
                              ),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else {
                          var data = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${data['name']}',
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2B2B2B),
                                ),
                              ),
                              Text(
                                '${data['email']}',
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.04,
                                  color: Color(0xFF2B2B2B),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    )
                        : Text(
                      'No Profile',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2B2B2B),
                      ),
                    ),
                    // Add Order History Row
                    SizedBox(height: 10),
                    Divider(
                      color: Colors.grey[300],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order History',
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.038,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2B2B2B),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: screenWidth * 0.06,
                            color: isLoggedIn ? Color(0xFF2B2B2B) : Colors.transparent,
                          ),
                          onPressed: isLoggedIn
                              ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Orderlist()),
                            );
                          }
                              : null,
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isLoggedIn ? 'Logout' : 'Login',
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.038,
                            fontWeight: FontWeight.w700,
                            color: isLoggedIn ? Color(0xFFEA1712) : Colors.blue,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (isLoggedIn) {
                              logoutAndClearStorage(context);
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Signin(),
                                ),
                              );
                            }
                          },
                          child: Icon(
                            isLoggedIn ? Icons.logout : Icons.login,
                            size: screenWidth * 0.06,
                            color: isLoggedIn ? Color(0xFFEA1712) : Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    Divider(
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: BottomBar(
        onTap: (index) {
          setState(() {});
        },
      ),
    );
  }
}
