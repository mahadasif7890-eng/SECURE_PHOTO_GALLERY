import 'package:flutter/material.dart';
import '../widgets/google_photos_logo.dart';
import 'main_navigation_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _agreeToTerms = true;

  final TextEditingController _emailController = TextEditingController(text: 'alex@gmail.com');
  final TextEditingController _passwordController = TextEditingController(text: '12ac34ed56tG');
  final TextEditingController _nameController = TextEditingController(text: 'Alex Johnson');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _proceedToApp() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim, secAnim) => const MainNavigationScreen(),
        transitionsBuilder: (context, anim, secAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgInputColor = isDark ? const Color(0xFF1E2024) : const Color(0xFFF1F3F4);
    final borderColor = isDark ? const Color(0xFF303338) : const Color(0xFFE0E3E7);
    final primaryButtonColor = isDark ? Colors.white : const Color(0xFF1F1F1F);
    final primaryButtonTextColor = isDark ? const Color(0xFF1F1F1F) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Back button
              GestureDetector(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2024) : const Color(0xFFF1F3F4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                    size: 28,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Logo & App Title
              Center(
                child: Column(
                  children: [
                    const GooglePhotosLogo(size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Secure Photos',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isLogin ? 'Welcome back to your private gallery' : 'Create an encrypted vault account',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: isDark ? Colors.white60 : const Color(0xFF5F6368),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Segmented Toggle Pill (Log in | Sign up)
              Center(
                child: Container(
                  width: 270,
                  height: 48,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2024) : const Color(0xFFF1F3F4),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isLogin = true;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: _isLogin
                                  ? (isDark ? const Color(0xFF2E3036) : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: _isLogin
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Log in',
                              style: TextStyle(
                                color: _isLogin
                                    ? (isDark ? Colors.white : const Color(0xFF1F1F1F))
                                    : (isDark ? Colors.white60 : const Color(0xFF5F6368)),
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isLogin = false;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: !_isLogin
                                  ? (isDark ? const Color(0xFF2E3036) : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: !_isLogin
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                color: !_isLogin
                                    ? (isDark ? Colors.white : const Color(0xFF1F1F1F))
                                    : (isDark ? Colors.white60 : const Color(0xFF5F6368)),
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // If Sign up, Full Name field
              if (!_isLogin) ...[
                Text(
                  'Full Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: bgInputColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Alex Johnson',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Email Address
              Text(
                'Email Address',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: bgInputColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'alex@gmail.com',
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Password
              Text(
                'Password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: bgInputColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '12ac34ed56tG',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Terms & Privacy Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    activeColor: const Color(0xFF1F1F1F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    onChanged: (val) {
                      setState(() {
                        _agreeToTerms = val ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: 'I agree with ',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms, Privacy Policy.',
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Log In / Sign Up Button (Themed)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _proceedToApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryButtonColor,
                    foregroundColor: primaryButtonTextColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 1,
                  ),
                  child: Text(
                    _isLogin ? 'Log In' : 'Sign Up',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Divider "Or Continue with"
              Row(
                children: [
                  Expanded(child: Divider(color: borderColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'Or Continue with',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: borderColor)),
                ],
              ),

              const SizedBox(height: 22),

              // Social Auth Buttons (Google & Apple)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _proceedToApp,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const GooglePhotosLogo(size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Google',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                              color: isDark ? Colors.white : const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _proceedToApp,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.apple,
                            size: 22,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Apple',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                              color: isDark ? Colors.white : const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Footer Switch Link
              Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: RichText(
                    text: TextSpan(
                      text: _isLogin ? 'Create New Account? ' : 'Already have an account? ',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                      ),
                      children: [
                        TextSpan(
                          text: _isLogin ? 'Sign up' : 'Log in',
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
