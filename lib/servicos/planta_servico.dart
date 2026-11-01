import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../modelos/planta.dart';

class PlantaServico {
  final FirebaseFirestore _banco = FirebaseFirestore.instance;
  final FirebaseAuth _autenticacao = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _colecaoPlantas(
    String espId,
  ) {
    return _banco
        .collection('modulos')
        .doc(espId)
        .collection('plantas');
  }

  /// Acompanha as plantas de um módulo em tempo real.
  Stream<List<Planta>> observarPlantas(String espId) {
    return _colecaoPlantas(espId)
        .orderBy('nome')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((documento) {
        return Planta.fromMap(
          id: documento.id,
          espId: espId,
          dados: documento.data(),
        );
      }).toList();
    });
  }

  /// Cadastra uma planta no módulo selecionado.
  Future<void> adicionarPlanta({
    required String espId,
    required String nome,
    required String especie,
    String? descricao,
    String? imagemUrl,
  }) async {
    final usuario = _autenticacao.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    if (nome.trim().isEmpty || especie.trim().isEmpty) {
      throw Exception('Informe o nome e a espécie da planta.');
    }

    await _colecaoPlantas(espId).add({
      'nome': nome.trim(),
      'especie': especie.trim(),
      'descricao': descricao?.trim(),
      'imagemUrl': imagemUrl,
      'dataCadastro': FieldValue.serverTimestamp(),
      'criadoPor': usuario.uid,
    });
  }

  /// Atualiza os dados de uma planta.
  Future<void> atualizarPlanta({
    required String espId,
    required String plantaId,
    required String nome,
    required String especie,
    String? descricao,
    String? imagemUrl,
  }) async {
    final usuario = _autenticacao.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    if (nome.trim().isEmpty || especie.trim().isEmpty) {
      throw Exception('Informe o nome e a espécie da planta.');
    }

    await _colecaoPlantas(espId).doc(plantaId).update({
      'nome': nome.trim(),
      'especie': especie.trim(),
      'descricao': descricao?.trim(),
      'imagemUrl': imagemUrl,
    });
  }

  /// Exclui uma planta.
  Future<void> excluirPlanta({
    required String espId,
    required String plantaId,
  }) async {
    final usuario = _autenticacao.currentUser;

    if (usuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    await _colecaoPlantas(espId).doc(plantaId).delete();
  }
}