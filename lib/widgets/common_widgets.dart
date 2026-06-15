import 'package:flutter/material.dart';

const Color primaryPink = Color(0xFFE91E63);
const Color darkPink = Color(0xFFC2185B);
const Color lightPink = Color(0xFFFCE4EC);

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.shopping_bag_outlined, size: 80, color: primaryPink),
        SizedBox(height: 10),
        Text(
          "SoleStore",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: primaryPink,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

Widget inputField(TextEditingController controller, String label, {bool obscure = false}) {
  return TextField(
    controller: controller,
    obscureText: obscure,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: lightPink,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryPink, width: 2),
      ),
    ),
  );
}