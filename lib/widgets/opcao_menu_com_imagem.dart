import 'package:flutter/material.dart';

class OpcaoMenuComImagem extends StatelessWidget {
  final String texto;
  final List<String> imagens;
  final Widget destino;

  const OpcaoMenuComImagem({
    super.key,
    required this.texto,
    required this.imagens,
    required this.destino,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF016A9B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: imagens.map((path) => Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Image.asset(path, height: 24, width: 24),
          )).toList(),
        ),
        title: Text(texto, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => destino));
        },
      ),
    );
  }
}