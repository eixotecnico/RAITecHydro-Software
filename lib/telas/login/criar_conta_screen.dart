import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaCriarConta extends StatefulWidget {
  const TelaCriarConta({super.key});

  @override
  State<TelaCriarConta> createState() => _TelaCriarContaState();
}

class _TelaCriarContaState extends State<TelaCriarConta> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  bool carregando = false;
  bool mostrarSenha = false;
  bool mostrarConfirmacao = false;

  static const Color azulPrincipal = Color(0xFF015A84);
  static const Color azulProfundo = Color(0xFF073B57);
  static const Color fundo = Color(0xFFF5F8FA);
  static const Color texto = Color(0xFF172B36);
  static const Color textoSecundario = Color(0xFF52616B);

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> criarConta() async {
    if (carregando) return;

    final nome = nomeController.text.trim();
    final email = emailController.text.trim();
    final senha = senhaController.text;
    final confirmarSenha = confirmarSenhaController.text;

    if (nome.isEmpty ||
        email.isEmpty ||
        senha.isEmpty ||
        confirmarSenha.isEmpty) {
      _mostrarMensagem('Preencha todos os campos.');
      return;
    }

    if (senha != confirmarSenha) {
      _mostrarMensagem('As senhas não coincidem.');
      return;
    }

    if (senha.length < 6) {
      _mostrarMensagem('A senha deve ter pelo menos 6 caracteres.');
      return;
    }

    setState(() => carregando = true);

    try {
      final credencial =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      await credencial.user?.updateDisplayName(nome);
      await credencial.user?.reload();

      // O main.dart detecta a autenticação e abre a lista de módulos.
    } on FirebaseAuthException catch (e) {
      String mensagem = 'Erro ao criar conta. Tente novamente.';

      switch (e.code) {
        case 'email-already-in-use':
          mensagem = 'Este e-mail já está cadastrado.';
          break;
        case 'invalid-email':
          mensagem = 'O endereço de e-mail é inválido.';
          break;
        case 'weak-password':
          mensagem = 'A senha é muito fraca.';
          break;
        case 'operation-not-allowed':
          mensagem = 'Cadastro por e-mail não está habilitado.';
          break;
        case 'network-request-failed':
          mensagem = 'Falha de conexão. Verifique sua internet.';
          break;
      }

      _mostrarMensagem(mensagem);
    } catch (e) {
      _mostrarMensagem('Ocorreu um erro ao criar a conta.');
    } finally {
      if (mounted) {
        setState(() => carregando = false);
      }
    }
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensagem),
          behavior: SnackBarBehavior.floating,
          backgroundColor: azulProfundo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/plantas.jpg',
            fit: BoxFit.cover,
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  azulProfundo.withValues(alpha: 0.78),
                  azulProfundo.withValues(alpha: 0.90),
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      _cabecalho(),

                      const SizedBox(height: 28),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.97),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Crie sua conta',
                              style: TextStyle(
                                color: texto,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              'Cadastre-se para começar a monitorar '
                              'suas plantas de maneira inteligente.',
                              style: TextStyle(
                                color: textoSecundario,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 28),

                            _campo(
                              controller: nomeController,
                              titulo: 'Nome completo',
                              dica: 'Como podemos chamar você?',
                              icone: Icons.person_outline,
                              capitalizacao: TextCapitalization.words,
                            ),

                            const SizedBox(height: 19),

                            _campo(
                              controller: emailController,
                              titulo: 'E-mail',
                              dica: 'Digite seu e-mail',
                              icone: Icons.email_outlined,
                              teclado: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 19),

                            _campo(
                              controller: senhaController,
                              titulo: 'Senha',
                              dica: 'Crie uma senha',
                              icone: Icons.lock_outline,
                              senha: true,
                              mostrarSenha: mostrarSenha,
                              aoAlternarSenha: () {
                                setState(() {
                                  mostrarSenha = !mostrarSenha;
                                });
                              },
                            ),

                            const SizedBox(height: 19),

                            _campo(
                              controller: confirmarSenhaController,
                              titulo: 'Confirmar senha',
                              dica: 'Digite a senha novamente',
                              icone: Icons.lock_outline,
                              senha: true,
                              mostrarSenha: mostrarConfirmacao,
                              aoAlternarSenha: () {
                                setState(() {
                                  mostrarConfirmacao =
                                      !mostrarConfirmacao;
                                });
                              },
                            ),

                            const SizedBox(height: 12),

                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: textoSecundario,
                                  size: 16,
                                ),
                                SizedBox(width: 7),
                                Expanded(
                                  child: Text(
                                    'Utilize uma senha com pelo menos '
                                    '6 caracteres.',
                                    style: TextStyle(
                                      color: textoSecundario,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 28),

                            SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed:
                                    carregando ? null : criarConta,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: azulPrincipal,
                                  disabledBackgroundColor:
                                      azulPrincipal.withValues(alpha: 0.5),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: carregando
                                    ? const SizedBox(
                                        height: 23,
                                        width: 23,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'CRIAR MINHA CONTA',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.7,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            Center(
                              child: TextButton.icon(
                                onPressed: carregando
                                    ? null
                                    : () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.arrow_back,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Já possui uma conta? Entrar',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: azulPrincipal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cabecalho() {
    return Column(
      children: [
        Container(
          height: 82,
          width: 82,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(23),
          ),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(height: 15),

        const Text(
          'Regador Automático',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'Faça parte do cuidado inteligente com plantas',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String titulo,
    required String dica,
    required IconData icone,
    TextInputType teclado = TextInputType.text,
    TextCapitalization capitalizacao = TextCapitalization.none,
    bool senha = false,
    bool mostrarSenha = false,
    VoidCallback? aoAlternarSenha,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: texto,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 9),

        TextField(
          controller: controller,
          keyboardType: teclado,
          textCapitalization: capitalizacao,
          obscureText: senha && !mostrarSenha,
          autocorrect: !senha,
          enableSuggestions: !senha,
          style: const TextStyle(
            color: texto,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: dica,
            hintStyle: const TextStyle(
              color: Color(0xFF9AA7AE),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icone,
              color: azulPrincipal,
              size: 21,
            ),
            suffixIcon: senha
                ? IconButton(
                    onPressed: aoAlternarSenha,
                    icon: Icon(
                      mostrarSenha
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: textoSecundario,
                    ),
                  )
                : null,
            filled: true,
            fillColor: fundo,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Color(0xFFDCE6EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Color(0xFFDCE6EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: azulPrincipal,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}