import 'package:flutter/material.dart';

import '../../modelos/modulo.dart';
import '../../modelos/planta.dart';
import '../../servicos/planta_servico.dart';
import '../../componentes/cartao_planta.dart';
import 'detalhes_planta.dart';

const Color azulPrincipal = Color(0xFF015A84);
const Color azulEscuro = Color(0xFF073B57);
const Color azulClaro = Color(0xFFE8F3F8);
const Color azulSuave = Color(0xFFD2E7F0);
const Color verdeNatural = Color(0xFF4E9B70);
const Color verdeClaro = Color(0xFFE7F3EA);
const Color fundoTela = Color(0xFFF5F8FA);
const Color textoSecundario = Color(0xFF52616B);
const Color textoPrincipal = Color(0xFF172B36);

class ListaDePlantas extends StatefulWidget {
  final Modulo modulo;

  const ListaDePlantas({
    super.key,
    required this.modulo,
  });

  @override
  State<ListaDePlantas> createState() => _ListaDePlantasState();
}

class _ListaDePlantasState extends State<ListaDePlantas> {
  final PlantaServico _plantaServico = PlantaServico();

  bool get podeGerenciar =>
      widget.modulo.permissao.podeGerenciarPlantas;

  Future<void> _adicionarPlanta() async {
    final nomeController = TextEditingController();
    final especieController = TextEditingController();
    final descricaoController = TextEditingController();

    final resultado = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Adicionar planta',
            style: TextStyle(
              color: textoPrincipal,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _campoFormulario(
                  controller: nomeController,
                  label: 'Nome da planta',
                  hint: 'Ex.: Mangueira',
                  icone: Icons.local_florist_outlined,
                ),
                const SizedBox(height: 15),
                _campoFormulario(
                  controller: especieController,
                  label: 'Espécie',
                  hint: 'Ex.: Mangifera indica',
                  icone: Icons.eco_outlined,
                ),
                const SizedBox(height: 15),
                _campoFormulario(
                  controller: descricaoController,
                  label: 'Descrição (opcional)',
                  hint: 'Informações sobre a planta',
                  icone: Icons.notes_rounded,
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: textoSecundario),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: azulPrincipal,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final nome = nomeController.text.trim();
                final especie = especieController.text.trim();

                if (nome.isEmpty || especie.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Preencha o nome e a espécie da planta.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext, {
                  'nome': nome,
                  'especie': especie,
                  'descricao': descricaoController.text.trim(),
                });
              },
              child: const Text(
                'Cadastrar',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    nomeController.dispose();
    especieController.dispose();
    descricaoController.dispose();

    if (resultado == null || !mounted) return;

    try {
      await _plantaServico.adicionarPlanta(
        espId: widget.modulo.espId,
        nome: resultado['nome']!,
        especie: resultado['especie']!,
        descricao: resultado['descricao'],
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Planta cadastrada com sucesso!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível cadastrar a planta: $erro'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _editarPlanta(Planta planta) async {
    final nomeController = TextEditingController(text: planta.nome);
    final especieController =
        TextEditingController(text: planta.especie);
    final descricaoController =
        TextEditingController(text: planta.descricao ?? '');

    final resultado = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Editar planta',
            style: TextStyle(
              color: textoPrincipal,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _campoFormulario(
                  controller: nomeController,
                  label: 'Nome',
                  icone: Icons.local_florist_outlined,
                ),
                const SizedBox(height: 15),
                _campoFormulario(
                  controller: especieController,
                  label: 'Espécie',
                  icone: Icons.eco_outlined,
                ),
                const SizedBox(height: 15),
                _campoFormulario(
                  controller: descricaoController,
                  label: 'Descrição',
                  icone: Icons.notes_rounded,
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: textoSecundario),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: azulPrincipal,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final nome = nomeController.text.trim();
                final especie = especieController.text.trim();

                if (nome.isNotEmpty && especie.isNotEmpty) {
                  Navigator.pop(dialogContext, {
                    'nome': nome,
                    'especie': especie,
                    'descricao': descricaoController.text.trim(),
                  });
                }
              },
              child: const Text(
                'Salvar alterações',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    nomeController.dispose();
    especieController.dispose();
    descricaoController.dispose();

    if (resultado == null || !mounted) return;

    try {
      await _plantaServico.atualizarPlanta(
        espId: widget.modulo.espId,
        plantaId: planta.id,
        nome: resultado['nome']!,
        especie: resultado['especie']!,
        descricao: resultado['descricao'],
        imagemUrl: planta.imagemUrl,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Planta atualizada com sucesso!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao editar planta: $erro'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _abrirDetalhes(Planta planta) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalhesPlanta(
          planta: planta,
          modulo: widget.modulo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundoTela,
      appBar: AppBar(
        backgroundColor: azulPrincipal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 4,
        title: const Text(
          'Minhas plantas',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      floatingActionButton: podeGerenciar
          ? FloatingActionButton.extended(
              onPressed: _adicionarPlanta,
              backgroundColor: azulPrincipal,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Adicionar planta',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            )
          : null,
      body: SafeArea(
        child: StreamBuilder<List<Planta>>(
          stream: _plantaServico.observarPlantas(
            widget.modulo.espId,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: azulPrincipal,
                  strokeWidth: 3,
                ),
              );
            }

            if (snapshot.hasError) {
              return _construirErro(snapshot.error);
            }

            final plantas = snapshot.data ?? [];

            return RefreshIndicator(
              color: azulPrincipal,
              onRefresh: () async {
                await _plantaServico.observarPlantas(
                  widget.modulo.espId,
                ).first;
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                children: [
                  _construirApresentacao(),
                  const SizedBox(height: 22),
                  _construirCartaoModulo(plantas.length),
                  const SizedBox(height: 28),
                  _construirTituloSecao(plantas.length),
                  const SizedBox(height: 15),
                  if (plantas.isEmpty)
                    _construirEstadoVazio()
                  else
                    ...plantas.asMap().entries.map(
                      (entrada) {
                        final planta = entrada.value;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: CartaoPlanta(
                            planta: planta,
                            onTap: () => _abrirDetalhes(planta),
                            onEditar: podeGerenciar
                                ? () => _editarPlanta(planta)
                                : null,
                          ),
                        );
                      },
                    ),
                  if (!podeGerenciar && plantas.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _construirAvisoPermissao(),
                  ],
                  const SizedBox(height: 75),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _construirApresentacao() {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            azulPrincipal,
            azulEscuro,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: azulPrincipal.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -20,
            child: Icon(
              Icons.eco_rounded,
              size: 115,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.spa_outlined,
                      color: Color(0xFFB8E7C7),
                      size: 16,
                    ),
                    SizedBox(width: 7),
                    Text(
                      'CUIDADO INTELIGENTE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 19),
              const Text(
                'Regador Automático',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'Gerencie suas plantas e acompanhe '
                'o desenvolvimento de cada uma.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.78),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirCartaoModulo(int quantidade) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8EEF2),
        ),
        boxShadow: [
          BoxShadow(
            color: azulEscuro.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: azulClaro,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.memory_rounded,
              color: azulPrincipal,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Módulo conectado à sua horta',
                  style: TextStyle(
                    color: textoSecundario,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.modulo.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textoPrincipal,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ESP ID: ${widget.modulo.espId}',
                  style: const TextStyle(
                    color: textoSecundario,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: verdeClaro,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '$quantidade',
                  style: const TextStyle(
                    color: verdeNatural,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  quantidade == 1 ? 'planta' : 'plantas',
                  style: const TextStyle(
                    color: verdeNatural,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirTituloSecao(int quantidade) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sua coleção',
                style: TextStyle(
                  color: textoPrincipal,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$quantidade ${quantidade == 1 ? 'planta cadastrada' : 'plantas cadastradas'}',
                style: const TextStyle(
                  color: textoSecundario,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (!podeGerenciar)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: azulClaro,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 14,
                  color: azulPrincipal,
                ),
                SizedBox(width: 5),
                Text(
                  'Somente leitura',
                  style: TextStyle(
                    color: azulPrincipal,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _construirEstadoVazio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 35, 22, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8EEF2),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: verdeClaro,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_florist_rounded,
              color: verdeNatural,
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sua horta começa aqui!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textoPrincipal,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            podeGerenciar
                ? 'Você ainda não cadastrou nenhuma planta.\n'
                    'Adicione a primeira para começar o monitoramento.'
                : 'Ainda não existem plantas cadastradas\n'
                    'neste módulo.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textoSecundario,
              fontSize: 12,
              height: 1.6,
            ),
          ),
          if (podeGerenciar) ...[
            const SizedBox(height: 23),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _adicionarPlanta,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Cadastrar primeira planta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: azulPrincipal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _construirAvisoPermissao() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: azulClaro,
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: azulPrincipal,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Você possui acesso somente para visualizar '
              'as plantas deste módulo.',
              style: TextStyle(
                color: azulEscuro,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirErro(Object? erro) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: const Color(0xFFFCEBEA),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                color: Color(0xFFD9534F),
                size: 35,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Não foi possível carregar as plantas',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textoPrincipal,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Verifique sua conexão e tente novamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textoSecundario,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '$erro',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textoSecundario,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoFormulario({
    required TextEditingController controller,
    required String label,
    required IconData icone,
    String? hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icone,
          color: azulPrincipal,
          size: 21,
        ),
        filled: true,
        fillColor: fundoTela,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: Color(0xFFE3EBF0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: azulPrincipal,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}