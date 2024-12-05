import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'favorite.dart';
import 'detail_produk.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<dynamic> _allProducts = [];
  List<dynamic> _products = [];
  bool _isLoading = true;
  late Box<String> _favoritesBox;

  @override
  void initState() {
    super.initState();
    _favoritesBox = Hive.box<String>('favorites');
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse('https://www.amiiboapi.com/api/amiibo/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> allProducts = data['amiibo'];

        setState(() {
          _allProducts = allProducts;
          _products = allProducts;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FavoritePage(),
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _addToFavorites(String head) {
    if (!_favoritesBox.containsKey(head)) {
      _favoritesBox.put(head, head);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to favorites: $head')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Already in favorites: $head')),
      );
    }
  }

  void _filterProducts(String query) {
    final filteredProducts = _allProducts.where((product) {
      final productName = product['name'].toString().toLowerCase();
      return productName.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _products = filteredProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nintendo Amiibo List',
          style: TextStyle(
              color: Colors.white, fontFamily: 'Mobile', fontSize: 23),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 2, 47, 39),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search products...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _filterProducts,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      final imageUrl = product['image'];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailPage(head: product['head']),
                            ),
                          );
                        },
                        child: Card(
                          color: const Color.fromARGB(255, 248, 255, 246),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Color.fromARGB(255, 2, 47, 39), // Warna hijau
                              width: 2, // Ketebalan border
                            ),
                          ),
                          elevation: 3,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start, // Mengatur agar semua elemen rata atas
                            children: [
                              // Gambar Produk dengan Padding
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: imageUrl != null
                                      ? Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          width: 100, // Lebar gambar dalam card horizontal
                                          height: 100,
                                        )
                                      : const Center(
                                          child: Icon(Icons.image, size: 50),
                                        ),
                                ),
                              ),
                              // Informasi Produk dan Ikon Favorit di Samping
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start, // Mengatur agar teks rata kiri dan atas
                                    children: [
                                      Text(
                                        'ID: ${product['head']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        'Nama: ${product['name']}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        '${product['gameSeries']}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Ikon Favorit di Samping Teks dan Rata Atas
                              IconButton(
                                alignment: Alignment.topRight, // Ikon rata di atas
                                icon: const Icon(
                                  Icons.favorite,
                                  color: Colors.grey,
                                ),
                                onPressed: () =>
                                    _addToFavorites(product['head']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 248, 255, 246),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 2, 47, 39),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
