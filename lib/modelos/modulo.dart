import 'permissao.dart';

class Modulo {
  final String espId;
  final String nome;
  final String proprietarioId;
  final Permissao permissao;
  final bool ativo;
  final bool possuiTemperatura;
  final bool possuiUmidadeAr;
  final bool possuiUmidadeSolo;
  final DateTime? dataCadastro;
  final DateTime? dataVinculacao;

  Modulo({
    required this.espId,
    required this.nome,
    required this.proprietarioId,
    required this.permissao,
    this.ativo = true,
    this.possuiTemperatura = false,
    this.possuiUmidadeAr = false,
    this.possuiUmidadeSolo = true,
    this.dataCadastro,
    this.dataVinculacao,
  });

  factory Modulo.fromMap({
    required String espId,
    required Map<String, dynamic> dadosModulo,
    required Map<String, dynamic> dadosVinculo,
  }) {
    final sensores =
        dadosModulo['sensores'] as Map<String, dynamic>? ?? {};

    return Modulo(
      espId: espId,
      nome: dadosVinculo['nome'] as String? ?? 'Meu módulo',
      proprietarioId:
          dadosModulo['proprietarioId'] as String? ?? '',
      permissao: Permissao.deString(
        dadosVinculo['permissao'] as String?,
      ),
      ativo: dadosModulo['ativo'] as bool? ?? true,
      possuiTemperatura:
          sensores['temperatura'] as bool? ?? false,
      possuiUmidadeAr:
          sensores['umidadeAr'] as bool? ?? false,
      possuiUmidadeSolo:
          sensores['umidadeSolo'] as bool? ?? false,
      dataCadastro:
          (dadosModulo['dataCadastro'] as dynamic)?.toDate(),
      dataVinculacao:
          (dadosVinculo['dataVinculacao'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> paraMap() {
    return {
      'nome': nome,
      'permissao': permissao.valor,
      'dataVinculacao': dataVinculacao,
    };
  }
}