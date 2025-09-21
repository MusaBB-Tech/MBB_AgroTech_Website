import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:mbb_agrotech_website/widgets/customToast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants/colors.dart';
import '../widgets/custom_loading.dart';
import '../utils/helpers/helper_functions.dart';


Future<void> showChangePasswordDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) => const ChangePasswordDialog(),
  );
}

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  _ChangePasswordDialogState createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isLoading = false;
  bool showOldPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  Future<void> _resetPassword() async {
    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      CustomToast.error(
        context,
        'New password and confirm password do not match.',
      );
      return;
    }

    if (newPassword.isEmpty || oldPassword.isEmpty || confirmPassword.isEmpty) {
      CustomToast.warning(context, 'Please fill in all fields.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        CustomToast.error(context, 'No user logged in.');
        return;
      }

      await supabase.auth.signInWithPassword(
        email: user.email!,
        password: oldPassword,
      );

      await supabase.auth.updateUser(UserAttributes(password: newPassword));

      CustomToast.success(context, 'Password updated successfully.');
      Navigator.of(context).pop();
    } catch (e) {
      CustomToast.error(context, 'An unexpected error occurred.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;

    final padding = isDesktop
        ? 32.0
        : isTablet
        ? 24.0
        : 16.0;
    final fontSizeTitle = isDesktop
        ? 24.0
        : isTablet
        ? 20.0
        : 18.0;
    final fontSizeField = isDesktop
        ? 16.0
        : isTablet
        ? 14.0
        : 12.0;
    final buttonPaddingVertical = isDesktop
        ? 16.0
        : isTablet
        ? 14.0
        : 12.0;
    final dialogWidth = isDesktop
        ? 500.0
        : isTablet
        ? 400.0
        : 300.0;

    return AlertDialog(
      backgroundColor: dark ? TColors.darkContainer : TColors.lightContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.all(padding),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Password',
                style: GoogleFonts.poppins(
                  fontSize: fontSizeTitle,
                  fontWeight: FontWeight.w700,
                  color: dark ? TColors.white : TColors.black,
                ),
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                controller: oldPasswordController,
                label: 'Old Password',
                isPasswordVisible: showOldPassword,
                toggleVisibility: () {
                  setState(() {
                    showOldPassword = !showOldPassword;
                  });
                },
                fontSize: fontSizeField,
                dark: dark,
                isDesktop: isDesktop,
                isTablet: isTablet,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: newPasswordController,
                label: 'New Password',
                isPasswordVisible: showNewPassword,
                toggleVisibility: () {
                  setState(() {
                    showNewPassword = !showNewPassword;
                  });
                },
                fontSize: fontSizeField,
                dark: dark,
                isDesktop: isDesktop,
                isTablet: isTablet,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: confirmPasswordController,
                label: 'Confirm Password',
                isPasswordVisible: showConfirmPassword,
                toggleVisibility: () {
                  setState(() {
                    showConfirmPassword = !showConfirmPassword;
                  });
                },
                fontSize: fontSizeField,
                dark: dark,
                isDesktop: isDesktop,
                isTablet: isTablet,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontSize: fontSizeField,
                        color: TColors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: isDesktop
                        ? 160
                        : isTablet
                        ? 140
                        : 120,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: TColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: buttonPaddingVertical,
                          horizontal: 20,
                        ),
                        elevation: 0,
                      ),
                      onPressed: isLoading ? null : _resetPassword,
                      child: isLoading
                          ? const CustomLoadingWidget(size: 20)
                          : Text(
                              'Reset Password',
                              style: GoogleFonts.poppins(
                                fontSize: fontSizeField,
                                fontWeight: FontWeight.w500,
                                color: TColors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isPasswordVisible,
    required VoidCallback toggleVisibility,
    required double fontSize,
    required bool dark,
    required bool isDesktop,
    required bool isTablet,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isPasswordVisible,
      style: GoogleFonts.poppins(
        fontSize: fontSize,
        color: dark ? TColors.white : TColors.black,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: dark ? TColors.darkContainer : TColors.lightContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: TColors.grey.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: TColors.primary, width: 2),
        ),
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          fontSize: fontSize,
          color: TColors.textsecondary,
        ),
        prefixIcon: Icon(
          Iconsax.lock,
          color: TColors.primary,
          size: isDesktop
              ? 24
              : isTablet
              ? 22
              : 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Iconsax.eye : Iconsax.eye_slash,
            color: TColors.primary,
            size: isDesktop
                ? 24
                : isTablet
                ? 22
                : 20,
          ),
          onPressed: toggleVisibility,
        ),
      ),
    );
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
