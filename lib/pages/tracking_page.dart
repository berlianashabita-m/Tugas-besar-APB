import 'package:flutter/material.dart';
import '../database/mysql_service.dart';

class TracingPage extends StatefulWidget {
  const TracingPage({super.key});

  @override
  State<TracingPage> createState() => _TracingPageState();
}

class _TracingPageState extends State<TracingPage> {
  late Future<List<Map<String, dynamic>>> _futureOrders;

  @override
  void initState() {
    super.initState();
    _futureOrders = MySqlService.getOrders(MySqlService.currentUserEmail ?? "user@gmail.com");
  }

  void _refresh() {
    setState(() {
      _futureOrders = MySqlService.getOrders(MySqlService.currentUserEmail ?? "user@gmail.com");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pelacakan Pesanan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.pink, // FIX: Ganti Pink agar serasi
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.pink));
          }
          
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(
              child: Text("Belum ada riwayat pesanan.", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final status = order['status'] ?? 'Menunggu Pembayaran';
              final List<dynamic> items = order['items'] ?? []; // Mengambil data items terstruktur dari PHP baru

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Order ID: #Sole-${order['id']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            status, 
                            style: TextStyle(
                              color: status.contains('Pending') || status == 'Menunggu Pembayaran' ? Colors.orange : Colors.green, 
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ],
                      ),
                      const Divider(),
                      
                      const Text("Rincian Produk:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 4),
                      
                      // Menampilkan list produk hasil olahan berantai PHP
                      if (items.isEmpty)
                        const Text("- Detail produk tidak ditemukan -", style: TextStyle(color: Colors.red, fontSize: 13))
                      else
                        ...items.map<Widget>((it) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text("- ${it['product_name']} (Size: ${it['size']}) x ${it['qty']}", style: const TextStyle(fontSize: 13)),
                              ),
                              Text("Rp ${it['price'] * it['qty']}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        )).toList(),
                      
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Pembayaran:", style: TextStyle(fontWeight: FontWeight.w500)),
                          Text("Rp ${order['grand_total']}", style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      
                      // Munculkan tombol simulasi bayar jika statusnya belum lunas
                      if (status.contains('Pending') || status == 'Menunggu Pembayaran') ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              bool ok = await MySqlService.updateOrderStatus(order['id'], "Diproses");
                              if (ok) {
                                _refresh();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Simulasi Pembayaran Berhasil!"), backgroundColor: Colors.pink),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                            child: const Text("BAYAR SEKARANG (SIMULASI)", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        )
                      ]
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}