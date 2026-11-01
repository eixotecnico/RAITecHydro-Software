
import 'package:flutter/material.dart';

import '../modelos/planta.dart';

const Color azulPrincipal = Color(0xFF015A84);
const Color azulClaro = Color(0xFFE8F3F8);

class CartaoPlanta extends StatelessWidget {
  final Planta planta;
  final VoidCallback onTap;
  final VoidCallback? onEditar;

  const CartaoPlanta({
    super.key,
    required this.planta,
    required this.onTap,
    this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.04),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              _construirImagem(),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planta.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      planta.especie,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),

                    if (planta.descricao != null &&
                        planta.descricao!.trim().isNotEmpty) ...[
                      const SizedBox(height: 7),

                      Text(
                        planta.descricao!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black45,
                          height: 1.4,
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    const Row(
                      children: [
                        Icon(
                          Icons.sensors_outlined,
                          color: azulPrincipal,
                          size: 14,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Monitoramento disponível',
                          style: TextStyle(
                            color: azulPrincipal,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 5),

              if (onEditar != null)
                IconButton(
                  onPressed: onEditar,
                  tooltip: 'Editar planta',
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.black54,
                    size: 20,
                  ),
                )
              else
                const Icon(
                  Icons.arrow_forward_ios,
                  color: azulPrincipal,
                  size: 15,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirImagem() {
    final imagemUrl = planta.imagemUrl;

    if (imagemUrl != null && imagemUrl.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Image.network(
          imagemUrl,
          width: 75,
          height: 75,
          fit: BoxFit.cover,
          errorBuilder: (context, erro, stackTrace) {
            return _construirImagemPadrao();
          },
        ),
      );
    }

    return _construirImagemPadrao();
  }

  Widget _construirImagemPadrao() {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: azulClaro,
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Icon(
        Icons.local_florist_outlined,
        color: azulPrincipal,
        size: 38,
      ),
    );
  }
}
