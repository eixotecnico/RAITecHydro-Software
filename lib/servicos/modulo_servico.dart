
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../modelos/modulo.dart';

class ModuloServico {
  final FirebaseFirestore _banco = FirebaseFirestore.instance;
  final FirebaseAuth _autenticacao = FirebaseAuth.instance;

  /// Retorna os módulos vinculados ao usuário autenticado.
  Future<List<Modulo>> listarModulos() async {
    final usuario = _autenticacao.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    final vinculos = await _banco
        .collection('usuarios')
        .doc(usuario.uid)
        .collection('modulos')
        .get();

    final List<Modulo> resultado = [];

    for (final vinculo in vinculos.docs) {
      final documentoModulo = await _banco
          .collection('modulos')
          .doc(vinculo.id)
          .get();

      if (!documentoModulo.exists) continue;

      final dadosModulo = documentoModulo.data();

      if (dadosModulo == null) continue;

      resultado.add(
        Modulo.fromMap(
          espId: documentoModulo.id,
          dadosModulo: dadosModulo,
          dadosVinculo: vinculo.data(),
        ),
      );
    }

    return resultado;
  }

  /// Recupera um módulo específico vinculado ao usuário.
  Future<Modulo?> buscarModulo(String espId) async {
    final usuario = _autenticacao.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    final vinculo = await _banco
        .collection('usuarios')
        .doc(usuario.uid)
        .collection('modulos')
        .doc(espId)
        .get();

    if (!vinculo.exists) return null;

    final documentoModulo = await _banco
        .collection('modulos')
        .doc(espId)
        .get();

    if (!documentoModulo.exists) return null;

    final dadosModulo = documentoModulo.data();
    final dadosVinculo = vinculo.data();

    if (dadosModulo == null || dadosVinculo == null) {
      return null;
    }

    return Modulo.fromMap(
      espId: espId,
      dadosModulo: dadosModulo,
      dadosVinculo: dadosVinculo,
    );
  }

  /// Cadastra um novo ESP32.
  ///
  /// O primeiro usuário a cadastrar um ESP ID inexistente
  /// será definido como proprietário.
  ///
  /// O cadastro grava:
  /// - Documento principal do módulo.
  /// - Permissão do proprietário.
  /// - Vínculo do módulo com o usuário.
  ///
  /// As três gravações acontecem na mesma transação.
  Future<void> cadastrarModulo({
    required String espId,
    required String nome,
    required bool possuiTemperatura,
    required bool possuiUmidadeAr,
    required bool possuiUmidadeSolo,
  }) async {
    final usuario = _autenticacao.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    final identificador = espId.trim().toUpperCase();
    final nomePersonalizado = nome.trim();

    if (identificador.isEmpty) {
      throw Exception('Informe o ID do ESP32.');
    }

    if (nomePersonalizado.isEmpty) {
      throw Exception('Informe um nome para o módulo.');
    }

    if (!possuiTemperatura &&
        !possuiUmidadeAr &&
        !possuiUmidadeSolo) {
      throw Exception(
        'Selecione pelo menos um sensor disponível.',
      );
    }

    final referenciaModulo = _banco
        .collection('modulos')
        .doc(identificador);

    final referenciaUsuario = _banco
        .collection('usuarios')
        .doc(usuario.uid);

    final referenciaVinculo = referenciaUsuario
        .collection('modulos')
        .doc(identificador);

    final referenciaAutorizacao = referenciaModulo
        .collection('usuariosAutorizados')
        .doc(usuario.uid);

    await _banco.runTransaction((transacao) async {
      // Verifica se o ESP32 já possui cadastro.
      final documentoExistente =
          await transacao.get(referenciaModulo);

      if (documentoExistente.exists) {
        throw Exception(
          'Este ESP32 já está cadastrado. '
          'Não é possível assumir a propriedade de um módulo existente.',
        );
      }

      final dataAtual = FieldValue.serverTimestamp();

      // 1. Cria o documento principal do módulo.
      transacao.set(referenciaModulo, {
        'espId': identificador,
        'proprietarioId': usuario.uid,
        'dataCadastro': dataAtual,
        'ativo': true,
        'sensores': {
          'temperatura': possuiTemperatura,
          'umidadeAr': possuiUmidadeAr,
          'umidadeSolo': possuiUmidadeSolo,
        },
      });

      // 2. Registra o usuário como proprietário autorizado.
      transacao.set(referenciaAutorizacao, {
        'permissao': 'proprietario',
        'dataVinculacao': dataAtual,
      });

      // 3. Cria o vínculo personalizado na conta do usuário.
      transacao.set(referenciaVinculo, {
        'nome': nomePersonalizado,
        'permissao': 'proprietario',
        'dataVinculacao': dataAtual,
      });
    });
  }

  /// Atualiza somente o nome personalizado do usuário.
  Future<void> atualizarNomeModulo({
    required String espId,
    required String novoNome,
  }) async {
    final usuario = _autenticacao.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    if (novoNome.trim().isEmpty) {
      throw Exception('Informe um nome válido.');
    }

    await _banco
        .collection('usuarios')
        .doc(usuario.uid)
        .collection('modulos')
        .doc(espId)
        .update({
      'nome': novoNome.trim(),
    });
  }
}
