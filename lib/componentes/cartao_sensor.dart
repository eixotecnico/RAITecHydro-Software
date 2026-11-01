import 'package:flutter/material.dart';

const Color azulSensor = Color(0xFF015A84);

class CartaoSensor extends StatelessWidget {
  final String titulo;
  final String valor;
  final String unidade;
  final IconData icone;
  final Color? cor;
  final String? descricao;

  const CartaoSensor({
    super.key,
    required this.titulo,
    required this.valor,
    required this.unidade,
    required this.icone,
    this.cor,
    this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    final corPrincipal = cor ?? azulSensor;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: corPrincipal.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icone,
                  color: corPrincipal,
                  size: 23,
                ),
              ),

              const Spacer(),

              const Icon(
                Icons.circle,
                color: Colors.green,
                size: 9,
              ),

              const SizedBox(width: 5),

              const Text(
                'Monitorando',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Text(
            titulo,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 7),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  valor,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: corPrincipal,
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              if (unidade.isNotEmpty) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    unidade,
                    style: TextStyle(
                      color: corPrincipal,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),

          if (descricao != null) ...[
            const SizedBox(height: 7),
            Text(
              descricao!,
              style: const TextStyle(
                color: Colors.black45,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}