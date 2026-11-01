import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/app_icons.dart';

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

  /// Set when the account exists but its email is not confirmed yet.
  String? _pendingEmail;
  int _resendIn = 0;
  Timer? _cooldown;

  @override
  void dispose() {
    _cooldown?.cancel();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _cooldown?.cancel();
    setState(() => _resendIn = 60);
    _cooldown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _resendIn <= 1) {
        t.cancel();
        if (mounted) setState(() => _resendIn = 0);
        return;
      }
      setState(() => _resendIn--);
    });
  }

  Future<void> _resend() async {
    final email = _pendingEmail;
    if (email == null) return;
    try {
      await context.read<AppState>().resendConfirmation(email);
      if (!mounted) return;
      _startCooldown();
      setState(() {
        _message = 'Đã gửi lại. Có thể mất vài phút – hãy xem cả mục Thư rác (Spam) và Quảng cáo.';
        _messageIsError = false;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _message = _describe(e);
        _messageIsError = true;
      });
    }
  }

  static String _describe(AuthException e) {
    final code = e.code ?? '';
    if (code.contains('rate_limit') || e.statusCode == '429') {
      return 'Đã gửi quá nhiều email gần đây. Dịch vụ email có sẵn của Supabase chỉ cho phép vài email mỗi giờ. '
          'Hãy đợi một lúc, hoặc tắt xác nhận email cho dự án này (xem bên dưới).';
    }
    if (code == 'invalid_credentials') return 'Sai email hoặc mật khẩu.';
    return e.message;
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final state = context.read<AppState>();
    if (state.supabase == null) {
      setState(() {
        _message = 'Hiện chưa thể dùng tài khoản. Bạn có thể tiếp tục với tư cách khách.';
        _messageIsError = true;
      });
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      if (_signUp) {
        final result = await state.signUp(_email.text, _password.text);
        if (!mounted) return;
        switch (result) {
          case SignUpResult.signedIn:
            if (widget.linking) Navigator.of(context).pop();
          case SignUpResult.confirmEmail:
            _startCooldown();
            setState(() {
              _pendingEmail = _email.text.trim();
              _signUp = false;
            });
          case SignUpResult.alreadyRegistered:
            setState(() {
              _signUp = false;
              _message = 'Email này đã có tài khoản. Hãy đăng nhập bằng mật khẩu của tài khoản đó.';
              _messageIsError = true;
            });
        }
      } else {
        await state.signIn(_email.text, _password.text);
        if (!mounted) return;
        if (widget.linking) Navigator.of(context).pop();
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.code == 'email_not_confirmed') {
          _pendingEmail = _email.text.trim();
          _message = null;
        } else {
          _message = _describe(e);
          _messageIsError = true;
        }
      });
    } catch (e) {
      setState(() {
        _message = 'Không kết nối được máy chủ. Hãy kiểm tra mạng, hoặc tiếp tục với tư cách khách.';
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
      appBar: widget.linking ? AppBar(title: const Text('Đồng bộ tiến độ')) : null,
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
                      Center(child: Image.asset('assets/images/app_icon.png', width: 104, height: 104)),
                      const SizedBox(height: 20),
                      Text('Iemanihongo', textAlign: TextAlign.center, style: context.text.headlineMedium),
                      const SizedBox(height: 6),
                      Text(
                        'Tiếng Nhật từ N5 đến N1: thẻ từ, trắc nghiệm\nvà một bài ngữ pháp ngắn mỗi ngày.',
                        textAlign: TextAlign.center,
                        style: context.text.bodyMedium?.copyWith(color: c.muted),
                      ),
                      const SizedBox(height: 28),
                    ] else ...[
                      Text(
                        'Tạo tài khoản hoặc đăng nhập để sao lưu tiến độ và đồng bộ giữa các thiết bị.',
                        style: context.text.bodyMedium?.copyWith(color: c.muted),
                      ),
                      const SizedBox(height: 20),
                    ],
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(AppIcons.mail)),
                      validator: (v) =>
                          v != null && RegExp(r'^\S+@\S+\.\S+$').hasMatch(v.trim()) ? null : 'Hãy nhập email hợp lệ',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      autofillHints: [_signUp ? AutofillHints.newPassword : AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: const Icon(AppIcons.lock),
                        suffixIcon: IconButton(
                          tooltip: _obscure ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                          icon: Icon(_obscure ? AppIcons.eye : AppIcons.eyeOff),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => (v ?? '').length >= 6 ? null : 'Ít nhất 6 ký tự',
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (_pendingEmail != null) ...[
                      const SizedBox(height: 14),
                      _ConfirmEmailPanel(email: _pendingEmail!, resendIn: _resendIn, onResend: _resend),
                    ],
                    if (_message != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _message!,
                        style: TextStyle(color: _messageIsError ? Theme.of(context).colorScheme.error : c.good),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _busy
                        ? const Center(
                            child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()),
                          )
                        : GradientButton(label: _signUp ? 'Tạo tài khoản' : 'Đăng nhập', onPressed: _submit),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _busy ? null : () => setState(() => _signUp = !_signUp),
                      child: Text(_signUp ? 'Tôi đã có tài khoản' : 'Bạn mới? Tạo tài khoản'),
                    ),
                    if (!widget.linking) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('hoặc', style: context.text.bodySmall),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _busy ? null : () => context.read<AppState>().continueAsGuest(),
                        icon: const Icon(AppIcons.guest),
                        label: const Text('Tiếp tục với tư cách khách'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tiến độ của khách chỉ lưu trên máy này. Bạn có thể liên kết tài khoản sau trong Cài đặt.',
                        textAlign: TextAlign.center,
                        style: context.text.bodySmall,
                      ),
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

/// Explains the confirmation step and why the email may not arrive.
class _ConfirmEmailPanel extends StatelessWidget {
  const _ConfirmEmailPanel({required this.email, required this.resendIn, required this.onResend});

  final String email;
  final int resendIn;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SoftCard(
      tone: PanelTone.sage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(AppIcons.mail, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text('Xác nhận email', style: context.text.titleMedium)),
            ],
          ),
          const SizedBox(height: 6),
          Text('Supabase sẽ gửi đường dẫn xác nhận tới $email. Hãy mở đường dẫn đó rồi đăng nhập tại đây.'),
          const SizedBox(height: 8),
          Text(
            'Không nhận được? Hãy xem Thư rác/Quảng cáo. Email có sẵn của Supabase chỉ gửi vài thư mỗi giờ, '
            'và với dự án mới chỉ gửi cho thành viên nhóm dự án. Với app cá nhân, cách đơn giản nhất là '
            'tắt xác nhận email: trang quản trị Supabase → Authentication → Sign In / Providers → Email → '
            'tắt "Confirm email", rồi đăng nhập. (Hoặc kết nối SMTP riêng tại Authentication → Emails.)',
            style: context.text.bodySmall,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: resendIn > 0 ? null : onResend,
            icon: Icon(AppIcons.retry, color: c.clay),
            label: Text(resendIn > 0 ? 'Gửi lại sau $resendIn giây' : 'Gửi lại email xác nhận'),
          ),
        ],
      ),
    );
  }
}
