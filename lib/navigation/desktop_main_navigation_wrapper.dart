import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:mbb_agrotech_website/pages/admin_panel.dart';
import 'package:mbb_agrotech_website/pages/products_screen.dart';
import 'package:mbb_agrotech_website/utils/showSnackBar.dart';
import 'package:mbb_agrotech_website/widgets/signi_signup_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/about_us_page.dart';
import '../pages/cart_screen.dart';
import '../pages/home_page.dart';
import '../pages/profile_screen.dart';
import '../utils/constants/colors.dart';
import '../utils/helpers/helper_functions.dart';
import '../widgets/contact_us_dialog.dart';

class DesktopMainNavigationWrapper extends StatefulWidget {
  final bool? isAdmin;
  final bool isAuthenticated;
  final SupabaseClient supabase;

  const DesktopMainNavigationWrapper({
    super.key,
    required this.isAdmin,
    required this.isAuthenticated,
    required this.supabase,
  });

  @override
  State<DesktopMainNavigationWrapper> createState() =>
      _DesktopMainNavigationWrapperState();
}

class _DesktopMainNavigationWrapperState
    extends State<DesktopMainNavigationWrapper> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  String? _hoveredItem;
  final Map<String, bool> _dropdownOpenStates = {};
  bool _isThemeDropdownOpen = false;
  ThemeMode _currentThemeMode = ThemeMode.system;
  OverlayEntry? _dropdownOverlay;
  OverlayEntry? _themeDropdownOverlay;
  String? _currentDropdown;

  final List<Widget> _pages = const [
    HomePage(),
    ProductsScreen(),
    CartScreen(),
    ProfileScreen(),
    AdminPanel(),
    AboutUsScreen(),
  ];

  final Map<String, List<Map<String, dynamic>>> _dropdownItems = {
    'Home': [
      {
        'title': 'Welcome',
        'subtitle': 'Explore our agricultural solutions',
        'icon': Iconsax.home,
        'color': TColors.primary,
        'action': 'navigate',
        'index': 0,
      },
      {
        'title': 'New Technologies',
        'subtitle': 'Check out our latest innovations',
        'icon': Iconsax.star,
        'color': Colors.blue,
        'action': 'navigate',
        'index': 0,
      },
    ],
    'Products': [
      {
        'title': 'All Products',
        'subtitle': 'Browse our full catalog',
        'icon': Iconsax.shop,
        'color': TColors.primary,
        'action': 'navigate',
        'index': 1,
      },
      {
        'title': 'Hydroponic Systems',
        'subtitle': 'Advanced soilless farming solutions',
        'icon': Iconsax.export,
        'color': Colors.green,
        'action': 'navigate',
        'index': 1,
      },
      {
        'title': 'Smart Sensors',
        'subtitle': 'IoT devices for precision agriculture',
        'icon': Iconsax.cpu,
        'color': Colors.blueAccent,
        'action': 'navigate',
        'index': 1,
      },
    ],
    'Cart': [
      {
        'title': 'View Cart',
        'subtitle': 'Check your selected items',
        'icon': Iconsax.shopping_cart,
        'color': TColors.primary,
        'action': 'navigate',
        'index': 2,
      },
      {
        'title': 'Checkout',
        'subtitle': 'Proceed to payment',
        'icon': Iconsax.card,
        'color': Colors.green,
        'action': 'navigate',
        'index': 2,
      },
    ],
    'Account': [
      {
        'title': 'Profile',
        'subtitle': 'Manage your account details',
        'icon': Iconsax.profile_circle,
        'color': Colors.blue,
        'action': 'navigate',
        'index': 3,
      },
      {
        'title': 'Orders',
        'subtitle': 'Track your orders',
        'icon': Iconsax.box,
        'color': Colors.purple,
        'action': 'navigate',
        'index': 3,
      },
      {
        'title': 'Saved Items',
        'subtitle': 'Your bookmarked products',
        'icon': Iconsax.heart,
        'color': Colors.red,
        'action': 'navigate',
        'index': 3,
      },
      {
        'title': 'Sign Out',
        'subtitle': 'Log out from your account',
        'icon': Iconsax.logout,
        'color': Colors.grey,
        'action': 'signout',
      },
    ],
    'Admin': [
      {
        'title': 'Admin Panel',
        'subtitle': 'Manage system settings',
        'icon': Iconsax.setting_2,
        'color': Colors.blueAccent,
        'action': 'navigate',
        'index': 4,
      },
    ],
    'About Us': [
      {
        'title': 'About Us',
        'subtitle': 'Learn more about MBB Agrotech',
        'icon': Iconsax.info_circle,
        'color': TColors.primary,
        'action': 'navigate',
        'index': 5,
      },
    ],
  };

  void _showSignInDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          SizedBox(width: 500, child: SigningSignupDialog(onSuccess: () {})),
    );
  }

  Future<void> _signOut() async {
    try {
      await widget.supabase.auth.signOut();
      setState(() {
        _currentIndex = 0;
      });
    } catch (e) {
      CustomSnackbar.error(context, 'Sign-out failed');
    }
  }

  void _showDropdown(String label, RenderBox renderBox, double screenWidth) {
    if ((label == 'Cart' || label == 'Account' || label == 'Admin') &&
        !widget.isAuthenticated) {
      CustomSnackbar.error(context, 'Please sign in to access this page');
      return;
    }
    if (label == 'Admin' && widget.isAdmin != true) return;

    _removeDropdown();
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    setState(() {
      _dropdownOpenStates[label] = true;
      _currentDropdown = label;
    });

    final dropdownWidth = screenWidth < 600 ? screenWidth * 0.9 : 280.0;

    _dropdownOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy + size.height,
        width: dropdownWidth,
        child: Material(
          elevation: 0,
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: THelperFunctions.isDarkMode(context)
                      ? Colors.black.withOpacity(0.6)
                      : Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: THelperFunctions.isDarkMode(context)
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _dropdownItems[label]!
                      .map((item) => _buildDropdownItem(item))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_dropdownOverlay!);
  }

  void _showThemeDropdown(RenderBox renderBox, double screenWidth) {
    _removeDropdown();
    _removeThemeDropdown();
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    setState(() => _isThemeDropdownOpen = true);

    final dropdownWidth = screenWidth < 600 ? screenWidth * 0.7 : 180.0;

    _themeDropdownOverlay = OverlayEntry(
      builder: (context) => Positioned(
        right: MediaQuery.of(context).size.width - position.dx - size.width,
        top: position.dy + size.height,
        width: dropdownWidth,
        child: Material(
          elevation: 0,
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: THelperFunctions.isDarkMode(context)
                      ? Colors.black.withOpacity(0.6)
                      : Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: THelperFunctions.isDarkMode(context)
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildThemeDropdownItem(
                      'Light',
                      Iconsax.sun_1,
                      ThemeMode.light,
                    ),
                    _buildThemeDropdownItem(
                      'Dark',
                      Iconsax.moon,
                      ThemeMode.dark,
                    ),
                    _buildThemeDropdownItem(
                      'System',
                      Iconsax.cpu,
                      ThemeMode.system,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_themeDropdownOverlay!);
  }

  Widget _buildThemeDropdownItem(
    String title,
    IconData icon,
    ThemeMode themeMode,
  ) {
    final isSelected = _currentThemeMode == themeMode;
    final dark = THelperFunctions.isDarkMode(context);

    return InkWell(
      onTap: () {
        setState(() {
          _currentThemeMode = themeMode;
          _isThemeDropdownOpen = false;
        });
        _removeThemeDropdown();
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 50),
        decoration: BoxDecoration(
          color: isSelected
              ? TColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? TColors.primary
                  : dark
                  ? TColors.white
                  : TColors.textprimary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? TColors.primary
                      : dark
                      ? TColors.white
                      : TColors.textprimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(Iconsax.tick_circle, size: 16, color: TColors.primary),
          ],
        ),
      ),
    );
  }

  void _removeDropdown() {
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
    _currentDropdown = null;
    setState(() => _dropdownOpenStates.clear());
  }

  void _removeThemeDropdown() {
    _themeDropdownOverlay?.remove();
    _themeDropdownOverlay = null;
    setState(() => _isThemeDropdownOpen = false);
  }

  Widget _buildDropdownItem(Map<String, dynamic> item) {
    final dark = THelperFunctions.isDarkMode(context);

    return InkWell(
      onTap: () {
        _removeDropdown();

        if (!widget.isAuthenticated &&
            (item['title'] == 'View Cart' ||
                item['title'] == 'Checkout' ||
                item['title'] == 'Profile' ||
                item['title'] == 'Orders' ||
                item['title'] == 'Saved Items' ||
                item['title'] == 'Sign Out' ||
                item['title'] == 'Admin Panel')) {
          CustomSnackbar.error(context, 'Please sign in to access this page');
          return;
        }

        switch (item['action']) {
          case 'navigate':
            setState(() => _currentIndex = item['index']);
            break;
          case 'signout':
            _signOut();
            break;
        }
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 70),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item['color'].withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(item['icon'], size: 20, color: item['color']),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item['title'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: dark ? TColors.white : TColors.textprimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['subtitle'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: dark
                          ? TColors.white.withOpacity(0.7)
                          : TColors.textprimary.withOpacity(0.7),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarBackground(bool dark) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          decoration: BoxDecoration(
            color: dark
                ? Colors.black.withOpacity(0.8)
                : Colors.white.withOpacity(0.95),
            border: Border(
              bottom: BorderSide(
                color: dark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButton(bool dark) {
    return TextButton.icon(
      onPressed: widget.isAuthenticated ? _signOut : _showSignInDialog,
      icon: Icon(
        widget.isAuthenticated ? Iconsax.logout : Iconsax.login,
        color: dark ? TColors.white : TColors.textprimary,
        size: 20,
      ),
      label: Text(
        widget.isAuthenticated ? 'Logout' : 'Sign In',
        style: TextStyle(
          color: dark ? TColors.white : TColors.textprimary,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildThemeSwitcher([bool? dark]) {
    final isDark = dark ?? THelperFunctions.isDarkMode(context);

    return Builder(
      builder: (context) {
        final key = GlobalKey();
        return GestureDetector(
          onTap: () {
            final renderBox =
                key.currentContext?.findRenderObject() as RenderBox?;
            if (renderBox != null) {
              if (_isThemeDropdownOpen) {
                _removeThemeDropdown();
              } else {
                _showThemeDropdown(
                  renderBox,
                  MediaQuery.of(context).size.width,
                );
              }
            }
          },
          child: Container(
            key: key,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: _isThemeDropdownOpen
                  ? TColors.primary.withOpacity(0.1)
                  : Colors.transparent,
            ),
            child: Icon(
              _currentThemeMode == ThemeMode.light
                  ? Iconsax.sun_1
                  : _currentThemeMode == ThemeMode.dark
                  ? Iconsax.moon
                  : Iconsax.cpu,
              size: 20,
              color: _isThemeDropdownOpen
                  ? TColors.primary
                  : isDark
                  ? TColors.white
                  : TColors.textprimary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItemWithDropdown(String label, int index) {
    return Builder(
      builder: (context) {
        final key = GlobalKey();
        return MouseRegion(
          onEnter: (_) {
            final renderBox =
                key.currentContext?.findRenderObject() as RenderBox?;
            if (renderBox != null) {
              _showDropdown(
                label,
                renderBox,
                MediaQuery.of(context).size.width,
              );
            }
          },
          onExit: (_) {
            Future.delayed(const Duration(milliseconds: 200), () {
              if (_currentDropdown == label) {
                setState(() => _hoveredItem = null);
                _removeDropdown();
              }
            });
          },
          child: Container(
            key: key,
            height: kToolbarHeight,
            alignment: Alignment.center,
            child: _buildDesktopNavItem(label, index),
          ),
        );
      },
    );
  }

  Widget _buildDesktopNavItem(String label, int index) {
    final dark = THelperFunctions.isDarkMode(context);
    final isSelected = _currentIndex == index;
    final isHovered = _hoveredItem == label;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: (_) => setState(() => _hoveredItem = label),
      onExit: (_) => setState(() => _hoveredItem = null),
      child: GestureDetector(
        onTap: () {
          if ((index == 2 || index == 3 || index == 4) &&
              !widget.isAuthenticated) {
            CustomSnackbar.error(context, 'Please sign in to access this page');
            return;
          }
          if (index == 4 && widget.isAdmin != true) return;

          setState(() => _currentIndex = index);
          _removeDropdown();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? TColors.primary
                  : isHovered
                  ? TColors.primary.withOpacity(0.8)
                  : dark
                  ? TColors.white
                  : TColors.textprimary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark =
        _currentThemeMode == ThemeMode.dark ||
        (_currentThemeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _currentThemeMode,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        backgroundColor: dark ? TColors.dark : TColors.light,
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 80,
          flexibleSpace: _buildAppBarBackground(dark),
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  'assets/images/mbb_logo.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'MBB AgroTech',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: TColors.primary,
                ),
              ),
            ],
          ),
          actions: [
            _buildNavItemWithDropdown('Home', 0),
            _buildNavItemWithDropdown('Products', 1),
            if (widget.isAuthenticated) _buildNavItemWithDropdown('Cart', 2),
            if (widget.isAuthenticated) _buildNavItemWithDropdown('Account', 3),
            if (widget.isAuthenticated && widget.isAdmin == true)
              _buildNavItemWithDropdown('Admin', 4),
            _buildNavItemWithDropdown('About Us', 5),
            const SizedBox(width: 16),
            _buildAuthButton(dark),
            const SizedBox(width: 16),
            _buildThemeSwitcher(dark),
            const SizedBox(width: 24),
          ],
        ),
        body: _pages[_currentIndex],
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialog(
            context: context,
            builder: (context) => const ContactUsDialog(),
          ),
          backgroundColor: TColors.primary,
          child: const Icon(Iconsax.message_text, color: TColors.white),
        ),
      ),
    );
  }
}
