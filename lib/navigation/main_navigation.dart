import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:mbb_agrotech_website/pages/admin_panel.dart';
import 'package:mbb_agrotech_website/pages/products_screen.dart';
import 'package:mbb_agrotech_website/widgets/signi_signup_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/about_us_page.dart';
import '../pages/cart_screen.dart';
import '../pages/home_page.dart';
import '../pages/profile_screen.dart';
import '../utils/constants/colors.dart';
import '../utils/helpers/helper_functions.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final SupabaseClient _supabase = Supabase.instance.client;
  int _currentIndex = 0;
  String? _hoveredItem;
  final Map<String, bool> _dropdownOpenStates = {
    'Home': false,
    'Products': false,
    'Cart': false,
    'Account': false,
    'Admin': false,
  };
  bool _isThemeDropdownOpen = false;
  ThemeMode _currentThemeMode = ThemeMode.system;
  bool? _isAdmin;

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

  OverlayEntry? _dropdownOverlay;
  OverlayEntry? _themeDropdownOverlay;
  String? _currentDropdown;

  @override
  void initState() {
    super.initState();
    _supabase.auth.onAuthStateChange.listen((data) {
      _checkAdminStatus();
      setState(() {});
    });
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    if (_supabase.auth.currentUser != null) {
      try {
        final response = await _supabase
            .from('profiles')
            .select('is_admin')
            .eq('id', _supabase.auth.currentUser!.id)
            .single();
        setState(() {
          _isAdmin = response['is_admin'] ?? false;
        });
      } catch (e) {
        print('Error checking admin status: $e');
        setState(() {
          _isAdmin = false;
        });
      }
    } else {
      setState(() {
        _isAdmin = false;
      });
    }
  }

  void _showSignInDialog() {
    showDialog(
      context: context,
      builder: (context) => SizedBox(
        width: 500,
        child: SigningSignupDialog(
          onSuccess: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await _supabase.auth.signOut();
      setState(() {
        _currentIndex = 0;
        _isAdmin = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign-out failed: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  bool get _isAuthenticated => _supabase.auth.currentUser != null;

  void _showDropdown(String label, RenderBox renderBox, double screenWidth) {
    if ((label == 'Cart' || label == 'Account' || label == 'Admin') &&
        !_isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in to access this page'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    if (label == 'Admin' && _isAdmin != true) {
      return;
    }

    _removeDropdown();
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    setState(() {
      _dropdownOpenStates[label] = true;
      _currentDropdown = label;
    });

    final dropdownWidth = screenWidth < 600
        ? screenWidth * 0.9
        : screenWidth < 1024
        ? 280.0
        : 280.0;

    _dropdownOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: screenWidth < 600 ? 16 : position.dx,
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

    setState(() {
      _isThemeDropdownOpen = true;
    });

    final dropdownWidth = screenWidth < 600 ? screenWidth * 0.7 : 180.0;

    _themeDropdownOverlay = OverlayEntry(
      builder: (context) => Positioned(
        right: screenWidth < 600
            ? 16
            : MediaQuery.of(context).size.width - position.dx - size.width,
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
    if (_dropdownOverlay != null) {
      _dropdownOverlay!.remove();
      _dropdownOverlay = null;
      _currentDropdown = null;
      setState(() {
        _dropdownOpenStates.updateAll((key, value) => false);
      });
    }
  }

  void _removeThemeDropdown() {
    if (_themeDropdownOverlay != null) {
      _themeDropdownOverlay!.remove();
      _themeDropdownOverlay = null;
      setState(() {
        _isThemeDropdownOpen = false;
      });
    }
  }

  Widget _buildDropdownItem(Map<String, dynamic> item) {
    final dark = THelperFunctions.isDarkMode(context);

    return InkWell(
      onTap: () {
        _removeDropdown();

        if (!_isAuthenticated &&
            (item['title'] == 'View Cart' ||
                item['title'] == 'Checkout' ||
                item['title'] == 'Profile' ||
                item['title'] == 'Orders' ||
                item['title'] == 'Saved Items' ||
                item['title'] == 'Sign Out' ||
                item['title'] == 'Admin Panel')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please sign in to access this page'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
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

  Widget _buildMobileDrawer() {
    final dark =
        _currentThemeMode == ThemeMode.dark ||
        (_currentThemeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Drawer(
      backgroundColor: dark
          ? Colors.black.withOpacity(0.8)
          : Colors.white.withOpacity(0.8),
      width: MediaQuery.of(context).size.width * 0.65,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: dark ? TColors.dark : TColors.primary.withOpacity(0.1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: TColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'MBB Agrotech',
                        style: TextStyle(
                          color: TColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Growing Smart, Feeding the Future',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: dark ? TColors.white : TColors.textprimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _isAuthenticated
                          ? _signOut
                          : _showSignInDialog,
                      icon: Icon(
                        _isAuthenticated ? Iconsax.logout : Iconsax.login,
                        color: dark ? TColors.white : TColors.textprimary,
                        size: 20,
                      ),
                      label: Text(
                        _isAuthenticated ? 'Logout' : 'Sign In',
                        style: TextStyle(
                          color: dark ? TColors.white : TColors.textprimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Iconsax.info_circle, color: TColors.primary),
                title: const Text('About Us'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 5);
                },
              ),
              ..._dropdownItems.entries
                  .where(
                    (entry) =>
                        _isAuthenticated ||
                        (entry.key != 'Cart' &&
                            entry.key != 'Account' &&
                            entry.key != 'Admin'),
                  )
                  .where((entry) => entry.key != 'Admin' || _isAdmin == true)
                  .map((entry) {
                    return ExpansionTile(
                      title: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 14,
                          color: dark ? TColors.white : TColors.textprimary,
                        ),
                      ),
                      children: entry.value.map((item) {
                        return ListTile(
                          leading: Icon(
                            item['icon'],
                            color: item['color'],
                            size: 20,
                          ),
                          title: Text(
                            item['title'],
                            style: TextStyle(
                              fontSize: 12,
                              color: dark ? TColors.white : TColors.textprimary,
                            ),
                          ),
                          subtitle: Text(
                            item['subtitle'],
                            style: TextStyle(
                              fontSize: 10,
                              color: dark
                                  ? TColors.white.withOpacity(0.7)
                                  : TColors.textprimary.withOpacity(0.7),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            if (!_isAuthenticated &&
                                (item['title'] == 'View Cart' ||
                                    item['title'] == 'Checkout' ||
                                    item['title'] == 'Profile' ||
                                    item['title'] == 'Orders' ||
                                    item['title'] == 'Saved Items' ||
                                    item['title'] == 'Sign Out' ||
                                    item['title'] == 'Admin Panel')) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Please sign in to access this page',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
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
                        );
                      }).toList(),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _currentThemeMode,
      debugShowCheckedModeBanner: false,
      home: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isMobile = screenWidth < 600;
          final isTablet = screenWidth >= 600 && screenWidth < 1024;
          final dark =
              _currentThemeMode == ThemeMode.dark ||
              (_currentThemeMode == ThemeMode.system &&
                  MediaQuery.of(context).platformBrightness == Brightness.dark);

          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: dark ? TColors.dark : TColors.light,
            extendBody: true,
            appBar: isMobile
                ? _buildMobileAppBar()
                : isTablet
                ? _buildTabletAppBar()
                : _buildDesktopAppBar(),
            endDrawer: isMobile ? _buildMobileDrawer() : null,
            body: _pages[_currentIndex],
            bottomNavigationBar: isMobile
                ? _buildBottomNavigationBar(dark)
                : null,
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              backgroundColor: TColors.primary,
              child: const Icon(Iconsax.support, color: TColors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar(bool dark) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 20, left: 16, right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
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
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: dark ? TColors.white : TColors.primary,
            );
          }
          return TextStyle(
            fontSize: 12,
            color: dark ? TColors.softgrey : TColors.darkGrey,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          return IconThemeData(
            size: 20,
            color: states.contains(WidgetState.selected)
                ? TColors.primary
                : (dark ? TColors.softgrey : TColors.darkGrey),
          );
        }),
      ),
      child: NavigationBar(
        height: 40,
        elevation: 0,
        backgroundColor: Colors.transparent,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if ((index == 2 || index == 3 || index == 4) && !_isAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Please sign in to access this page'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            return;
          }
          if (index == 4 && _isAdmin != true) {
            return;
          }
          setState(() {
            _currentIndex = index;
          });
        },
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        indicatorColor: dark
            ? TColors.primary.withOpacity(0.3)
            : TColors.primary.withOpacity(0.3),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: _buildNavigationDestinations(),
      ),
    );
  }

  List<NavigationDestination> _buildNavigationDestinations() {
    return [
      const NavigationDestination(
        icon: Icon(Iconsax.home),
        selectedIcon: Icon(Iconsax.home),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Iconsax.shop),
        selectedIcon: Icon(Iconsax.shop),
        label: 'Products',
      ),
      if (_isAuthenticated)
        const NavigationDestination(
          icon: Icon(Iconsax.shopping_cart),
          selectedIcon: Icon(Iconsax.shopping_cart),
          label: 'Cart',
        ),
      if (_isAuthenticated)
        const NavigationDestination(
          icon: Icon(Iconsax.profile_circle),
          selectedIcon: Icon(Iconsax.profile_circle),
          label: 'Account',
        ),
      if (_isAuthenticated && _isAdmin == true)
        const NavigationDestination(
          icon: Icon(Iconsax.setting_2),
          selectedIcon: Icon(Iconsax.setting_2),
          label: 'Admin',
        ),
      const NavigationDestination(
        icon: Icon(Iconsax.info_circle),
        selectedIcon: Icon(Iconsax.info_circle),
        label: 'About Us',
      ),
    ];
  }

  AppBar _buildDesktopAppBar() {
    final dark =
        _currentThemeMode == ThemeMode.dark ||
        (_currentThemeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return AppBar(
      backgroundColor: dark ? TColors.dark : TColors.light,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 80,
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
        if (_isAuthenticated) _buildNavItemWithDropdown('Cart', 2),
        if (_isAuthenticated) _buildNavItemWithDropdown('Account', 3),
        if (_isAuthenticated && _isAdmin == true)
          _buildNavItemWithDropdown('Admin', 4),
        _buildNavItemWithDropdown('About Us', 5),
        const SizedBox(width: 16),
        TextButton.icon(
          onPressed: _isAuthenticated ? _signOut : _showSignInDialog,
          icon: Icon(
            _isAuthenticated ? Iconsax.logout : Iconsax.login,
            color: dark ? TColors.white : TColors.textprimary,
            size: 20,
          ),
          label: Text(
            _isAuthenticated ? 'Logout' : 'Sign In',
            style: TextStyle(
              color: dark ? TColors.white : TColors.textprimary,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildThemeSwitcher(),
        const SizedBox(width: 24),
      ],
    );
  }

  AppBar _buildTabletAppBar() {
    final dark =
        _currentThemeMode == ThemeMode.dark ||
        (_currentThemeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return AppBar(
      backgroundColor: dark ? TColors.dark : TColors.light,
      elevation: 0,
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0,
      toolbarHeight: 70,
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TColors.primary,
            ),
          ),
        ],
      ),
      actions: [
        _buildNavItemWithDropdown('Home', 0),
        _buildNavItemWithDropdown('Products', 1),
        if (_isAuthenticated) _buildNavItemWithDropdown('Cart', 2),
        if (_isAuthenticated) _buildNavItemWithDropdown('Account', 3),
        if (_isAuthenticated && _isAdmin == true)
          _buildNavItemWithDropdown('Admin', 4),
        _buildNavItemWithDropdown('About Us', 5),
        const SizedBox(width: 16),
        TextButton.icon(
          onPressed: _isAuthenticated ? _signOut : _showSignInDialog,
          icon: Icon(
            _isAuthenticated ? Iconsax.logout : Iconsax.login,
            color: dark ? TColors.white : TColors.textprimary,
            size: 20,
          ),
          label: Text(
            _isAuthenticated ? 'Logout' : 'Sign In',
            style: TextStyle(
              color: dark ? TColors.white : TColors.textprimary,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildThemeSwitcher(),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildThemeSwitcher() {
    final dark =
        _currentThemeMode == ThemeMode.dark ||
        (_currentThemeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

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
                  : dark
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
                setState(() {
                  _hoveredItem = null;
                  _dropdownOpenStates[label] = false;
                });
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
    final dark =
        _currentThemeMode == ThemeMode.dark ||
        (_currentThemeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    final isSelected = _currentIndex == index;
    final isHovered = _hoveredItem == label;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: (_) => setState(() => _hoveredItem = label),
      onExit: (_) => setState(() => _hoveredItem = null),
      child: GestureDetector(
        onTap: () {
          if ((index == 2 || index == 3 || index == 4) && !_isAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Please sign in to access this page'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            return;
          }
          if (index == 4 && _isAdmin != true) {
            return;
          }
          setState(() {
            _currentIndex = index;
          });
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

  AppBar _buildMobileAppBar() {
    final dark =
        _currentThemeMode == ThemeMode.dark ||
        (_currentThemeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return AppBar(
      backgroundColor: dark ? TColors.dark : TColors.light,
      elevation: 0,
      automaticallyImplyLeading: false,
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
        IconButton(
          icon: Icon(
            Iconsax.info_circle,
            color: dark ? TColors.white : TColors.textprimary,
          ),
          onPressed: () {
            setState(() => _currentIndex = 5);
          },
        ),
        Builder(
          builder: (context) {
            final key = GlobalKey();
            return IconButton(
              key: key,
              icon: Icon(
                _currentThemeMode == ThemeMode.light
                    ? Iconsax.sun_1
                    : _currentThemeMode == ThemeMode.dark
                    ? Iconsax.moon
                    : Iconsax.cpu,
                color: dark ? TColors.white : TColors.textprimary,
              ),
              onPressed: () {
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
            );
          },
        ),
        if (!_isAuthenticated)
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
        if (_isAuthenticated)
          IconButton(
            icon: Icon(
              Iconsax.menu_1,
              color: dark ? TColors.white : TColors.textprimary,
            ),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
      ],
    );
  }
}
