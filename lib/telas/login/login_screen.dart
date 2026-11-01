import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'criar_conta_screen.dart';
import 'esqueceu_senha_screen.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool carregando = false;
  bool mostrarSenha = false;

  static const Color azulPrincipal = Color(0xFF015A84);
  static const Color azulProfundo = Color(0xFF073B57);
  static const Color fundo = Color(0xFFF5F8FA);
  static const Color texto = Color(0xFF172B36);
  static const Color textoSecundario = Color(0xFF52616B);

  Future<void> login() async {
    if (carregando) return;

    if (emailController.text.trim().isEmpty ||
        senhaController.text.isEmpty) {
      _mostrarMensagem('Preencha o e-mail e a senha.');
      return;
    }

    setState(() => carregando = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text,
      );

      // O main.dart identifica a autenticação e abre a lista de módulos.
    } on FirebaseAuthException catch (e) {
      String mensagem = 'Erro ao fazer login.';

      switch (e.code) {
        case 'user-not-found':
          mensagem = 'Usuário não encontrado.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          mensagem = 'E-mail ou senha incorretos.';
          break;
        case 'invalid-email':
          mensagem = 'E-mail inválido.';
          break;
        case 'too-many-requests':
          mensagem = 'Muitas tentativas. Tente novamente mais tarde.';
          break;
        case 'network-request-failed':
          mensagem = 'Verifique sua conexão com a internet.';
          break;
      }

      _mostrarMensagem(mensagem);
    } catch (e) {
      _mostrarMensagem('Não foi possível fazer login.');
    } finally {
      if (mounted) {
        setState(() => carregando = false);
      }
    }
  }

  Future<void> loginComGoogle() async {
    if (carregando) return;

    setState(() => carregando = true);

    try {
      final googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // O main.dart identifica a autenticação e abre a lista de módulos.
    } on FirebaseAuthException catch (e) {
      _mostrarMensagem(
        'Erro ao entrar com Google: ${e.message ?? e.code}',
      );
    } catch (e) {
      _mostrarMensagem('Não foi possível entrar com Google.');
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
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      body: _fundoComImagem(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 32,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _cabecalho(),

                    const SizedBox(height: 32),

                    Container(
                      padding: const EdgeInsets.all(28),
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
                            'Bem-vindo de volta!',
                            style: TextStyle(
                              color: texto,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Entre para acompanhar seus módulos e '
                            'cuidar melhor das suas plantas.',
                            style: TextStyle(
                              color: textoSecundario,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 28),

                          _campo(
                            controller: emailController,
                            titulo: 'E-mail',
                            dica: 'Digite seu e-mail',
                            icone: Icons.email_outlined,
                            teclado: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 20),

                          _campo(
                            controller: senhaController,
                            titulo: 'Senha',
                            dica: 'Digite sua senha',
                            icone: Icons.lock_outline,
                            senha: true,
                            mostrarSenha: mostrarSenha,
                            aoAlternarSenha: () {
                              setState(() {
                                mostrarSenha = !mostrarSenha;
                              });
                            },
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: carregando
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const TelaEsqueceuSenha(),
                                        ),
                                      );
                                    },
                              child: const Text(
                                'Esqueceu a senha?',
                                style: TextStyle(
                                  color: azulPrincipal,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: carregando ? null : login,
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
                                      'ENTRAR',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  'OU',
                                  style: TextStyle(
                                    color: textoSecundario,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed:
                                  carregando ? null : loginComGoogle,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: texto,
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/google.png',
                                    height: 21,
                                    width: 21,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Continuar com Google',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Flexible(
                                child: Text(
                                  'Ainda não possui uma conta?',
                                  style: TextStyle(
                                    color: textoSecundario,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: carregando
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const TelaCriarConta(),
                                          ),
                                        );
                                      },
                                child: const Text(
                                  'Criar conta',
                                  style: TextStyle(
                                    color: azulPrincipal,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'RAITEC • RAITecHydro ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fundoComImagem({required Widget child}) {
    return Stack(
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
                azulProfundo.withValues(alpha: 0.88),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }

  Widget _cabecalho() {
    return Column(
      children: [
        Container(
          height: 94,
          width: 94,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'Regador Automático',
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Monitoramento para suas plantas',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 13,
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