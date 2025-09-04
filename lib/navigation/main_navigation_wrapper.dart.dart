import 'package:flutter/material.dart';
import 'package:mbb_agrotech_website/responsive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'desktop_main_navigation_wrapper.dart';
import 'tablet_main_navigation_wrapper.dart';
import 'mobile_main_navigation_wrapper.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool? _isAdmin;

  @override
  void initState() {
    super.initState();
    _supabase.auth.onAuthStateChange.listen((data) {
      _checkAdminStatus();
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
        debugPrint('Error checking admin status');
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

  bool get _isAuthenticated => _supabase.auth.currentUser != null;

  @override
  Widget build(BuildContext context) {
    if (ResponsiveLayout.isMobile(context)) {
      return MobileMainNavigationWrapper(
        isAdmin: _isAdmin,
        isAuthenticated: _isAuthenticated,
        supabase: _supabase,
      );
    } else if (ResponsiveLayout.isTablet(context)) {
      return TabletMainNavigationWrapper(
        isAdmin: _isAdmin,
        isAuthenticated: _isAuthenticated,
        supabase: _supabase,
      );
    } else {
      return DesktopMainNavigationWrapper(
        isAdmin: _isAdmin,
        isAuthenticated: _isAuthenticated,
        supabase: _supabase,
      );
    }
  }
}
