import "package:core/core.dart";
import "package:flutter/material.dart";
import "login_viewmodel.dart";

class LoginPage extends StatefulWidget {
  final LoginViewModel viewModel;

  const LoginPage({required this.viewModel, super.key});

  @override
  State<LoginPage> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    widget.viewModel.login.addListener(_onLoginResult);
  }

  void _onLoginResult() {
    final command = widget.viewModel.login;

    if (command.value case FailureCommand(:final error)) {
      context.showErrorSnackBar(error.toString());
    }
  }

  @override
  void dispose() {
    widget.viewModel.login.removeListener(_onLoginResult);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.viewModel.login.execute((
      email: _emailController.text.trim(),
      password: _passwordController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "RouteSync",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Informe o email" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Senha",
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Informe a senha" : null,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 32),
                ListenableBuilder(
                  listenable: widget.viewModel.login,
                  builder: (context, _) {
                    final isRunning =
                        widget.viewModel.login.value is RunningCommand;
                    return FilledButton(
                      onPressed: isRunning ? null : _submit,
                      child: isRunning
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Entrar"),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
