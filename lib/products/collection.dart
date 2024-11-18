import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screens/base_screen.dart';
import 'product.dart';

class CollectionScreen extends StatefulWidget {
  @override
  _CollectionScreenState createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  String selectedBrand = 'All';

  final List<String> brands = [
    'All',
    'Tommy Hilfiger',
    'Marc Jacobs',
    'Michael Kors',
    'Guess',
    'Emporio Armani',
    'Fossil',
    'Coach',
    'Seiko',
    'Vivienne Westwood',
    'Burberry',
    'Versace',
    'Gucci',
    'Tag Heuer',
    'Omega',
  ];

  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final response = await http.get(Uri.parse('http://localhost:3000/products'));

    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> _fetchProductsByBrand(String brand) async {
    final response = brand == 'All'
        ? await http.get(Uri.parse('http://localhost:3000/products'))
        : await http.get(Uri.parse('http://localhost:3000/products/brand/$brand'));

    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, 
      child: BaseScreen(
        title: 'Collection',
        body: Column(
          children: [
            _buildBrandTabs(),
            Expanded(
              child: Container(
                color: Colors.white, 
                child: products.isEmpty
                    ? Center(child: Text('ไม่พบสินค้าตามแบรนด์ที่เลือก'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5, 
                          crossAxisSpacing: 8.0, 
                          mainAxisSpacing: 8.0, 
                          childAspectRatio: 0.95, 
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return WatchCard(
                            name: '${product['Brand']}, ${product['Serial_number']}',
                            price: product['Price'],
                            imageUrl: product['Images'], 
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(product: product),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

Widget _buildBrandTabs() {
  return Container(
    height: 60.0,
    color: Colors.white,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: brands.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ChoiceChip(
            label: Text(
              brands[index],
              style: TextStyle(
                color: selectedBrand == brands[index] ? Colors.white : Colors.black, 
              ),
            ),
            selected: selectedBrand == brands[index],
            backgroundColor: Colors.white,
            selectedColor: Colors.indigo[900],
            side: BorderSide(color: Colors.grey),
            onSelected: (selected) {
              setState(() {
                selectedBrand = brands[index];
              });
              _fetchProductsByBrand(selectedBrand);
            },
          ),
        );
      },
    ),
  );
}
}

class WatchCard extends StatelessWidget {
  final String name;
  final String price;
  final String imageUrl;
  final VoidCallback onPressed;

  WatchCard({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.onPressed,
  });

@override
Widget build(BuildContext context) {
  return Card(
    color: Colors.white,
    elevation: 6.0, 
    shadowColor: const Color.fromARGB(255, 0, 51, 102).withOpacity(0.5), 
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 200,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.error);  
              },
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            name,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[900],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.0),
          Text(
            price,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Colors.indigo[900], 
            ),
          ),
          SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.grey, 
              elevation: 0,
              side: BorderSide(color: Colors.indigo[900]!, width: 1.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              'ดูเพิ่มเติม',
              style: TextStyle(
                fontSize: 14.0,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                color: Colors.indigo[900], 
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
