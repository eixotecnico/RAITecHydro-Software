import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final String imagePath;
  final String text;
  final Widget destino;

  const MenuButton({
    super.key,
    required this.imagePath,
    required this.text,
    required this.destino,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF016A9B),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destino),
          );
        },
        child: Row(
          children: [
            Image.asset(imagePath, height: 28, width: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }
}