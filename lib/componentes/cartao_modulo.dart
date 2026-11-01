
import 'package:flutter/material.dart';

import '../modelos/modulo.dart';
import '../modelos/permissao.dart';

const Color azulPrincipal = Color(0xFF015A84);
const Color azulClaro = Color(0xFFE8F3F8);

class CartaoModulo extends StatelessWidget {
  final Modulo modulo;
  final int quantidadePlantas;
  final VoidCallback onTap;
  final VoidCallback? onEditar;

  const CartaoModulo({
    super.key,
    required this.modulo,
    this.quantidadePlantas = 0,
    required this.onTap,
    this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    final permissao = modulo.permissao;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.04),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: azulClaro,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.memory_outlined,
                      color: azulPrincipal,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          modulo.nome,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          modulo.espId,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (onEditar != null)
                    IconButton(
                      onPressed: onEditar,
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              _construirPermissao(permissao),

              const SizedBox(height: 16),

              const Text(
                'Sensores disponíveis',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (modulo.possuiTemperatura)
                    _construirSensor(
                      Icons.thermostat,
                      'Temperatura',
                    ),

                  if (modulo.possuiUmidadeAr)
                    _construirSensor(
                      Icons.water_drop_outlined,
                      'Umidade do ar',
                    ),

                  if (modulo.possuiUmidadeSolo)
                    _construirSensor(
                      Icons.grass_outlined,
                      'Umidade do solo',
                    ),

                  if (!modulo.possuiTemperatura &&
                      !modulo.possuiUmidadeAr &&
                      !modulo.possuiUmidadeSolo)
                    const Text(
                      'Nenhum sensor configurado',
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              const Divider(),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(
                    Icons.local_florist_outlined,
                    color: azulPrincipal,
                    size: 20,
                  ),

                  const SizedBox(width: 8),

                  const Expanded(
                    child: Text(
                      'Plantas cadastradas',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  Text(
                    '$quantidadePlantas',
                    style: const TextStyle(
                      color: azulPrincipal,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(width: 8),

                  const Icon(
                    Icons.arrow_forward_ios,
                    color: azulPrincipal,
                    size: 13,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirPermissao(Permissao permissao) {
    Color cor;
    Color fundo;
    IconData icone;

    switch (permissao) {
      case Permissao.proprietario:
        cor = Colors.deepPurple;
        fundo = Colors.deepPurple.withValues(alpha: 0.08);
        icone = Icons.verified_user_outlined;
        break;

      case Permissao.compartilhado:
        cor = Colors.green.shade700;
        fundo = Colors.green.withValues(alpha: 0.08);
        icone = Icons.people_outline;
        break;

      case Permissao.visualizador:
        cor = azulPrincipal;
        fundo = azulClaro;
        icone = Icons.visibility_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 15, color: cor),
          const SizedBox(width: 6),
          Text(
            permissao.descricao,
            style: TextStyle(
              color: cor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirSensor(IconData icone, String nome) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: azulClaro,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icone,
            color: azulPrincipal,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            nome,
            style: const TextStyle(
              color: azulPrincipal,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
