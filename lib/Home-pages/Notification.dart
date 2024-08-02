import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bottombar/bottombar.dart';
import 'home.dart';

class notification extends StatefulWidget {
  final List<Map<String, dynamic>> favoriteProducts;

  const notification ({super.key, required this.favoriteProducts});


  @override
  State<notification > createState() => _notificationState();
}

class _notificationState extends State<notification > {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text('Notification',
        style: GoogleFonts.montserrat(),),
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
      body: widget.favoriteProducts.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/no-notification.png',
              height: 150,
              width: 250,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'No message notification',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
              },
              child: Text(
                'Return to home page',
                style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff0D6EFD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),          ],
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: screenWidth < 600 ? 2 : 4,
          crossAxisSpacing: screenWidth * 0.02,
          mainAxisSpacing: screenHeight * 0.02,
          childAspectRatio: 0.75,
        ),
        itemCount: widget.favoriteProducts.length,
        itemBuilder: (context, index) {
          final product = widget.favoriteProducts[index];
          return Container(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Card(
              elevation: 4,
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: screenWidth * 0.05,
                        ),
                        onPressed: () {
                          setState(() {
                            product['isFavorite'] = !product['isFavorite'];
                            if (!product['isFavorite']) {
                              widget.favoriteProducts.removeAt(index);
                            }
                          });
                        },
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: Image.asset(
                          product['image'],
                          width: screenWidth * 0.3,
                          height: screenHeight * 0.15,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    product['name'],
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    product['price'],
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
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
