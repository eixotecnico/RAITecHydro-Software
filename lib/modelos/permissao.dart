enum Permissao {
  proprietario,
  compartilhado,
  visualizador;

  String get valor {
    switch (this) {
      case Permissao.proprietario:
        return 'proprietario';
      case Permissao.compartilhado:
        return 'compartilhado';
      case Permissao.visualizador:
        return 'visualizador';
    }
  }

  String get descricao {
    switch (this) {
      case Permissao.proprietario:
        return 'Proprietário';
      case Permissao.compartilhado:
        return 'Acesso compartilhado';
      case Permissao.visualizador:
        return 'Somente visualização';
    }
  }

  bool get podeGerenciarPlantas {
    return this == Permissao.proprietario ||
        this == Permissao.compartilhado;
  }

  bool get podeCompartilhar {
    return this == Permissao.proprietario;
  }

  bool get podeTransferirPropriedade {
    return this == Permissao.proprietario;
  }

  static Permissao deString(String? valor) {
    switch (valor) {
      case 'proprietario':
        return Permissao.proprietario;
      case 'compartilhado':
        return Permissao.compartilhado;
      case 'visualizador':
        return Permissao.visualizador;
      default:
        return Permissao.visualizador;
    }
  }
}