import 'package:flutter/material.dart';

import '../responsive.dart';
import 'desktop_home_page.dart';
import 'tablet_home_page.dart';
import 'mobile_home_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (ResponsiveLayout.isMobile(context)) {
      return const MobileHomePage();
    } else if (ResponsiveLayout.isTablet(context)) {
      return const TabletHomePage();
    } else {
      return const DesktopHomePage();
    }
  }
}
