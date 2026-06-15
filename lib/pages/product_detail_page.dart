import 'package:flutter/material.dart';

import '../database/mysql_service.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailPage> createState() =>
      _ProductDetailPageState();
}

class _ProductDetailPageState
    extends State<ProductDetailPage> {
  Map<String, dynamic>? _selectedSizeData;

  @override
  Widget build(BuildContext context) {
    final String? imageName =
        widget.product['image_url'];

    final String imageUrl =
        (imageName != null &&
                imageName.isNotEmpty &&
                imageName != '-')
            ? "${MySqlService.baseUrl}/uploads/$imageName"
            : "";

    final List<dynamic> sizes =
        widget.product['sizes'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product['name'] ??
              'Detail Produk',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Gambar Produk
            Container(
              width: double.infinity,
              height: 320,
              color: Colors.grey[100],
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error,
                              stackTrace) {
                        return const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.pink,
                        );
                      },
                    )
                  : const Icon(
                      Icons.shopping_bag,
                      size: 120,
                      color: Colors.pink,
                    ),
            ),

            Padding(
              padding:
                  const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // Nama Produk
                  Text(
                    widget.product['name'] ??
                        'Sepatu Casual',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Harga
                  Text(
                    "Rp ${widget.product['price']}",
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.pink,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const Divider(
                    height: 30,
                    thickness: 1,
                  ),

                  // Pilih Ukuran
                  const Text(
                    "Pilih Ukuran Sepatu:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  sizes.isEmpty
                      ? const Padding(
                          padding:
                              EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          child: Text(
                            "Waduh, stok ukuran belum di-input oleh admin.",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        )
                      : Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children:
                              sizes.map<Widget>(
                            (sz) {
                              final int stokUkuran =
                                  sz['stock'] ??
                                      0;

                              final bool
                                  isSelected =
                                  _selectedSizeData?[
                                          'size_id'] ==
                                      sz[
                                          'size_id'];

                              final bool
                                  isAvailable =
                                  stokUkuran >
                                      0;

                              return ChoiceChip(
                                label: Text(
                                  "Size ${sz['size']} (Stok: $stokUkuran)",
                                ),
                                selected:
                                    isSelected,
                                onSelected:
                                    isAvailable
                                        ? (
                                            selected,
                                          ) {
                                            setState(
                                              () {
                                                _selectedSizeData =
                                                    selected
                                                        ? sz
                                                        : null;
                                              },
                                            );
                                          }
                                        : null,
                                selectedColor:
                                    Colors.pink,
                                backgroundColor:
                                    Colors.white,
                                disabledColor:
                                    Colors.grey[
                                        200],
                                labelStyle:
                                    TextStyle(
                                  color:
                                      isSelected
                                          ? Colors
                                              .white
                                          : (isAvailable
                                              ? Colors
                                                  .black
                                              : Colors.grey[
                                                  500]),
                                  fontWeight:
                                      isSelected
                                          ? FontWeight
                                              .bold
                                          : FontWeight
                                              .normal,
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  side:
                                      BorderSide(
                                    color:
                                        isSelected
                                            ? Colors
                                                .pink
                                            : Colors.grey[
                                                300]!,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    8,
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        ),

                  const Divider(
                    height: 40,
                    thickness: 1,
                  ),

                  // Deskripsi
                  const Text(
                    "Deskripsi Produk:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Sepatu sneakers kualitas premium dengan desain kekinian. Sangat empuk, tahan lama, anti-slip, dan cocok banget dipakai kuliah, kerja, ataupun nongkrong santai.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Tombol Keranjang
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(
                0.1,
              ),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed:
              _selectedSizeData == null
                  ? null
                  : () {
                      int existingIndex =
                          MySqlService
                              .cartList
                              .indexWhere(
                        (element) =>
                            element[
                                'product_id'] ==
                            widget
                                .product['id'] &&
                            element[
                                'size'] ==
                                _selectedSizeData![
                                    'size'],
                      );

                      if (existingIndex >= 0) {
                        MySqlService
                                .cartList[
                            existingIndex]['qty'] += 1;
                      } else {
                        MySqlService.cartList
                            .add({
                          "product_id":
                              widget
                                  .product['id'],
                          "name":
                              widget.product['name'],
                          "price":
                              widget.product['price'],
                          "size":
                              _selectedSizeData![
                                  'size'],
                          "qty": 1,
                        });
                      }

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Mantap! ${widget.product['name']} (Size ${_selectedSizeData!['size']}) masuk ke keranjang!",
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .w500,
                            ),
                          ),
                          backgroundColor:
                              Colors.pink,
                          behavior:
                              SnackBarBehavior
                                  .floating,
                        ),
                      );
                    },
          style:
              ElevatedButton.styleFrom(
            minimumSize:
                const Size.fromHeight(
              50,
            ),
            backgroundColor:
                Colors.pink,
            foregroundColor:
                Colors.white,
            disabledBackgroundColor:
                Colors.grey[300],
            disabledForegroundColor:
                Colors.grey[500],
            elevation: 0,
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),
          ),
          child: const Text(
            "MASUKKAN KERANJANG",
            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}