import 'package:flutter/material.dart';

import '../database/mysql_service.dart';
import 'cart_page.dart';
import 'login_page.dart';
import 'product_detail_page.dart';
import 'tracking_page.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() =>
      _ProductPageState();
}

class _ProductPageState
    extends State<ProductPage> {
  late Future<List<Map<String, dynamic>>>
      _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts =
        MySqlService.getProducts();
  }

  void _refreshData() {
    setState(() {
      _futureProducts =
          MySqlService.getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SoleStore Catalog",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
            ),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(
              Icons.local_shipping,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const TracingPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.shopping_cart,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const CartPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.logout,
            ),
            onPressed: () {
              MySqlService
                  .currentUserEmail = null;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<
          List<Map<String, dynamic>>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(
                color: Colors.pink,
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Terjadi kesalahan saat mengambil data produk",
              ),
            );
          }

          final products =
              snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada produk tersedia",
              ),
            );
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder:
                (context, index) {
              final item = products[index];

              return Card(
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.shopping_bag,
                    color: Colors.pink,
                  ),
                  title: Text(
                    item['name'] ?? 'Sepatu',
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Rp ${item['price']}",
                    style: const TextStyle(
                      color: Colors.pink,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.pink,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailPage(
                          product: item,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}