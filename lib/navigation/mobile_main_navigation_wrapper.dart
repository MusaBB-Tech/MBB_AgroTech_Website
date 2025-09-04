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

class MobileMainNavigationWrapper extends StatefulWidget {
  final bool? isAdmin;
  final bool isAuthenticated;
  final SupabaseClient supabase;

  const MobileMainNavigationWrapper({
    super.key,
    required this.isAdmin,
    required this.isAuthenticated,
    required this.supabase,
  });

  @override
  State<MobileMainNavigationWrapper> createState() =>
      _MobileMainNavigationWrapperState();
}

class _MobileMainNavigationWrapperState
    extends State<MobileMainNavigationWrapper> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0; // Index for _pages list
  int _selectedNavIndex = 0; // Index for NavigationBar destinations
  bool _isThemeDropdownOpen = false;
  ThemeMode _currentThemeMode = ThemeMode.system;
  OverlayEntry? _themeDropdownOverlay;

  final List<Widget> _pages = const [
    HomePage(),
    ProductsScreen(),
    CartScreen(),
    ProfileScreen(),
    AdminPanel(),
    AboutUsScreen(),
  ];

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
        _currentIndex = 0; // Reset to Home page
        _selectedNavIndex = 0; // Reset to Home destination
      });
    } catch (e) {
      CustomSnackbar.error(context, 'Sign-out failed');
    }
  }

  void _showThemeDropdown(RenderBox renderBox, double screenWidth) {
    _removeThemeDropdown();
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    setState(() => _isThemeDropdownOpen = true);

    final dropdownWidth = screenWidth * 0.7;

    _themeDropdownOverlay = OverlayEntry(
      builder: (context) => Positioned(
        right: 16,
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

  void _removeThemeDropdown() {
    _themeDropdownOverlay?.remove();
    _themeDropdownOverlay = null;
    setState(() => _isThemeDropdownOpen = false);
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

  Widget _buildBottomNavigationBar(bool dark) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 20, left: 16, right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: dark
                  ? TColors.dark.withOpacity(0.5)
                  : TColors.light.withOpacity(0.5),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: dark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.15),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildNavigationBar(dark),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationBar(bool dark) {
    // Define a mapping of NavigationBar indices to _pages indices
    final pageIndexMap = <int, int>{};
    int navIndex = 0;

    // Always present destinations
    pageIndexMap[navIndex++] = 0; // Home -> _pages[0]
    pageIndexMap[navIndex++] = 1; // Products -> _pages[1]
    if (widget.isAuthenticated) {
      pageIndexMap[navIndex++] = 2; // Cart -> _pages[2]
      pageIndexMap[navIndex++] = 3; // Account -> _pages[3]
    }
    if (widget.isAuthenticated && widget.isAdmin == true) {
      pageIndexMap[navIndex++] = 4; // Admin -> _pages[4]
    }
    pageIndexMap[navIndex] = 5; // About Us -> _pages[5]

    // Create the reverse mapping to find the NavigationBar index from _pages index
    final navIndexMap = pageIndexMap.map((k, v) => MapEntry(v, k));

    // Ensure _selectedNavIndex is valid for the current destinations
    if (_selectedNavIndex >= pageIndexMap.length) {
      _selectedNavIndex = navIndexMap[_currentIndex] ?? 0;
    }

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          return TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w500
                : FontWeight.normal,
            color: states.contains(WidgetState.selected)
                ? (dark ? TColors.white : TColors.primary)
                : (dark ? TColors.softgrey : TColors.darkGrey),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          return IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? TColors.primary
                : (dark ? TColors.softgrey : TColors.darkGrey),
          );
        }),
      ),
      child: NavigationBar(
        height: 60,
        elevation: 0,
        backgroundColor: Colors.transparent,
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          // Map the NavigationBar index to the _pages index
          final pageIndex = pageIndexMap[index]!;

          // Restrict access to Cart, Account, and Admin if not authenticated
          if ((pageIndex == 2 || pageIndex == 3 || pageIndex == 4) &&
              !widget.isAuthenticated) {
            CustomSnackbar.error(context, 'Please sign in to access this page');
            return;
          }
          // Restrict access to Admin if not an admin
          if (pageIndex == 4 && widget.isAdmin != true) {
            return;
          }

          setState(() {
            _currentIndex = pageIndex;
            _selectedNavIndex = index;
          });
        },
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        indicatorColor: dark
            ? TColors.primary.withOpacity(0.3)
            : TColors.primary.withOpacity(0.3),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          const NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
          const NavigationDestination(
            icon: Icon(Iconsax.shop),
            label: 'Products',
          ),
          if (widget.isAuthenticated)
            const NavigationDestination(
              icon: Icon(Iconsax.shopping_cart),
              label: 'Cart',
            ),
          if (widget.isAuthenticated)
            const NavigationDestination(
              icon: Icon(Iconsax.profile_circle),
              label: 'Account',
            ),
          if (widget.isAuthenticated && widget.isAdmin == true)
            const NavigationDestination(
              icon: Icon(Iconsax.setting_2),
              label: 'Admin',
            ),
          const NavigationDestination(
            icon: Icon(Iconsax.info_circle),
            label: 'About Us',
          ),
        ],
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
        appBar: _currentIndex == 0
            ? AppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: 70,
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
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'MBB Agrotech',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                    ),
                  ],
                ),
                actions: [
                  _buildThemeSwitcher(dark),
                  if (!widget.isAuthenticated)
                    TextButton.icon(
                      onPressed: _showSignInDialog,
                      icon: Icon(
                        Iconsax.login,
                        color: dark ? TColors.white : TColors.textprimary,
                        size: 20,
                      ),
                      label: Text(
                        'Sign In',
                        style: TextStyle(
                          color: dark ? TColors.white : TColors.textprimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  if (widget.isAuthenticated)
                    TextButton.icon(
                      onPressed: _signOut,
                      icon: Icon(
                        Iconsax.logout,
                        color: dark ? TColors.white : TColors.textprimary,
                        size: 20,
                      ),
                      label: Text(
                        'Logout',
                        style: TextStyle(
                          color: dark ? TColors.white : TColors.textprimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              )
            : null,
        body: _pages[_currentIndex],
        bottomNavigationBar: _buildBottomNavigationBar(dark),
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
