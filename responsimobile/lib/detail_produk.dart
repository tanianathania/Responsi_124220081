import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class ProductDetailPage extends StatefulWidget {
  final String head;

  const ProductDetailPage({Key? key, required this.head}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Map<String, dynamic> product;
  bool _isLoading = true;
  late Box<String> _favoritesBox;

  @override
  void initState() {
    super.initState();
    _favoritesBox = Hive.box<String>('favorites');
    fetchProductDetails();
  }

  Future<void> fetchProductDetails() async {
    final url = Uri.parse('https://www.amiiboapi.com/api/amiibo/?head=${widget.head}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          product = data['amiibo'][0];
          _isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat detail produk');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  void _addToFavorites(String head) {
    if (!_favoritesBox.containsKey(head)) {
      _favoritesBox.put(head, head);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ditambahkan ke favorit: $head')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sudah ada di favorit: $head')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isLoading ? "Detail" : "${product['name'] ?? "'s Detail"}'s Detail",
          style: const TextStyle(color: Colors.white, fontFamily: 'Mobile', fontSize: 23),
        ),
        iconTheme: const IconThemeData(color: Colors.white), 
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 2, 47, 39),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            color: Colors.white,
            onPressed: () => _addToFavorites(product['head']),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ?? 'Nama Produk',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (product['image'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product['image'],
                          width: MediaQuery.of(context).size.width - 32, // Sesuaikan lebar device
                          
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      const Center(child: Icon(Icons.image, size: 100)),

                    const SizedBox(height: 16),   
                    Row(
                      children: [
                        const Text(
                          'Amiibo Series: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Spacer(),
                        Text(
                          '${product['amiiboSeries']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Character: ',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Spacer(),
                        Text(
                          '${product['character']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Game Series: ',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Spacer(),
                        Text(
                          '${product['gameSeries']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Type: ',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Spacer(),
                        Text(
                          '${product['type']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Release Dates:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(
                      color: Colors.black38, // Warna garis tipis
                      thickness: 0.5, // Ketebalan garis
                      indent: 0, // Jarak dari kiri
                      endIndent: 0, // Jarak dari kanan
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('Australia: '),
                        Spacer(),
                        Text('${product['release']?['au'] ?? 'Tidak tersedia'}'),    
                      ],
                    ),
                    Row(
                      children: [
                        Text('Europe: '),
                        Spacer(),
                        Text('${product['release']?['eu'] ?? 'Tidak tersedia'}'),    
                      ],
                    ),
                    Row(
                      children: [
                        Text('Japan: '),
                        Spacer(),
                        Text('${product['release']?['jp'] ?? 'Tidak tersedia'}'),    
                      ],
                    ),
                    Row(
                      children: [
                        Text('North America: '),
                        Spacer(),
                        Text('${product['release']?['na'] ?? 'Tidak tersedia'}'),    
                      ],
                    ),                    
                  ],
                ),
              ),
            ),
    );
  }
}
