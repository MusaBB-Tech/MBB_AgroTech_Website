import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants/colors.dart';
import '../widgets/custom_loading.dart';
import '../utils/showSnackBar.dart';
import '../utils/helpers/helper_functions.dart';
import 'dart:ui';

class BookConsultationDialog extends StatefulWidget {
  const BookConsultationDialog({super.key});

  @override
  State<BookConsultationDialog> createState() => _BookConsultationDialogState();
}

class _BookConsultationDialogState extends State<BookConsultationDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String? _selectedConsultationType;
  bool _isLoading = false;

  // Supabase client
  final SupabaseClient _supabase = Supabase.instance.client;

  // Consultation types
  final List<String> _consultationTypes = [
    'Hydroponics System Design',
    'Farm Setup Consultation',
    'Crop Selection Advice',
    'Nutrient Management',
    'System Troubleshooting',
    'Commercial Scale Planning',
    'Home Hydroponics Setup',
    'Other Inquiry',
  ];

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Stack(
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
                              'Hydroponics Experts - Book a Consultation',
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

                        // Consultation Form Title
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Schedule Your Consultation',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: dark ? Colors.white : TColors.dark,
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Consultation Form
                        _buildConsultationForm(dark),

                        const SizedBox(height: 20),

                        // Additional Info
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
    );
  }

  Widget _buildConsultationForm(bool dark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
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
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: dark ? Colors.white : Colors.black,
            ),
            decoration: _inputDecoration('Phone Number', Iconsax.call, dark),
          ),
          const SizedBox(height: 12),

          // Replace the existing Consultation Type Dropdown with this:
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: dark
                  ? Colors.black.withOpacity(0.4)
                  : Colors.white.withOpacity(0.6),
              border: Border.all(
                color: dark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              dropdownColor: dark
                  ? Colors.black.withOpacity(0.8)
                  : Colors.white.withOpacity(0.9),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: dark ? Colors.white : Colors.black,
              ),
              value: _selectedConsultationType,
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(Iconsax.book, color: TColors.primary),
                hintText: 'Select Consultation Type',
                hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: dark
                      ? Colors.white.withOpacity(0.7)
                      : Colors.black.withOpacity(0.6),
                ),
              ),
              items: _consultationTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedConsultationType = newValue;
                });
              },
              isExpanded: true,
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _messageController,
            maxLines: 4,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: dark ? Colors.white : Colors.black,
            ),
            decoration: _inputDecoration(
              'Additional Details (Optional)',
              Iconsax.message_text,
              dark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(bool dark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.calendar, size: 16, color: TColors.primary),
            const SizedBox(width: 8),
            Text(
              'Monday - Friday, 9am - 5pm',
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
            onPressed: _isLoading ? null : _submitConsultationRequest,
            child: _isLoading
                ? const CustomLoadingWidget()
                : Text(
                    'Book Consultation',
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

  Future<void> _submitConsultationRequest() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _selectedConsultationType == null) {
      CustomSnackbar.warning(context, 'Please fill all required fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Insert the consultation request into Supabase
      final response = await _supabase.from('consultation_requests').insert({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'consultation_type': _selectedConsultationType,
        'message': _messageController.text,
        'requested_at': DateTime.now().toIso8601String(),
        'status': 'Pending',
      });

      if (response != null) {
        throw response.error!;
      }
      Navigator.of(context).pop();
      CustomToast.success(
        context,
        "Your consultation request has been submitted successfully!",
      );
    } catch (e) {
      CustomToast.error(
        context,
        "Failed to submit consultation request. Please try again.",
      );
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
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
