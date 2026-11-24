import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guia_turismo/controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // Mostra a tela de acesso com o estado atual do login.
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF22D3EE).withValues(alpha: 0.08),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: 72,
                        height: 72,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22D3EE)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFF22D3EE)
                                .withValues(alpha: 0.28),
                          ),
                        ),
                        child: const Icon(
                          Icons.explore_rounded,
                          color: Color(0xFF22D3EE),
                          size: 38,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Nome principal do app exibido no topo da tela de login.
                      const Text(
                        'ROTA DO FABIANO',
                        style: TextStyle(
                          color: Color(0xFF22D3EE),
                          fontSize: 12,
                          letterSpacing: 2.8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Seu próximo lugar\nfavorito está por aqui.',
                        style: TextStyle(
                          color: Color(0xFFF1F5F9),
                          fontSize: 30,
                          height: 1.18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Entre para explorar destinos e compartilhar novos lugares.',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      if (controller.erro.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B6B)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFF6B6B)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            controller.erro,
                            style: const TextStyle(color: Color(0xFFFF9B9B)),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 54,
                        child: FilledButton.icon(
                          onPressed: controller.carregando
                              ? null
                              : controller.entrarComGoogle,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF22D3EE),
                            foregroundColor: const Color(0xFF06232B),
                            disabledBackgroundColor: const Color(0xFF22D3EE)
                                .withValues(alpha: 0.45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: controller.carregando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Color(0xFF06232B),
                                  ),
                                )
                              : const Icon(Icons.login_rounded),
                          label: const Text(
                            'Entrar com o Google',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Center(
                        child: Text(
                          'Descubra. Salve. Compartilhe.',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
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
