import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/constants/colors.dart';
import '../utils/helpers/helper_functions.dart';
import '../widgets/changing_password_dialog.dart';
import '../widgets/footer.dart';
import '../utils/constants/nigeria_states.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  Map<String, dynamic>? _userProfile;
  List<Map<String, dynamic>> _orders = [];
  bool _isLoadingProfile = true;
  bool _isLoadingOrders = true;
  bool _hasError = false;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _shippingAddressController = TextEditingController();
  final _dialogContactNameController = TextEditingController();
  final _dialogPhoneController = TextEditingController();
  final _dialogStreetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchOrders();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoadingProfile = false;
        });
        return;
      }

      final response = await _supabase
          .from('profiles')
          .select('first_name, email, phone, shipping_address')
          .eq('id', user.id)
          .maybeSingle();

      setState(() {
        _userProfile =
            response ??
            {
              'first_name': user.email?.split('@')[0] ?? 'Guest',
              'email': user.email,
              'phone': '',
              'shipping_address': '',
            };
        _nameController.text = _userProfile!['first_name'] ?? '';
        _emailController.text = _userProfile!['email'] ?? '';
        _phoneController.text = _userProfile!['phone'] ?? '';
        _shippingAddressController.text =
            _userProfile!['shipping_address'] ?? '';
        _isLoadingProfile = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProfile = false;
        _hasError = true;
      });
      if (mounted) {
        _showSnackbar('Error fetching profile: $e');
      }
    }
  }

  Future<void> _fetchOrders() async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      _showSnackbar('Please log in to view your orders.');
      setState(() {
        _isLoadingOrders = false;
        _hasError = true;
      });
      return;
    }

    try {
      final response = await _supabase
          .from('order_headers')
          .select('''
            id, total_amount, status, payment_status, created_at,
            order_items (id, product_id, quantity, price, name, image)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _orders = List<Map<String, dynamic>>.from(response);
          _isLoadingOrders = false;
          _hasError = false;
        });
      }
    } catch (error) {
      debugPrint('Error fetching orders: $error');
      _showSnackbar('Failed to load orders. Please try again.');
      if (mounted) {
        setState(() {
          _isLoadingOrders = false;
          _hasError = true;
        });
      }
    }
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.poppins()),
          backgroundColor: TColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('profiles').upsert({
        'id': user.id,
        'first_name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'shipping_address': _shippingAddressController.text,
      });

      setState(() {
        _isEditing = false;
        _userProfile = {
          'first_name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'shipping_address': _shippingAddressController.text,
        };
      });

      if (mounted) {
        _showSnackbar('Profile updated successfully');
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Error updating profile');
      }
    }
  }

  void _changePassword() {
    showChangePasswordDialog(context);
  }

  Future<void> _showShippingAddressDialog() async {
    final dark = THelperFunctions.isDarkMode(context);
    bool isDialogLoading = false;
    String? selectedState;
    String? selectedLocalGov;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, dialogSetState) => AlertDialog(
          backgroundColor: dark
              ? TColors.darkContainer
              : TColors.lightContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Edit Shipping Address',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: dark ? TColors.white : TColors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _dialogContactNameController,
                  decoration: _inputDecoration('Contact Name', Iconsax.user),
                  style: GoogleFonts.poppins(
                    color: dark ? TColors.white : TColors.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _dialogPhoneController,
                  decoration: _inputDecoration('Phone Number', Iconsax.call),
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.poppins(
                    color: dark ? TColors.white : TColors.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  dropdownColor: dark
                      ? TColors.darkContainer
                      : TColors.lightContainer,
                  value: selectedState,
                  decoration: _inputDecoration('State', Iconsax.map),
                  style: GoogleFonts.poppins(
                    color: dark ? TColors.white : TColors.black,
                    fontSize: 16,
                  ),
                  items: nigeriaStatesAndLGAs.keys.map((String state) {
                    return DropdownMenuItem<String>(
                      value: state,
                      child: Text(
                        state,
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    dialogSetState(() {
                      selectedState = newValue;
                      selectedLocalGov = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  dropdownColor: dark
                      ? TColors.darkContainer
                      : TColors.lightContainer,
                  value: selectedLocalGov,
                  decoration: _inputDecoration(
                    'Local Gov\'n',
                    Iconsax.building,
                  ),
                  style: GoogleFonts.poppins(
                    color: dark ? TColors.white : TColors.black,
                    fontSize: 16,
                  ),
                  items: selectedState != null
                      ? nigeriaStatesAndLGAs[selectedState]!.map((String lga) {
                          return DropdownMenuItem<String>(
                            value: lga,
                            child: Text(
                              lga,
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                          );
                        }).toList()
                      : [],
                  onChanged: (String? newValue) {
                    dialogSetState(() {
                      selectedLocalGov = newValue;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _dialogStreetController,
                  decoration: _inputDecoration(
                    'Street Address',
                    Iconsax.location,
                  ),
                  style: GoogleFonts.poppins(
                    color: dark ? TColors.white : TColors.black,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: TColors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: isDialogLoading
                  ? null
                  : () async {
                      if (_dialogContactNameController.text.isEmpty ||
                          _dialogPhoneController.text.isEmpty ||
                          selectedState == null ||
                          selectedLocalGov == null ||
                          _dialogStreetController.text.isEmpty) {
                        _showSnackbar('Please fill all fields');
                        return;
                      }

                      dialogSetState(() {
                        isDialogLoading = true;
                      });

                      final shippingAddress = _buildShippingAddressString(
                        _dialogContactNameController.text,
                        _dialogPhoneController.text,
                        selectedState!,
                        selectedLocalGov!,
                        _dialogStreetController.text,
                      );
                      try {
                        await _supabase
                            .from('profiles')
                            .update({'shipping_address': shippingAddress})
                            .eq('id', _supabase.auth.currentUser!.id);

                        setState(() {
                          _shippingAddressController.text = shippingAddress;
                          _userProfile?['shipping_address'] = shippingAddress;
                        });
                        _showSnackbar('Shipping address updated successfully');
                        Navigator.pop(context);
                      } catch (e) {
                        _showSnackbar('Failed to update shipping address: $e');
                      } finally {
                        dialogSetState(() {
                          isDialogLoading = false;
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: TColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                elevation: 0,
              ),
              child: isDialogLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: TColors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Save',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildShippingAddressString(
    String contactName,
    String phone,
    String state,
    String localGov,
    String street,
  ) {
    return '$contactName, $phone, $state, $localGov, $street';
  }

  TextStyle _headlineMedium(
    BuildContext context,
    bool isDesktop,
    bool isTablet,
  ) {
    return GoogleFonts.poppins(
      fontSize: isDesktop
          ? 32
          : isTablet
          ? 28
          : 24,
      fontWeight: FontWeight.w700,
      color: THelperFunctions.isDarkMode(context)
          ? TColors.white
          : TColors.black,
      height: 1.3,
    );
  }

  TextStyle _bodyLarge(BuildContext context, bool isDesktop, bool isTablet) {
    return GoogleFonts.poppins(
      fontSize: isDesktop
          ? 18
          : isTablet
          ? 16
          : 14,
      color: TColors.textsecondary,
      height: 1.5,
    );
  }

  TextStyle _bodyMedium(BuildContext context, bool isDesktop, bool isTablet) {
    return GoogleFonts.poppins(
      fontSize: isDesktop
          ? 16
          : isTablet
          ? 14
          : 12,
      color: TColors.textsecondary,
      height: 1.5,
    );
  }

  Widget _buildShimmerEffect(bool isDesktop, bool isTablet) {
    return Shimmer.fromColors(
      baseColor: THelperFunctions.isDarkMode(context)
          ? TColors.darkGrey
          : TColors.softgrey,
      highlightColor: TColors.grey,
      child: Column(
        children: [
          Container(
            width: 200,
            height: isDesktop
                ? 28
                : isTablet
                ? 24
                : 20,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: isDesktop ? 70 : 60,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: isDesktop ? 70 : 60,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: isDesktop ? 70 : 60,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderShimmerEffect(bool isDesktop, bool isTablet) {
    return Shimmer.fromColors(
      baseColor: THelperFunctions.isDarkMode(context)
          ? TColors.darkGrey
          : TColors.softgrey,
      highlightColor: TColors.grey,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Container(
                width: isDesktop ? 50 : 40,
                height: isDesktop ? 50 : 40,
                color: Colors.white,
              ),
              title: Container(
                width: 100,
                height: isDesktop ? 18 : 16,
                color: Colors.white,
              ),
              subtitle: Container(
                width: 150,
                height: isDesktop ? 16 : 14,
                color: Colors.white,
              ),
              trailing: Container(
                width: 80,
                height: isDesktop ? 18 : 16,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;
    final paddingHorizontal = isDesktop
        ? 80.0
        : isTablet
        ? 40.0
        : 16.0;
    final paddingVertical = isDesktop
        ? 40.0
        : isTablet
        ? 32.0
        : 24.0;

    return Scaffold(
      backgroundColor: dark ? TColors.dark : TColors.light,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: dark ? TColors.darkContainer : TColors.lightContainer,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(
                horizontal: paddingHorizontal,
                vertical: paddingVertical,
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: isDesktop
                        ? 80
                        : isTablet
                        ? 60
                        : 40,
                    backgroundColor: TColors.primary,
                    child: Text(
                      _userProfile?['first_name']?.isNotEmpty == true
                          ? _userProfile!['first_name'][0].toUpperCase()
                          : 'U',
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop
                            ? 40
                            : isTablet
                            ? 32
                            : 24,
                        color: TColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _userProfile?['first_name'] ?? 'Guest User',
                    style: GoogleFonts.poppins(
                      fontSize: isDesktop
                          ? 28
                          : isTablet
                          ? 24
                          : 20,
                      fontWeight: FontWeight.w700,
                      color: dark ? TColors.white : TColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _userProfile?['email'] ?? '',
                    style: _bodyMedium(context, isDesktop, isTablet).copyWith(
                      color: dark
                          ? TColors.white.withOpacity(0.7)
                          : TColors.textsecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: paddingHorizontal,
                vertical: paddingVertical,
              ),
              child: isMobile
                  ? _buildMobileLayout(
                      context,
                      dark,
                      isDesktop,
                      isTablet,
                      paddingHorizontal,
                      paddingVertical,
                    )
                  : _buildTabletDesktopLayout(
                      context,
                      dark,
                      isDesktop,
                      isTablet,
                      paddingHorizontal,
                      paddingVertical,
                    ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    bool dark,
    bool isDesktop,
    bool isTablet,
    double paddingHorizontal,
    double paddingVertical,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Details',
          style: _headlineMedium(context, isDesktop, isTablet),
        ),
        const SizedBox(height: 20),
        _isLoadingProfile
            ? _buildShimmerEffect(isDesktop, isTablet)
            : _userProfile == null
            ? Center(
                child: Text(
                  'No profile data available',
                  style: _bodyMedium(context, isDesktop, isTablet),
                ),
              )
            : _buildProfileCard(dark, isDesktop, isTablet),
        const SizedBox(height: 40),
        Text(
          'Order History',
          style: _headlineMedium(context, isDesktop, isTablet),
        ),
        const SizedBox(height: 20),
        _buildOrderHistory(dark, isDesktop, isTablet),
      ],
    );
  }

  Widget _buildTabletDesktopLayout(
    BuildContext context,
    bool dark,
    bool isDesktop,
    bool isTablet,
    double paddingHorizontal,
    double paddingVertical,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile Details',
                style: _headlineMedium(context, isDesktop, isTablet),
              ),
              const SizedBox(height: 20),
              _isLoadingProfile
                  ? _buildShimmerEffect(isDesktop, isTablet)
                  : _userProfile == null
                  ? Center(
                      child: Text(
                        'No profile data available',
                        style: _bodyMedium(context, isDesktop, isTablet),
                      ),
                    )
                  : _buildProfileCard(dark, isDesktop, isTablet),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order History',
                style: _headlineMedium(context, isDesktop, isTablet),
              ),
              const SizedBox(height: 20),
              _buildOrderHistory(dark, isDesktop, isTablet),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(bool dark, bool isDesktop, bool isTablet) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: dark ? TColors.darkContainer : TColors.lightContainer,
      child: Padding(
        padding: EdgeInsets.all(
          isDesktop
              ? 32
              : isTablet
              ? 24
              : 16,
        ),
        child: _isEditing
            ? Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration('First Name', Iconsax.user),
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop
                            ? 18
                            : isTablet
                            ? 16
                            : 14,
                        color: dark ? TColors.white : TColors.black,
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter your first name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration('Email', Iconsax.sms),
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop
                            ? 18
                            : isTablet
                            ? 16
                            : 14,
                        color: dark ? TColors.white : TColors.black,
                      ),
                      validator: (value) =>
                          value == null || !value.contains('@')
                          ? 'Please enter a valid email'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: _inputDecoration('Phone', Iconsax.call),
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop
                            ? 18
                            : isTablet
                            ? 16
                            : 14,
                        color: dark ? TColors.white : TColors.black,
                      ),
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            !RegExp(r'^\+?\d{10,15}$').hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _isEditing = false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: TColors.grey,
                              side: const BorderSide(color: TColors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: isDesktop
                                    ? 16
                                    : isTablet
                                    ? 14
                                    : 12,
                                horizontal: 20,
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                fontSize: isDesktop
                                    ? 16
                                    : isTablet
                                    ? 14
                                    : 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColors.primary,
                              foregroundColor: TColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: isDesktop
                                    ? 16
                                    : isTablet
                                    ? 14
                                    : 12,
                                horizontal: 20,
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Save',
                              style: GoogleFonts.poppins(
                                fontSize: isDesktop
                                    ? 16
                                    : isTablet
                                    ? 14
                                    : 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _userProfile!['first_name'] ?? 'No Name',
                        style: GoogleFonts.poppins(
                          fontSize: isDesktop
                              ? 24
                              : isTablet
                              ? 20
                              : 18,
                          fontWeight: FontWeight.w700,
                          color: dark ? TColors.white : TColors.black,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Iconsax.edit,
                          color: TColors.primary,
                          size: 24,
                        ),
                        onPressed: () => setState(() => _isEditing = true),
                        style: IconButton.styleFrom(
                          backgroundColor: dark
                              ? TColors.darkContainer
                              : TColors.lightContainer,
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildProfileDetail(
                    Iconsax.sms,
                    _userProfile!['email'] ?? 'No Email',
                    dark,
                    isDesktop,
                    isTablet,
                  ),
                  const SizedBox(height: 12),
                  _buildProfileDetail(
                    Iconsax.call,
                    _userProfile!['phone']?.isNotEmpty == true
                        ? _userProfile!['phone']
                        : 'No Phone',
                    dark,
                    isDesktop,
                    isTablet,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _showShippingAddressDialog,
                    child: _buildProfileDetail(
                      Iconsax.location,
                      _userProfile!['shipping_address']?.isNotEmpty == true
                          ? _userProfile!['shipping_address']
                          : 'No Shipping Address',
                      dark,
                      isDesktop,
                      isTablet,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _changePassword,
                      child: Text(
                        'Change Password',
                        style: GoogleFonts.poppins(
                          fontSize: isDesktop
                              ? 16
                              : isTablet
                              ? 14
                              : 12,
                          color: TColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildOrderHistory(bool dark, bool isDesktop, bool isTablet) {
    return _isLoadingOrders
        ? _buildOrderShimmerEffect(isDesktop, isTablet)
        : _hasError
        ? Center(
            child: Column(
              children: [
                Icon(
                  Iconsax.warning_2,
                  size: isDesktop
                      ? 56
                      : isTablet
                      ? 48
                      : 40,
                  color: dark
                      ? TColors.white.withOpacity(0.6)
                      : TColors.textsecondary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Failed to load orders',
                  style: _bodyMedium(context, isDesktop, isTablet),
                ),
              ],
            ),
          )
        : _orders.isEmpty
        ? Center(
            child: Column(
              children: [
                Icon(
                  Iconsax.box,
                  size: isDesktop
                      ? 56
                      : isTablet
                      ? 48
                      : 40,
                  color: dark
                      ? TColors.white.withOpacity(0.6)
                      : TColors.textsecondary,
                ),
                const SizedBox(height: 8),
                Text(
                  'No orders found',
                  style: _bodyMedium(context, isDesktop, isTablet),
                ),
              ],
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _orders.length,
            itemBuilder: (context, index) {
              final order = _orders[index];
              final items = List<Map<String, dynamic>>.from(
                order['order_items'] ?? [],
              );
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: dark ? TColors.darkContainer : TColors.lightContainer,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ExpansionTile(
                  leading: Icon(
                    Iconsax.box,
                    color: TColors.primary,
                    size: isDesktop ? 32 : 28,
                  ),
                  title: Text(
                    'Order #${order['id']}',
                    style: GoogleFonts.poppins(
                      fontSize: isDesktop
                          ? 18
                          : isTablet
                          ? 16
                          : 14,
                      fontWeight: FontWeight.w600,
                      color: dark ? TColors.white : TColors.black,
                    ),
                  ),
                  subtitle: Text(
                    'Total: ₦${(order['total_amount'] as num).toStringAsFixed(2)} | Placed: ${order['created_at'].toString().substring(0, 10)}',
                    style: _bodyMedium(context, isDesktop, isTablet).copyWith(
                      color: dark
                          ? TColors.white.withOpacity(0.7)
                          : TColors.textsecondary,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: order['status'] == 'Delivered'
                          ? Colors.green.withOpacity(0.1)
                          : order['status'] == 'Processing'
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order['status'],
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 14 : 12,
                        color: order['status'] == 'Delivered'
                            ? Colors.green
                            : order['status'] == 'Processing'
                            ? Colors.orange
                            : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  children: items.map((item) {
                    return ListTile(
                      leading: item['image'] != null && item['image'].isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item['image'],
                                width: isDesktop ? 50 : 40,
                                height: isDesktop ? 50 : 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Iconsax.image,
                                      color: TColors.primary,
                                      size: isDesktop ? 32 : 28,
                                    ),
                              ),
                            )
                          : Icon(
                              Iconsax.image,
                              color: TColors.primary,
                              size: isDesktop ? 32 : 28,
                            ),
                      title: Text(
                        item['name'] ?? 'Unknown Item',
                        style: GoogleFonts.poppins(
                          fontSize: isDesktop
                              ? 16
                              : isTablet
                              ? 14
                              : 12,
                          fontWeight: FontWeight.w500,
                          color: dark ? TColors.white : TColors.black,
                        ),
                      ),
                      subtitle: Text(
                        'Qty: ${item['quantity']} | Price: ₦${(item['price'] as num).toStringAsFixed(2)}',
                        style: _bodyMedium(context, isDesktop, isTablet)
                            .copyWith(
                              color: dark
                                  ? TColors.white.withOpacity(0.7)
                                  : TColors.textsecondary,
                            ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
  }

  InputDecoration _inputDecoration(String label, [IconData? icon]) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: TColors.textsecondary),
      prefixIcon: icon != null ? Icon(icon, color: TColors.primary) : null,
      filled: true,
      fillColor: THelperFunctions.isDarkMode(context)
          ? TColors.darkContainer
          : TColors.lightContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: TColors.primary, width: 2),
      ),
    );
  }

  Widget _buildProfileDetail(
    IconData icon,
    String value,
    bool dark,
    bool isDesktop,
    bool isTablet,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: isDesktop
              ? 24
              : isTablet
              ? 22
              : 20,
          color: TColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isDesktop
                  ? 16
                  : isTablet
                  ? 14
                  : 12,
              color: dark ? TColors.white : TColors.black,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _shippingAddressController.dispose();
    _dialogContactNameController.dispose();
    _dialogPhoneController.dispose();
    _dialogStreetController.dispose();
    super.dispose();
  }
}
