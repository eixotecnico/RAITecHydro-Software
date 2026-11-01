class Planta {
  final String id;
  final String espId;
  final String nome;
  final String especie;
  final String? descricao;
  final String? imagemUrl;
  final DateTime? dataCadastro;

  Planta({
    required this.id,
    required this.espId,
    required this.nome,
    required this.especie,
    this.descricao,
    this.imagemUrl,
    this.dataCadastro,
  });

  factory Planta.fromMap({
    required String id,
    required String espId,
    required Map<String, dynamic> dados,
  }) {
    return Planta(
      id: id,
      espId: espId,
      nome: dados['nome'] as String? ?? '',
      especie: dados['especie'] as String? ?? '',
      descricao: dados['descricao'] as String?,
      imagemUrl: dados['imagemUrl'] as String?,
      dataCadastro:
          (dados['dataCadastro'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> paraMap() {
    return {
      'nome': nome,
      'especie': especie,
      'descricao': descricao,
      'imagemUrl': imagemUrl,
      'dataCadastro': dataCadastro,
    };
  }
}