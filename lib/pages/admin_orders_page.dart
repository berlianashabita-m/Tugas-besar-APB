import 'package:flutter/material.dart';
import '../database/mysql_service.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  late Future<List<Map<String, dynamic>>> _futureAdminOrders;

  @override
  void initState() {
    super.initState();
    // Admin menarik semua data order (tanpa filter email)
    _futureAdminOrders = MySqlService.getOrders(""); 
  }

  void _refresh() {
    setState(() {
      _futureAdminOrders = MySqlService.getOrders("");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel Kelola Pesanan (Admin)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureAdminOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.pink));
          }

          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(
              child: Text("Belum ada pesanan masuk dari pembeli.", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final status = order['status'] ?? 'Pending';
              final List<dynamic> items = order['items'] ?? []; // FIX: Sekarang membaca rincian dari PHP baru

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card Order
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Order ID: #Sole-${order['id']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: status.contains('Selesai') ? Colors.green[50] : Colors.orange[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: status.contains('Selesai') ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("Pembeli: ${order['user_email']}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      const Divider(thickness: 1),

                      // Bagian Rincian Produk Yang Dibeli
                      const Text("Rincian Produk Belanjaan:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.pink)),
                      const SizedBox(height: 6),
                      if (items.isEmpty)
                        const Text("- Tidak ada rincian item (Data lama rusak) -", style: TextStyle(color: Colors.red, fontSize: 13))
                      else
                        ...items.map<Widget>((it) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text("• ${it['product_name']} (Size: ${it['size']}) x${it['qty']}", style: const TextStyle(fontSize: 13)),
                              ),
                              Text("Rp ${it['price'] * it['qty']}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )).toList(),

                      const Divider(thickness: 1),
                      
                      // Total Pembayaran
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Grand Total:", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Rp ${order['grand_total']}", style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Menu Aksi Pengubah Status oleh Admin
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              // Simulasi memperbarui status pesanan menjadi Selesai / Dikirim
                              bool ok = await MySqlService.updateOrderStatus(order['id'], "Selesai (Dikirim Admin)");
                              if (ok) {
                                _refresh();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Status pesanan berhasil diperbarui ke Selesai!"), backgroundColor: Colors.green),
                                );
                              }
                            },
                            icon: const Icon(Icons.check_circle_outline, size: 18),
                            label: const Text("SELESAIKAN ORDERAN", style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                        ],
                      ),
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