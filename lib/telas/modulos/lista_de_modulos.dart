import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../modelos/modulo.dart';
import '../../servicos/modulo_servico.dart';
import '../../servicos/planta_servico.dart';
import '../../componentes/cartao_modulo.dart';
import '../plantas/lista_de_plantas.dart';

const Color azulPrincipal = Color(0xFF015A84);
const Color azulProfundo = Color(0xFF073B57);
const Color azulClaro = Color(0xFFE8F3F8);
const Color azulSuave = Color(0xFFD2E7F0);
const Color verdeNatural = Color(0xFF4E9B70);
const Color verdeSuave = Color(0xFFE7F3EA);
const Color fundoTela = Color(0xFFF5F8FA);
const Color textoPrincipal = Color(0xFF172B36);
const Color textoSecundario = Color(0xFF52616B);
const Color vermelhoErro = Color(0xFFD9534F);

class ListaDeModulos extends StatefulWidget {
  const ListaDeModulos({super.key});

  @override
  State<ListaDeModulos> createState() => _ListaDeModulosState();
}

class _ListaDeModulosState extends State<ListaDeModulos> {
  final ModuloServico _moduloServico = ModuloServico();
  final PlantaServico _plantaServico = PlantaServico();

  late Future<List<Modulo>> _modulosFuture;

  bool _cadastrandoModulo = false;

  User? get usuario => FirebaseAuth.instance.currentUser;

  String get nomeUsuario {
    final nome = usuario?.displayName;

    if (nome != null && nome.trim().isNotEmpty) {
      return nome.trim();
    }

    return usuario?.email?.split('@').first ?? 'Usuário';
  }

  String get emailUsuario => usuario?.email ?? '';

  @override
  void initState() {
    super.initState();
    _carregarModulos();
  }

  void _carregarModulos() {
    _modulosFuture = _moduloServico.listarModulos();
  }

  Future<void> _atualizarLista() async {
    setState(_carregarModulos);
    await _modulosFuture;
  }

  // ------------------------------------------
  // EDITAR NOME DO MÓDULO
  // ------------------------------------------

  Future<void> _editarNomeModulo(Modulo modulo) async {
    final controller = TextEditingController(text: modulo.nome);

    final novoNome = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Editar nome do módulo',
            style: TextStyle(
              color: azulProfundo,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: textoPrincipal),
            decoration: _decoracaoCampo(
              label: 'Nome personalizado',
              hint: 'Ex.: Módulo da horta',
              icone: Icons.edit_outlined,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
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
                final nome = controller.text.trim();

                if (nome.isNotEmpty) {
                  Navigator.pop(dialogContext, nome);
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

    controller.dispose();

    if (novoNome == null || !mounted) return;

    try {
      await _moduloServico.atualizarNomeModulo(
        espId: modulo.espId,
        novoNome: novoNome,
      );

      if (!mounted) return;

      await _atualizarLista();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        _construirNotificacao(
          'Nome do módulo atualizado com sucesso!',
          sucesso: true,
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        _construirNotificacao(
          'Não foi possível atualizar: ${_mensagemErro(erro)}',
          sucesso: false,
        ),
      );
    }
  }

  // ------------------------------------------
  // ADICIONAR MÓDULO
  // ------------------------------------------

  Future<void> _adicionarModulo() async {
    if (_cadastrandoModulo) return;

    final dados = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _FormularioModuloDialog(),
    );

    if (dados == null || !mounted) return;

    setState(() {
      _cadastrandoModulo = true;
    });

    try {
      await _moduloServico.cadastrarModulo(
        espId: dados['espId'] as String,
        nome: dados['nome'] as String,
        possuiTemperatura: dados['possuiTemperatura'] as bool,
        possuiUmidadeAr: dados['possuiUmidadeAr'] as bool,
        possuiUmidadeSolo: dados['possuiUmidadeSolo'] as bool,
      );

      if (!mounted) return;

      await _atualizarLista();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        _construirNotificacao(
          'Módulo cadastrado! Você é o proprietário deste dispositivo.',
          sucesso: true,
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        _construirNotificacao(
          _mensagemErro(erro),
          sucesso: false,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _cadastrandoModulo = false;
        });
      }
    }
  }

  String _mensagemErro(Object erro) {
    final mensagem = erro.toString();

    return mensagem.startsWith('Exception: ')
        ? mensagem.replaceFirst('Exception: ', '')
        : mensagem;
  }

  SnackBar _construirNotificacao(
    String mensagem, {
    required bool sucesso,
  }) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: sucesso ? azulProfundo : vermelhoErro,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      content: Row(
        children: [
          Icon(
            sucesso ? Icons.check_circle_outline : Icons.error_outline,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              mensagem,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------
  // ENCERRAR SESSÃO
  // ------------------------------------------

  Future<void> _sairDaConta() async {
    await FirebaseAuth.instance.signOut();
  }

  // ------------------------------------------
  // ABRIR PLANTAS
  // ------------------------------------------

  void _abrirPlantas(Modulo modulo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListaDePlantas(modulo: modulo),
      ),
    );
  }

  // ------------------------------------------
  // TELA PRINCIPAL
  // ------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundoTela,
      appBar: AppBar(
        backgroundColor: azulPrincipal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: const Text(
          'Regador Automático',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _construirMenu(),
      body: SafeArea(
        child: RefreshIndicator(
          color: azulPrincipal,
          backgroundColor: Colors.white,
          onRefresh: _atualizarLista,
          child: FutureBuilder<List<Modulo>>(
            future: _modulosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: azulPrincipal,
                    strokeWidth: 2.5,
                  ),
                );
              }

              if (snapshot.hasError) {
                return _construirErro(snapshot.error.toString());
              }

              final modulos = snapshot.data ?? [];

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 32),
                children: [
                  _construirApresentacao(),

                  const SizedBox(height: 25),

                  _construirBotaoAdicionar(),

                  const SizedBox(height: 32),

                  _construirTituloSecao(modulos.length),

                  const SizedBox(height: 17),

                  if (modulos.isEmpty)
                    _construirEstadoVazio()
                  else
                    ...modulos.map(
                      (modulo) => Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: StreamBuilder(
                          stream: _plantaServico.observarPlantas(
                            modulo.espId,
                          ),
                          builder: (context, plantasSnapshot) {
                            final quantidade =
                                plantasSnapshot.data?.length ?? 0;

                            return CartaoModulo(
                              modulo: modulo,
                              quantidadePlantas: quantidade,
                              onTap: () => _abrirPlantas(modulo),
                              onEditar: () => _editarNomeModulo(modulo),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ------------------------------------------
  // APRESENTAÇÃO
  // ------------------------------------------

  Widget _construirApresentacao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Olá,',
          style: TextStyle(
            fontSize: 15,
            color: textoSecundario,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          nomeUsuario,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w700,
            color: azulProfundo,
            letterSpacing: -0.7,
          ),
        ),

        const SizedBox(height: 9),

        const Text(
          'Acompanhe seus dispositivos e monitore o cuidado com suas plantas em um só lugar.',
          style: TextStyle(
            fontSize: 14,
            color: textoSecundario,
            height: 1.55,
          ),
        ),

        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: azulClaro,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: azulSuave,
              width: 1,
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.eco_outlined,
                color: verdeNatural,
                size: 27,
              ),
              SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seu cultivo, sob controle',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: azulProfundo,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Acompanhe as condições das suas plantas com praticidade.',
                      style: TextStyle(
                        fontSize: 12,
                        color: textoSecundario,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------
  // BOTÃO ADICIONAR
  // ------------------------------------------

  Widget _construirBotaoAdicionar() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _cadastrandoModulo ? null : _adicionarModulo,
        icon: _cadastrandoModulo
            ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add_rounded, size: 23),
        label: Text(
          _cadastrandoModulo
              ? 'Cadastrando módulo...'
              : 'Adicionar módulo',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: azulPrincipal,
          foregroundColor: Colors.white,
          disabledBackgroundColor: azulPrincipal.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------
  // TÍTULO DA SEÇÃO
  // ------------------------------------------

  Widget _construirTituloSecao(int quantidade) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Meus dispositivos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textoPrincipal,
              letterSpacing: -0.3,
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: azulClaro,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$quantidade ${quantidade == 1 ? 'módulo' : 'módulos'}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: azulPrincipal,
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------
  // MENU LATERAL
  // ------------------------------------------

  Widget _construirMenu() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 60, 22, 25),
            decoration: const BoxDecoration(
              color: azulPrincipal,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(22),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: azulPrincipal,
                    size: 34,
                  ),
                ),

                const SizedBox(height: 17),

                Text(
                  nomeUsuario,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  emailUsuario,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.eco_outlined,
                        color: Colors.white,
                        size: 15,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Regador Automático',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              decoration: BoxDecoration(
                color: azulClaro,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.memory_rounded,
                  color: azulPrincipal,
                ),
                title: const Text(
                  'Meus módulos',
                  style: TextStyle(
                    color: azulProfundo,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                selected: true,
                onTap: () => Navigator.pop(context),
              ),
            ),
          ),

          const Spacer(),

          const Divider(
            color: azulSuave,
            indent: 20,
            endIndent: 20,
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 5, 12, 20),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: const Icon(
                Icons.logout_rounded,
                color: vermelhoErro,
              ),
              title: const Text(
                'Sair da conta',
                style: TextStyle(
                  color: vermelhoErro,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _sairDaConta();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------
  // ESTADO VAZIO
  // ------------------------------------------

  Widget _construirEstadoVazio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 35, 22, 35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: azulSuave),
        boxShadow: [
          BoxShadow(
            color: azulProfundo.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: const BoxDecoration(
              color: azulClaro,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.memory_outlined,
              color: azulPrincipal,
              size: 42,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Nenhum módulo cadastrado',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: azulProfundo,
            ),
          ),

          const SizedBox(height: 9),

          const Text(
            'Adicione seu primeiro dispositivo para começar a acompanhar as condições do seu cultivo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: textoSecundario,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          OutlinedButton.icon(
            onPressed: _adicionarModulo,
            icon: const Icon(Icons.add_rounded, size: 19),
            label: const Text('Cadastrar primeiro módulo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: azulPrincipal,
              side: const BorderSide(color: azulPrincipal),
              padding: const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------
  // ESTADO DE ERRO
  // ------------------------------------------

  Widget _construirErro(String erro) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: const Color(0xFFFCEBEA),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                color: vermelhoErro,
                size: 42,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Não foi possível carregar seus módulos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textoPrincipal,
              ),
            ),

            const SizedBox(height: 9),

            const Text(
              'Verifique sua conexão com a internet e tente novamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: textoSecundario,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              erro,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: textoSecundario,
              ),
            ),

            const SizedBox(height: 22),

            ElevatedButton.icon(
              onPressed: _atualizarLista,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
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
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================
// FORMULÁRIO DE CADASTRO DO MÓDULO
// ==================================================

class _FormularioModuloDialog extends StatefulWidget {
  const _FormularioModuloDialog();

  @override
  State<_FormularioModuloDialog> createState() =>
      _FormularioModuloDialogState();
}

class _FormularioModuloDialogState
    extends State<_FormularioModuloDialog> {
  final _formularioKey = GlobalKey<FormState>();

  final _controllerNome = TextEditingController(
    text: 'Módulo da horta',
  );

  final _controllerEspId = TextEditingController(
    text: '30:76:F5:93:79:C8',
  );

  bool possuiTemperatura = true;
  bool possuiUmidadeAr = true;
  bool possuiUmidadeSolo = true;

  @override
  void dispose() {
    _controllerNome.dispose();
    _controllerEspId.dispose();
    super.dispose();
  }

  InputDecoration _decoracaoCampo({
    required String label,
    required String hint,
    required IconData icone,
  }) {
    return InputDecoration(
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
        horizontal: 15,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: azulSuave),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: azulSuave),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: azulPrincipal,
          width: 1.6,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: vermelhoErro),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: vermelhoErro,
          width: 1.5,
        ),
      ),
    );
  }

  void _cadastrar() {
    if (!_formularioKey.currentState!.validate()) {
      return;
    }

    if (!possuiTemperatura &&
        !possuiUmidadeAr &&
        !possuiUmidadeSolo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos um sensor.'),
          backgroundColor: vermelhoErro,
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      {
        'nome': _controllerNome.text.trim(),
        'espId': _controllerEspId.text.trim(),
        'possuiTemperatura': possuiTemperatura,
        'possuiUmidadeAr': possuiUmidadeAr,
        'possuiUmidadeSolo': possuiUmidadeSolo,
      },
    );
  }

  // ------------------------------------------
  // ITEM DE SENSOR
  // ------------------------------------------

  Widget _construirSensor({
    required String titulo,
    required String descricao,
    required IconData icone,
    required bool selecionado,
    required Color corIcone,
    required ValueChanged<bool?> aoAlterar,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: selecionado ? azulClaro : Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: selecionado ? azulSuave : const Color(0xFFE7EDF0),
        ),
      ),
      child: CheckboxListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 5,
        ),
        activeColor: azulPrincipal,
        checkboxShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        controlAffinity: ListTileControlAffinity.trailing,
        secondary: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: corIcone.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icone,
            color: corIcone,
            size: 23,
          ),
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textoPrincipal,
          ),
        ),
        subtitle: Text(
          descricao,
          style: const TextStyle(
            fontSize: 11,
            color: textoSecundario,
          ),
        ),
        value: selecionado,
        onChanged: aoAlterar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // CABEÇALHO

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(21, 21, 16, 19),
              decoration: const BoxDecoration(
                color: azulClaro,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.memory_rounded,
                      color: azulPrincipal,
                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 13),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adicionar módulo',
                          style: TextStyle(
                            color: azulProfundo,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Configure seu dispositivo',
                          style: TextStyle(
                            color: textoSecundario,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    tooltip: 'Fechar',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: textoSecundario,
                    ),
                  ),
                ],
              ),
            ),

            // CONTEÚDO

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
                child: Form(
                  key: _formularioKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Identificação',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: azulProfundo,
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        'Defina como deseja identificar seu equipamento.',
                        style: TextStyle(
                          fontSize: 12,
                          color: textoSecundario,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _controllerNome,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(
                          color: textoPrincipal,
                          fontSize: 14,
                        ),
                        decoration: _decoracaoCampo(
                          label: 'Nome do módulo',
                          hint: 'Ex.: Módulo da horta',
                          icone: Icons.label_outline_rounded,
                        ),
                        validator: (valor) {
                          if (valor == null || valor.trim().isEmpty) {
                            return 'Informe um nome para o módulo.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 13),

                      TextFormField(
                        controller: _controllerEspId,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(
                          color: textoPrincipal,
                          fontSize: 14,
                        ),
                        decoration: _decoracaoCampo(
                          label: 'Identificação do ESP32',
                          hint: 'Ex.: 30:76:F5:93:79:C8',
                          icone: Icons.developer_board_outlined,
                        ),
                        validator: (valor) {
                          if (valor == null || valor.trim().isEmpty) {
                            return 'Informe o ID do ESP32.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        'Sensores disponíveis',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: azulProfundo,
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        'Marque somente os sensores instalados neste dispositivo.',
                        style: TextStyle(
                          fontSize: 12,
                          color: textoSecundario,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 14),

                      _construirSensor(
                        titulo: 'Temperatura',
                        descricao: 'Monitoramento da temperatura ambiente',
                        icone: Icons.thermostat_rounded,
                        corIcone: const Color(0xFFE58B45),
                        selecionado: possuiTemperatura,
                        aoAlterar: (valor) {
                          setState(() {
                            possuiTemperatura = valor ?? false;
                          });
                        },
                      ),

                      _construirSensor(
                        titulo: 'Umidade do ar',
                        descricao: 'Acompanhamento da umidade ambiente',
                        icone: Icons.water_drop_outlined,
                        corIcone: azulPrincipal,
                        selecionado: possuiUmidadeAr,
                        aoAlterar: (valor) {
                          setState(() {
                            possuiUmidadeAr = valor ?? false;
                          });
                        },
                      ),

                      _construirSensor(
                        titulo: 'Umidade do solo',
                        descricao: 'Monitoramento da umidade da terra',
                        icone: Icons.grass_rounded,
                        corIcone: verdeNatural,
                        selecionado: possuiUmidadeSolo,
                        aoAlterar: (valor) {
                          setState(() {
                            possuiUmidadeSolo = valor ?? false;
                          });
                        },
                      ),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: verdeSuave,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: verdeNatural,
                              size: 19,
                            ),
                            SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'Selecione apenas os sensores que realmente estão instalados no seu módulo.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textoPrincipal,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // AÇÕES

            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: azulSuave),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textoSecundario,
                        side: const BorderSide(color: azulSuave),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _cadastrar,
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text(
                        'Cadastrar módulo',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: azulPrincipal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================
// DECORAÇÃO DOS CAMPOS
// ==================================================

InputDecoration _decoracaoCampo({
  required String label,
  required String hint,
  required IconData icone,
}) {
  return InputDecoration(
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
      horizontal: 15,
      vertical: 16,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: azulSuave),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: azulSuave),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: azulPrincipal,
        width: 1.5,
      ),
    ),
  );
}
