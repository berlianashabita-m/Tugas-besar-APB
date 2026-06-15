import 'package:flutter/material.dart';

import '../database/mysql_service.dart';

class CheckoutPage extends StatefulWidget {
  final List<dynamic>? checkoutItems;
  final int? totalHarga;

  const CheckoutPage({
    super.key,
    this.checkoutItems,
    this.totalHarga,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedPaymentMethod = "Transfer Bank (Manual)";

  final List<String> _paymentOptions = [
    "Transfer Bank (Manual)",
    "E-Wallet (Dana/OVO/Gopay)",
    "COD (Bayar di Tempat)",
    "SoleStore Pink Pay (Simulasi)",
  ];

  int _hitungTotalBelanjaan() {
    if (widget.totalHarga != null &&
        widget.totalHarga! > 0) {
      return widget.totalHarga!;
    }

    int total = 0;

    for (var item in MySqlService.cartList) {
      int price = item['price'] ?? 0;
      int qty = item['qty'] ?? 1;

      total += price * qty;
    }

    return total;
  }

  Future<void> _prosesCheckoutKeDatabase() async {
    final listBarang =
        (widget.checkoutItems != null &&
                widget.checkoutItems!.isNotEmpty)
            ? widget.checkoutItems!
            : MySqlService.cartList;

    if (listBarang.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Barang belanjaan kosong, bro!",
          ),
        ),
      );
      return;
    }

    Map<String, dynamic> checkoutPayload = {
      "user_email":
          MySqlService.currentUserEmail ??
          "pembeli@solestore.com",
      "payment_method": _selectedPaymentMethod,
      "grand_total": _hitungTotalBelanjaan(),
      "items": listBarang.map((item) {
        return {
          "product_id": item['product_id'],
          "name": item['name'],
          "price": item['price'],
          "size": item['size'],
          "qty": item['qty'],
        };
      }).toList(),
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Colors.pink,
        ),
      ),
    );

    bool sukses =
        await MySqlService.checkoutOrderComplex(
      checkoutPayload,
    );

    Navigator.pop(context);

    if (sukses) {
      setState(() {
        MySqlService.cartList.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Pesanan Berhasil! Stok otomatis terpotong di DB.",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.pink,
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Gagal mengirim data checkout ke Laragon!",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final listBelanjaan =
        (widget.checkoutItems != null &&
                widget.checkoutItems!.isNotEmpty)
            ? widget.checkoutItems!
            : MySqlService.cartList;

    final totalBayar = _hitungTotalBelanjaan();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Konfirmasi Pesanan",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: listBelanjaan.isEmpty
          ? const Center(
              child: Text(
                "Tidak ada produk untuk checkout.",
              ),
            )
          : Column(
              children: [
                Expanded(
                  flex: 3,
                  child: ListView.builder(
                    itemCount: listBelanjaan.length,
                    itemBuilder: (context, index) {
                      final item =
                          listBelanjaan[index];

                      return Card(
                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.check_box,
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
                            "Size/Ukuran: ${item['size']} | Jumlah: x${item['qty']}",
                          ),
                          trailing: Text(
                            "Rp ${item['price'] * item['qty']}",
                            style: const TextStyle(
                              color: Colors.pink,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Divider(
                  thickness: 1.5,
                ),

                Padding(
                  padding:
                      const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Metode Pembayaran (Formalitas Proyek):",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.pink,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            8,
                          ),
                        ),
                        child:
                            DropdownButtonHideUnderline(
                          child:
                              DropdownButton<String>(
                            value:
                                _selectedPaymentMethod,
                            isExpanded: true,
                            items:
                                _paymentOptions.map(
                              (value) {
                                return DropdownMenuItem<
                                    String>(
                                  value: value,
                                  child: Text(
                                    value,
                                  ),
                                );
                              },
                            ).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentMethod =
                                    value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.all(16),
                  color: Colors.pink[50],
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            const Text(
                              "Total Pembayaran:",
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              "Rp $totalBayar",
                              style:
                                  const TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                                color: Colors.pink,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed:
                              _prosesCheckoutKeDatabase,
                          icon: const Icon(
                            Icons
                                .shopping_bag_rounded,
                          ),
                          label: const Text(
                            "Buat Pesanan",
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.pink,
                            foregroundColor:
                                Colors.white,
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}