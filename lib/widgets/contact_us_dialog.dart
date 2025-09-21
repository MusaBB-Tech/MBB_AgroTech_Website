import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:mbb_agrotech_website/widgets/customToast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants/colors.dart';
import '../widgets/custom_loading.dart';

import '../utils/helpers/helper_functions.dart';
import 'dart:ui';

class ContactUsDialog extends StatefulWidget {
  const ContactUsDialog({super.key});

  @override
  State<ContactUsDialog> createState() => _ContactUsDialogState();
}

class _ContactUsDialogState extends State<ContactUsDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  // Supabase client
  final SupabaseClient _supabase = Supabase.instance.client;

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
                          // Company Information Header
                          Column(
                            children: [
                              Text(
                                'MBB Agrotech',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: TColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'Growing Smart, Feeding the Future',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: dark
                                          ? Colors.white70
                                          : TColors.darkGrey,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Contact Form Title
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Contact Our Team',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: dark ? Colors.white : TColors.dark,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Contact Form
                          _buildContactForm(dark),

                          const SizedBox(height: 20),

                          // Additional Contact Info
                          _buildContactInfo(dark),

                          const SizedBox(height: 20),

                          // Submit Button
                          _buildSubmitButton(dark),
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

  Widget _buildContactForm(bool dark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _nameController,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: dark ? Colors.white : Colors.black,
          ),
          decoration: _inputDecoration('Your Name', Iconsax.user, dark),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: dark ? Colors.white : Colors.black,
          ),
          decoration: _inputDecoration('Email Address', Iconsax.sms, dark),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _messageController,
          maxLines: 5,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: dark ? Colors.white : Colors.black,
          ),
          decoration: _inputDecoration(
            'Your Message',
            Iconsax.message_text,
            dark,
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo(bool dark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.call, size: 16, color: TColors.primary),
            const SizedBox(width: 8),
            Text(
              '+234 704 630 6129',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: dark ? Colors.white70 : TColors.darkGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.sms, size: 16, color: TColors.primary),
            const SizedBox(width: 8),
            Text(
              'mbbagrotech@gmail.com',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: dark ? Colors.white70 : TColors.darkGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool dark) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              side: BorderSide(color: TColors.primary),
              backgroundColor: dark
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
            onPressed: _isLoading ? null : _submitContactForm,
            child: _isLoading
                ? const CustomLoadingWidget()
                : Text(
                    'Send Message',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hintText, IconData icon, bool dark) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: dark
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
          color: dark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: dark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      filled: true,
      fillColor: dark
          ? Colors.black.withOpacity(0.4)
          : Colors.white.withOpacity(0.6),
    );
  }

  Future<void> _submitContactForm() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _messageController.text.isEmpty) {
      CustomToast.warning(context, 'Please fill all fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Insert the contact form data into Supabase
      final response = await _supabase.from('contact_submissions').insert({
        'name': _nameController.text,
        'email': _emailController.text,
        'message': _messageController.text,
        'submitted_at': DateTime.now().toIso8601String(),
      });

      if (response != null) {
        throw response.error!;
      }
      Navigator.of(context).pop();
      CustomToast.success(context, "Your message has been sent successfully!");
    } catch (e) {
      CustomToast.success(context, "Failed to send message ");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
