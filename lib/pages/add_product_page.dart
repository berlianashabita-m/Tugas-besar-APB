import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database/mysql_service.dart';
import 'admin_orders_page.dart';
import 'login_page.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  late Future<List<Map<String, dynamic>>> _futureProducts;
  
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _initSizeController = TextEditingController();
  final _initStockController = TextEditingController();
  
  final _sizeNumberController = TextEditingController();
  final _sizeStockController = TextEditingController();
  
  File? _imageFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _futureProducts = MySqlService.getProducts();
  }

  void _refreshData() {
    setState(() {
      _futureProducts = MySqlService.getProducts();
    });
  }

  void _pickImage(StateSetter setDialogState) async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file != null) {
      setDialogState(() {
        _imageFile = File(file.path);
      });
    }
  }

  void _clearForm() {
    _nameController.clear();
    _priceController.clear();
    _initSizeController.clear();
    _initStockController.clear();
    setState(() {
      _imageFile = null;
    });
  }

  // C - CREATE PRODUK MASTER
  void _saveNewProductMaster(StateSetter setDialogState) async {
    final name = _nameController.text.trim();
    final price = int.tryParse(_priceController.text.trim()) ?? 0;
    final size = int.tryParse(_initSizeController.text.trim()) ?? 0;
    final stock = int.tryParse(_initStockController.text.trim()) ?? 0;

    if (name.isEmpty || price <= 0 || size <= 0 || stock < 0 || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua kolom dan Foto Sepatu Wajib diisi!")),
      );
      return;
    }

    setDialogState(() { _isUploading = true; });
    int? newProductId = await MySqlService.addProductMaster(name, price, _imageFile!.path);
    
    if (newProductId != null) {
      await MySqlService.addSizeToProduct(newProductId, size, stock);
      setDialogState(() { _isUploading = false; });
      Navigator.pop(context);
      _clearForm();
      _refreshData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sepatu baru berhasil ditambahkan!"), backgroundColor: Colors.pink),
      );
    } else {
      setDialogState(() { _isUploading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengupload produk ke server.")),
      );
    }
  }

  // U - UPDATE PRODUK MASTER
  void _showEditProductDialog(Map<String, dynamic> product) {
    _nameController.text = product['name'] ?? '';
    _priceController.text = (product['price'] ?? 0).toString();
    _imageFile = null; 

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Data Sepatu", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _pickImage(setDialogState),
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.pink, width: 1),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(_imageFile!, fit: BoxFit.cover))
                            : const Icon(Icons.add_a_photo, size: 30, color: Colors.pink),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text("*Kosongkan jika tidak ingin ganti foto", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Nama Sepatu", border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: _priceController, decoration: const InputDecoration(labelText: "Harga (Rp)", border: OutlineInputBorder()), keyboardType: TextInputType.number),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () { Navigator.pop(context); _clearForm(); }, child: const Text("Batal")),
                _isUploading
                    ? const CircularProgressIndicator(color: Colors.pink)
                    : ElevatedButton(
                        onPressed: () async {
                          final edtName = _nameController.text.trim();
                          final edtPrice = int.tryParse(_priceController.text.trim()) ?? 0;

                          if (edtName.isEmpty || edtPrice <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nama dan Harga harus valid!")));
                            return;
                          }

                          setDialogState(() { _isUploading = true; });
                          bool ok = await MySqlService.editProductMaster(
                            product['id'], 
                            edtName, 
                            edtPrice, 
                            _imageFile?.path ?? ""
                          );
                          setDialogState(() { _isUploading = false; });
                          
                          if (ok) {
                            Navigator.pop(context);
                            _clearForm();
                            _refreshData();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sepatu berhasil diperbarui!"), backgroundColor: Colors.pink));
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white),
                        child: const Text("Simpan Perubahan"),
                      )
              ],
            );
          },
        );
      },
    );
  }

  // CRUD UKURAN: C - CREATE / U - UPDATE UKURAN LENGKAP
  void _showAddOrEditSizeDialog(int productId, {Map<String, dynamic>? existingSize}) {
    if (existingSize != null) {
      _sizeNumberController.text = (existingSize['size'] ?? 0).toString();
      _sizeStockController.text = (existingSize['stock'] ?? 0).toString();
    } else {
      _sizeNumberController.clear();
      _sizeStockController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingSize == null ? "Tambah Ukuran" : "Edit Stok & Ukuran", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pink)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _sizeNumberController, 
              decoration: const InputDecoration(labelText: "Nomor Ukuran (Misal: 40)", border: OutlineInputBorder()), 
              keyboardType: TextInputType.number,
              enabled: existingSize == null, // Jika edit, nomor ukurannya di-lock aja biar aman
            ),
            const SizedBox(height: 12),
            TextField(controller: _sizeStockController, decoration: const InputDecoration(labelText: "Jumlah Stok", border: OutlineInputBorder()), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          // CRUD UKURAN: D - DELETE (HANYA MUNCUL PAS MODE EDIT)
          if (existingSize != null)
            TextButton(
              onPressed: () async {
                bool ok = await MySqlService.deleteProductSize(existingSize['size_id']);
                if (ok) {
                  Navigator.pop(context);
                  _refreshData();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Variasi Ukuran Berhasil Dihapus!"), backgroundColor: Colors.red));
                }
              },
              child: const Text("Hapus Ukuran", style: TextStyle(color: Colors.red)),
            ),
          ElevatedButton(
            onPressed: () async {
              int sz = int.tryParse(_sizeNumberController.text) ?? 0;
              int stk = int.tryParse(_sizeStockController.text) ?? 0;
              if (sz > 0 && stk >= 0) {
                if (existingSize == null) {
                  // Tambah baru
                  await MySqlService.addSizeToProduct(productId, sz, stk);
                } else {
                  // Edit stok yang sudah ada
                  await MySqlService.updateSizeStock(existingSize['size_id'], stk);
                }
                Navigator.pop(context);
                _refreshData();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white),
            child: Text(existingSize == null ? "Tambah" : "Simpan"),
          )
        ],
      ),
    );
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Tambah Sepatu Baru", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _pickImage(setDialogState),
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.pink, width: 1),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(_imageFile!, fit: BoxFit.cover))
                            : const Icon(Icons.add_a_photo, size: 30, color: Colors.pink),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Nama Sepatu", border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: _priceController, decoration: const InputDecoration(labelText: "Harga (Rp)", border: OutlineInputBorder()), keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _initSizeController, decoration: const InputDecoration(labelText: "Size", border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: _initStockController, decoration: const InputDecoration(labelText: "Stok", border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                _isUploading
                    ? const CircularProgressIndicator(color: Colors.pink)
                    : ElevatedButton(
                        onPressed: () => _saveNewProductMaster(setDialogState),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white),
                        child: const Text("Simpan Sepatu"),
                      ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin: Toko Pink Merona", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
          IconButton(icon: const Icon(Icons.list_alt), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminOrdersPage()))),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LoginPage()))),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.pink));
          final products = snapshot.data ?? [];
          if (products.isEmpty) return const Center(child: Text("Katalog Kosong. Klik + untuk tambah sepatu baru."));

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final item = products[index];
              List<dynamic> sizes = item['sizes'] ?? [];
              final String? imageName = item['image_url'];
              final String imageUrl = (imageName != null && imageName.isNotEmpty && imageName != '-')
                  ? "${MySqlService.baseUrl}/uploads/$imageName" : "";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6)),
                            child: imageUrl.isNotEmpty
                                ? ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image)))
                                : const Icon(Icons.shopping_bag, color: Colors.pink),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text("Harga: Rp ${item['price']}", style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showEditProductDialog(item)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red), 
                            onPressed: () async {
                              bool confirmed = await showDialog(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text("Hapus Sepatu?"),
                                  content: const Text("Apakah kamu yakin ingin menghapus produk ini beserta seluruh variasi stok ukurannya?"),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Batal")),
                                    TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
                                  ],
                                )
                              ) ?? false;
                              
                              if (confirmed) {
                                bool ok = await MySqlService.deleteProduct(item['id']);
                                if(ok) _refreshData();
                              }
                            }
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text("Variasi Ukuran (Klik +1 Stok / Tahan lama untuk CRUD Kelola):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: sizes.map<Widget>((sz) {
                          return GestureDetector(
                            onLongPress: () => _showAddOrEditSizeDialog(item['id'], existingSize: sz), // Tahan lama buat edit/hapus ukuran
                            child: Chip(
                              label: Text("Size ${sz['size']} [${sz['stock']}]"),
                              onDeleted: () async {
                                // MODIFIKASI: Sekali klik nambah +1 stok
                                await MySqlService.updateSizeStock(sz['size_id'], (sz['stock'] as int) + 1);
                                _refreshData();
                              },
                              deleteIcon: const Icon(Icons.add_circle, color: Colors.green, size: 18),
                            ),
                          );
                        }).toList(),
                      ),
                      TextButton.icon(
                        onPressed: () => _showAddOrEditSizeDialog(item['id']),
                        icon: const Icon(Icons.add, size: 16, color: Colors.pink),
                        label: const Text("Tambah Varian Ukuran Baru", style: TextStyle(color: Colors.pink, fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showAddProductDialog, backgroundColor: Colors.pink, foregroundColor: Colors.white, child: const Icon(Icons.add)),
    );
  }
}