import 'package:flutter/material.dart';

import '../database/mysql_service.dart';
import 'product_page.dart';
import 'add_product_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoginView = true;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // DIUBAH: Default role disesuaikan murni ke 'pembeli'
  String _selectedRole = "pembeli";

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Email dan Password tidak boleh kosong!",
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    if (_isLoginView) {
      // LOGIN
      var res = await MySqlService.loginUser(
        email,
        password,
      );

      setState(() {
        _isLoading = false;
      });

      if (res['status'] == 'success') {
        // Simpan session user global di memory Flutter
        MySqlService.currentUserEmail = res['email'];
        MySqlService.currentUserRole = res['role'];

        // DIUBAH: Jika role yang kembali dari database adalah 'pemilik'
        if (res['role'] == 'pemilik') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProductPage(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ProductPage(),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res['message'] ?? "Login Gagal",
            ),
          ),
        );
      }
    } else {
      // REGISTER
      if (name.isEmpty) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Nama lengkap wajib diisi saat daftar!",
            ),
          ),
        );
        return;
      }

      var res = await MySqlService.registerUser(
        email,
        password,
        name,
        phone,
        _selectedRole, // Mengirim data murni 'pembeli' atau 'pemilik'
      );

      setState(() {
        _isLoading = false;
      });

      if (res['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Registrasi Sukses! Silakan login.",
            ),
            backgroundColor: Colors.pink,
          ),
        );

        setState(() {
          _isLoginView = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res['message'] ?? "Registrasi Gagal",
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isLoginView ? "SoleStore Login" : "SoleStore Register",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shopping_bag,
                  size: 80,
                  color: Colors.pink,
                ),

                const SizedBox(height: 20),

                // FIELD REGISTER
                if (!_isLoginView) ...[
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Nama Lengkap",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.pink,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Nomor WhatsApp/HP",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(
                        Icons.phone,
                        color: Colors.pink,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],

                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email Address",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.pink,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.pink,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: "Daftar/Login Sebagai",
                    border: OutlineInputBorder(),
                  ),
                  // DIUBAH: value di bawah disamakan dengan struktur enum MySQL murni kamu
                  items: const [
                    DropdownMenuItem(
                      value: "pembeli",
                      child: Text(
                        "Pembeli (User)",
                      ),
                    ),
                    DropdownMenuItem(
                      value: "pemilik",
                      child: Text(
                        "Pemilik (Admin)",
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value ?? "pembeli";
                    });
                  },
                ),

                const SizedBox(height: 24),

                _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.pink,
                      )
                    : ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(
                            50,
                          ),
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          _isLoginView ? "LOGIN" : "DAFTAR AKUN BARU",
                        ),
                      ),

                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLoginView = !_isLoginView;
                    });
                  },
                  child: Text(
                    _isLoginView
                        ? "Belum punya akun? Daftar di sini"
                        : "Sudah punya akun? Login di sini",
                    style: const TextStyle(
                      color: Colors.pink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}