import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pop(context);
    }
  }

  List<dynamic> _favoritesData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    final favoritesBox = Hive.box<String>('favorites');
    final favoriteHeads = favoritesBox.values.toList();

    try {
      List<dynamic> favoritesData = [];
      for (var head in favoriteHeads) {
        final url = Uri.parse('https://www.amiiboapi.com/api/amiibo/?head=$head');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          if (data['amiibo'] != null) {
            favoritesData.add(data['amiibo'][0]);
          }
        }
      }

      setState(() {
        _favoritesData = favoritesData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  Future<void> _removeFavorite(String head) async {
    final favoritesBox = Hive.box<String>('favorites');
    await favoritesBox.delete(head);

    // Temukan produk yang sesuai dengan 'head' dan dapatkan nama produk
    final productToRemove = _favoritesData.firstWhere(
      (product) => product['head'] == head,
      orElse: () => {}, // Jika tidak ditemukan, kembalikan objek kosong
    );

    setState(() {
      _favoritesData.removeWhere((product) => product['head'] == head);
    });

    // Menampilkan SnackBar dengan nama produk yang dihapus
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${productToRemove['name']} removed from favorites')),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites', style: TextStyle(color: Colors.white, fontFamily: 'Mobile', fontSize: 23)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 2, 47, 39),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoritesData.isEmpty
              ? const Center(
                  child: Text(
                    'Favorite masih kosong',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _favoritesData.length,
                  itemBuilder: (context, index) {
                    final product = _favoritesData[index];
                    final imageUrl = product['image'];

                    return Dismissible(
                      key: Key(product['head']),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        _removeFavorite(product['head']);
                      },
                      background: Container(
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white, size: 40),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                      ),
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
                          crossAxisAlignment: CrossAxisAlignment.start, // Agar semua elemen rata atas
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
                                    vertical: 4.0, horizontal: 8.0),
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
                              onPressed: () => _removeFavorite(product['head']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
