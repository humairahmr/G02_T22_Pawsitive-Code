import 'package:flutter/material.dart';

class CustomerAuthScreen extends StatefulWidget {
  const CustomerAuthScreen({super.key, required this.onSubmit, this.onBack});

  final VoidCallback onSubmit;
  final VoidCallback? onBack;

  @override
  State<CustomerAuthScreen> createState() => _CustomerAuthScreenState();
}

class _CustomerAuthScreenState extends State<CustomerAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isSignUp = false;
  bool _obscure = true;
  bool _agreed = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSignUp && !_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the terms and policy.')),
      );
      return;
    }
    setState(() => _loading = true);
    // TODO: replace with real Firebase/Supabase sign in / sign up
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _loading = false);
    widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: widget.onBack == null
          ? null
          : AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
            ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isSignUp ? 'Get Started Now' : 'Welcome back!',
                      style: theme.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Image.asset(
                      'Assets/image/Logo.png',
                      height: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('LOGO ERROR: $error');
                        return const SizedBox(height: 120);
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSignUp
                          ? 'Sign up to book your photography session'
                          : 'Sign in to book your photography session',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    if (_isSignUp) ...[
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          hintText: 'Enter your name',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter your name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone number',
                          hintText: 'Enter your phone number',
                        ),
                        validator: (v) => (v == null || v.trim().length < 8)
                            ? 'Enter a valid phone number'
                            : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        hintText: 'Enter your email',
                      ),
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'At least 6 characters'
                          : null,
                    ),
                    if (_isSignUp)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _agreed,
                        onChanged: (v) => setState(() => _agreed = v ?? false),
                        title: const Text('I agree to the terms & policy'),
                      ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isSignUp ? 'Signup' : 'Login'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => setState(() => _isSignUp = !_isSignUp),
                      child: Text(
                        _isSignUp
                            ? 'Have an account? Sign In'
                            : 'Don’t have an account? Sign Up',
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
}
