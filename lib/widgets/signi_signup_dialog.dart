import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:mbb_agrotech_website/widgets/customToast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants/colors.dart';
import '../widgets/custom_loading.dart';
import '../utils/helpers/helper_functions.dart';
import 'dart:ui';

class SigningSignupDialog extends StatefulWidget {
  const SigningSignupDialog({super.key, required Null Function() onSuccess});

  @override
  State<SigningSignupDialog> createState() => _SigningSignupDialogState();
}

class _SigningSignupDialogState extends State<SigningSignupDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return SingleChildScrollView(
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Center(
            child: SizedBox(
              width: 400,
              child: Dialog(
                insetPadding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: dark
                            ? Colors.black.withOpacity(0.6)
                            : Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: dark
                              ? Colors.white.withOpacity(0.2)
                              : Colors.black.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Sign In / Sign Up',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: dark ? Colors.white : TColors.dark,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 5.0,
                            ),
                            decoration: BoxDecoration(
                              color: dark
                                  ? Colors.black.withOpacity(0.4)
                                  : Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: dark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.1),
                              ),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              isScrollable: false,
                              unselectedLabelColor: dark
                                  ? TColors.white.withOpacity(0.6)
                                  : TColors.black.withOpacity(0.6),
                              labelColor: TColors.white,
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              unselectedLabelStyle: TextStyle(fontSize: 12),
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: TColors.primary,
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicatorPadding: EdgeInsets.symmetric(
                                horizontal: 3.0,
                                vertical: 3.0,
                              ),
                              labelPadding: EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              dividerColor: Colors.transparent,
                              tabs: const [
                                Tab(text: 'Sign In'),
                                Tab(text: 'Sign Up'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                          SizedBox(
                            height: 400,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _SignInTab(dark: dark),
                                _SignUpTab(dark: dark),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 20,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dark
                        ? Colors.black.withOpacity(0.6)
                        : Colors.white.withOpacity(0.8),
                  ),
                  child: Icon(
                    Icons.close,
                    color: dark ? TColors.light : TColors.dark,
                    size: 24,
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

class _SignInTab extends StatefulWidget {
  final bool dark;

  const _SignInTab({required this.dark});

  @override
  State<_SignInTab> createState() => _SignInTabState();
}

class _SignInTabState extends State<_SignInTab> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  InputDecoration _inputDecoration(String hintText, IconData icon) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: widget.dark
            ? Colors.white.withOpacity(0.7)
            : Colors.black.withOpacity(0.6),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      prefixIcon: Icon(icon, color: TColors.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: widget.dark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: widget.dark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      filled: true,
      fillColor: widget.dark
          ? Colors.black.withOpacity(0.4)
          : Colors.white.withOpacity(0.6),
      suffixIcon: hintText.toLowerCase().contains('password')
          ? IconButton(
              icon: Icon(
                _isPasswordVisible ? Iconsax.eye : Iconsax.eye_slash,
                color: TColors.primary,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            )
          : null,
    );
  }

  Future<void> _handleSignIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      CustomToast.warning(context, 'Please fill all fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.session != null) {
        Navigator.of(context).pop(); // Close dialog on success
      }
    } on AuthException {
      CustomToast.error(context, 'Invalid Credentials, please try again');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: widget.dark ? Colors.white : Colors.black,
            ),
            decoration: _inputDecoration('Email Address', Iconsax.sms),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: widget.dark ? Colors.white : Colors.black,
            ),
            decoration: _inputDecoration('Password', Iconsax.lock),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    activeColor: TColors.primary,
                    value: _rememberMe,
                    onChanged: (bool? value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                  ),
                  Text(
                    'Remember Me',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: widget.dark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to forgot password screen
                },
                child: Text(
                  'Forgot Password?',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: TColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: BorderSide(color: TColors.primary),
                    backgroundColor: widget.dark
                        ? Colors.black.withOpacity(0.4)
                        : Colors.white.withOpacity(0.6),
                  ),
                  child: Text(
                    'Cancel',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: TColors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleSignIn,
                  child: _isLoading
                      ? const CustomLoadingWidget()
                      : Text(
                          'Sign In',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SignUpTab extends StatefulWidget {
  final bool dark;

  const _SignUpTab({required this.dark});

  @override
  State<_SignUpTab> createState() => _SignUpTabState();
}

class _SignUpTabState extends State<_SignUpTab> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isTermsAccepted = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final RegExp _emailRegExp = RegExp(
    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
  );

  InputDecoration _inputDecoration(String hintText, IconData icon) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: widget.dark
            ? Colors.white.withOpacity(0.7)
            : Colors.black.withOpacity(0.6),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      prefixIcon: Icon(icon, color: TColors.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: widget.dark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: widget.dark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      filled: true,
      fillColor: widget.dark
          ? Colors.black.withOpacity(0.4)
          : Colors.white.withOpacity(0.6),
      suffixIcon: hintText.toLowerCase().contains('password')
          ? IconButton(
              icon: Icon(
                _isPasswordVisible ? Iconsax.eye : Iconsax.eye_slash,
                color: TColors.primary,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            )
          : null,
    );
  }

  Future<void> _handleRegistration() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        !_emailRegExp.hasMatch(_emailController.text) ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _confirmPasswordController.text != _passwordController.text ||
        !_isTermsAccepted) {
      CustomToast.warning(
        context,
        'Please fill all fields correctly and accept terms',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'first_name': firstName, 'last_name': lastName},
      );

      if (response.user != null) {
        CustomToast.success(
          context,
          'Registration successful! Please check your email.',
        );
        Navigator.of(context).pop(); // Close dialog on success
      }
    } on AuthException {
      CustomToast.error(context, 'Error');
    } catch (e) {
      CustomToast.error(context, 'Unexpected error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _firstNameController,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: widget.dark ? Colors.white : Colors.black,
                  ),
                  decoration: _inputDecoration('First Name', Iconsax.user),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _lastNameController,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: widget.dark ? Colors.white : Colors.black,
                  ),
                  decoration: _inputDecoration('Last Name', Iconsax.user),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: widget.dark ? Colors.white : Colors.black,
            ),
            decoration: _inputDecoration('Email Address', Iconsax.message),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: widget.dark ? Colors.white : Colors.black,
            ),
            decoration: _inputDecoration('Password', Iconsax.lock),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmPasswordController,
            obscureText: !_isPasswordVisible,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: widget.dark ? Colors.white : Colors.black,
            ),
            decoration: _inputDecoration('Confirm Password', Iconsax.lock),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: _isTermsAccepted,
                onChanged: (value) {
                  setState(() {
                    _isTermsAccepted = value ?? false;
                  });
                },
                activeColor: TColors.primary,
              ),
              Expanded(
                child: Text(
                  'By registering, you agree to our Privacy Policy and Terms & Conditions.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: widget.dark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: BorderSide(color: TColors.primary),
                    backgroundColor: widget.dark
                        ? Colors.black.withOpacity(0.4)
                        : Colors.white.withOpacity(0.6),
                  ),
                  child: Text(
                    'Cancel',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: TColors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTermsAccepted
                        ? TColors.primary
                        : widget.dark
                        ? Colors.black.withOpacity(0.4)
                        : Colors.white.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _isTermsAccepted && !_isLoading
                      ? _handleRegistration
                      : null,
                  child: _isLoading
                      ? const CustomLoadingWidget()
                      : Text(
                          'Register',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
