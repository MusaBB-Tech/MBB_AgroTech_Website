import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../responsive.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Our Services',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF4E6BFF), Color(0xFF1A3A8F)],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 120,
              vertical: 60,
            ),
            child: const Center(child: Text('Services Page Content')),
          ),
        ),
      ],
    );
  }
}
