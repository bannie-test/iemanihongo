import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Sign in / create account, or continue as a guest (fully offline).
/// Also used from Settings to link a guest's progress to an account.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.linking = false});

  final bool linking;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _signUp = false;
  bool _busy = false;
  bool _obscure = true;
  String? _message;
  bool _messageIsError = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final state = context.read<AppState>();
    if (state.supabase == null) {
      setState(() {
        _message = 'Accounts are unavailable right now. You can continue as a guest.';
        _messageIsError = true;
      });
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      String? info;
      if (_signUp) {
        info = await state.signUp(_email.text, _password.text);
      } else {
        await state.signIn(_email.text, _password.text);
      }
      if (!mounted) return;
      if (info != null) {
        setState(() {
          _message = info;
          _messageIsError = false;
          _signUp = false;
        });
      } else if (widget.linking) {
        Navigator.of(context).pop();
      }
    } on AuthException catch (e) {
      setState(() {
        _message = e.message;
        _messageIsError = true;
      });
    } catch (e) {
      setState(() {
        _message = 'Could not reach the server. Check your connection, or continue as a guest.';
        _messageIsError = true;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: widget.linking ? AppBar(title: const Text('Sync your progress')) : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!widget.linking) ...[
                      Center(
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(gradient: c.gradient, borderRadius: BorderRadius.circular(28)),
                          child: const Center(
                            child: Text('日', style: TextStyle(color: Colors.white, fontSize: 46, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Iemanihongo', textAlign: TextAlign.center, style: context.text.headlineMedium),
                      const SizedBox(height: 6),
                      Text('Japanese from N5 to N1: flashcards, quizzes\nand a short grammar lesson every day.',
                          textAlign: TextAlign.center, style: context.text.bodyMedium?.copyWith(color: c.muted)),
                      const SizedBox(height: 28),
                    ] else ...[
                      Text('Create an account or sign in to back up your progress and sync it across devices.',
                          style: context.text.bodyMedium?.copyWith(color: c.muted)),
                      const SizedBox(height: 20),
                    ],
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline_rounded)),
                      validator: (v) => v != null && RegExp(r'^\S+@\S+\.\S+$').hasMatch(v.trim()) ? null : 'Enter a valid email',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      autofillHints: [_signUp ? AutofillHints.newPassword : AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          tooltip: _obscure ? 'Show password' : 'Hide password',
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => (v ?? '').length >= 6 ? null : 'At least 6 characters',
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 14),
                      Text(_message!,
                          style: TextStyle(color: _messageIsError ? Theme.of(context).colorScheme.error : c.good)),
                    ],
                    const SizedBox(height: 20),
                    _busy
                        ? const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
                        : GradientButton(label: _signUp ? 'Create account' : 'Sign in', onPressed: _submit),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _busy ? null : () => setState(() => _signUp = !_signUp),
                      child: Text(_signUp ? 'I already have an account' : 'New here? Create an account'),
                    ),
                    if (!widget.linking) ...[
                      const SizedBox(height: 8),
                      Row(children: [
                        const Expanded(child: Divider()),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('or', style: context.text.bodySmall)),
                        const Expanded(child: Divider()),
                      ]),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _busy ? null : () => context.read<AppState>().continueAsGuest(),
                        icon: const Icon(Icons.person_outline_rounded),
                        label: const Text('Continue as guest'),
                      ),
                      const SizedBox(height: 8),
                      Text('Guest progress stays on this device. You can link an account later in Settings.',
                          textAlign: TextAlign.center, style: context.text.bodySmall),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
