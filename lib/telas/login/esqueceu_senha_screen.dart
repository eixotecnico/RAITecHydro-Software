import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaEsqueceuSenha extends StatefulWidget {
  const TelaEsqueceuSenha({super.key});

  @override
  State<TelaEsqueceuSenha> createState() => _TelaEsqueceuSenhaState();
}

class _TelaEsqueceuSenhaState extends State<TelaEsqueceuSenha> {
  final emailController = TextEditingController();

  bool carregando = false;

  static const Color azulPrincipal = Color(0xFF015A84);
  static const Color azulProfundo = Color(0xFF073B57);
  static const Color fundo = Color(0xFFF5F8FA);
  static const Color texto = Color(0xFF172B36);
  static const Color textoSecundario = Color(0xFF52616B);

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> enviarEmail() async {
    if (carregando) return;

    final email = emailController.text.trim();

    if (email.isEmpty) {
      _mostrarMensagem('Informe seu e-mail.');
      return;
    }

    setState(() => carregando = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('E-mail de recuperação enviado.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF4E9B70),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String mensagem = 'Erro ao enviar e-mail.';

      switch (e.code) {
        case 'invalid-email':
          mensagem = 'E-mail inválido.';
          break;
        case 'user-not-found':
          mensagem = 'Não existe uma conta com esse e-mail.';
          break;
        case 'network-request-failed':
          mensagem = 'Verifique sua conexão com a internet.';
          break;
      }

      _mostrarMensagem(mensagem);
    } catch (e) {
      _mostrarMensagem('Não foi possível enviar o e-mail.');
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
                vertical: 32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 90,
                        width: 90,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
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
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 30),

                      Container(
                        width: double.infinity,
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
                            Center(
                              child: Container(
                                height: 66,
                                width: 66,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F3F8),
                                  borderRadius: BorderRadius.circular(21),
                                ),
                                child: const Icon(
                                  Icons.mark_email_read_outlined,
                                  color: azulPrincipal,
                                  size: 34,
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            const Text(
                              'Recuperar senha',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: texto,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              'Não se preocupe! Informe o e-mail '
                              'cadastrado e enviaremos as instruções '
                              'para redefinir sua senha.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textoSecundario,
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),

                            const SizedBox(height: 30),

                            const Text(
                              'E-mail cadastrado',
                              style: TextStyle(
                                color: texto,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 9),

                            TextField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                color: texto,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Digite seu e-mail',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF9AA7AE),
                                  fontSize: 14,
                                ),
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: azulPrincipal,
                                  size: 21,
                                ),
                                filled: true,
                                fillColor: fundo,
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 17,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(13),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFDCE6EB),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(13),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFDCE6EB),
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
                            ),

                            const SizedBox(height: 25),

                            SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed:
                                    carregando ? null : enviarEmail,
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
                                        'ENVIAR INSTRUÇÕES',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 18),

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
                                  'Voltar ao login',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
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
}