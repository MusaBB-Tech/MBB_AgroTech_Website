import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/constants/colors.dart';
import '../responsive.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveLayout.isMobile(context);
    final isTablet = ResponsiveLayout.isTablet(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    final double screenPadding = isDesktop
        ? 32
        : isTablet
        ? 24
        : 16;
    final double sectionSpacing = isDesktop
        ? 40
        : isTablet
        ? 32
        : 24;
    final double titleFontSize = isDesktop
        ? 24
        : isTablet
        ? 20
        : 18;
    final double textFontSize = isDesktop
        ? 16
        : isTablet
        ? 14
        : 13;
    final double iconSize = isDesktop
        ? 28
        : isTablet
        ? 24
        : 20;
    final double teamAvatarSize = isDesktop
        ? 80
        : isTablet
        ? 70
        : 60;
    final double buttonFontSize = isDesktop
        ? 16
        : isTablet
        ? 14
        : 13;
    final double buttonHeight = isDesktop
        ? 50
        : isTablet
        ? 46
        : 44;

    return Scaffold(
      backgroundColor: dark ? TColors.dark : TColors.light,
      appBar: AppBar(
        titleSpacing: 16,
        scrolledUnderElevation: 0,

        title: Text(
          'About Us',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        backgroundColor: dark ? TColors.dark : TColors.light,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? screenPadding : screenPadding * 1.5,
          vertical: screenPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(screenPadding),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: dark
                        ? [
                            TColors.primary.withOpacity(0.3),
                            TColors.primary.withOpacity(0.1),
                          ]
                        : [
                            TColors.primary.withOpacity(0.2),
                            TColors.primary.withOpacity(0.05),
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? 0.1 : 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Iconsax.blur,
                  size: iconSize * 1.5,
                  color: TColors.primary,
                ),
              ),
            ),
            SizedBox(height: sectionSpacing),
            // Mission Section
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: dark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
              color: dark ? TColors.darkContainer : TColors.lightContainer,
              child: Padding(
                padding: EdgeInsets.all(screenPadding),
                child: _buildSection(
                  context,
                  icon: Iconsax.blur,
                  title: 'Our Mission',
                  content:
                      'At HydroGrow, we believe in revolutionizing agriculture through sustainable hydroponic solutions. Our mission is to make urban farming accessible to everyone, reducing water usage by up to 90% compared to traditional farming while delivering fresh, pesticide-free produce year-round.',
                  dark: dark,
                  titleFontSize: titleFontSize,
                  textFontSize: textFontSize,
                  iconSize: iconSize,
                ),
              ),
            ),
            SizedBox(height: sectionSpacing),
            // Team Section
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: dark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
              color: dark ? TColors.darkContainer : TColors.lightContainer,
              child: Padding(
                padding: EdgeInsets.all(screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      context,
                      icon: Iconsax.people,
                      title: 'Our Team',
                      dark: dark,
                      titleFontSize: titleFontSize,
                    ),
                    SizedBox(height: screenPadding),
                    Text(
                      'We are a passionate team of agricultural engineers, sustainability experts, and tech enthusiasts dedicated to making hydroponic farming accessible to everyone.',
                      style: GoogleFonts.poppins(
                        fontSize: textFontSize,
                        color: dark ? TColors.lightgrey : TColors.darkGrey,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: screenPadding),
                    SizedBox(
                      height: teamAvatarSize * 1.8,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildTeamMember(
                            'assets/images/team1.jpg',
                            'Alex',
                            'Founder',
                            dark,
                            teamAvatarSize,
                            textFontSize,
                          ),
                          SizedBox(width: screenPadding),
                          _buildTeamMember(
                            'assets/images/team2.jpg',
                            'Sarah',
                            'Lead Engineer',
                            dark,
                            teamAvatarSize,
                            textFontSize,
                          ),
                          SizedBox(width: screenPadding),
                          _buildTeamMember(
                            'assets/images/team3.jpg',
                            'Jamal',
                            'Agronomist',
                            dark,
                            teamAvatarSize,
                            textFontSize,
                          ),
                          if (isDesktop) SizedBox(width: screenPadding),
                          if (isDesktop)
                            _buildTeamMember(
                              'assets/images/team4.jpg',
                              'Maria',
                              'Marketing',
                              dark,
                              teamAvatarSize,
                              textFontSize,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: sectionSpacing),
            // Values Section
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: dark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
              color: dark ? TColors.darkContainer : TColors.lightContainer,
              child: Padding(
                padding: EdgeInsets.all(screenPadding),
                child: _buildSection(
                  context,
                  icon: Iconsax.like_shapes,
                  title: 'Our Values',
                  content: '',
                  dark: dark,
                  titleFontSize: titleFontSize,
                  textFontSize: textFontSize,
                  iconSize: iconSize,
                  children: [
                    _buildValueItem(
                      context,
                      'Sustainability',
                      'We prioritize eco-friendly solutions that minimize environmental impact.',
                      Iconsax.blur,
                      dark,
                      screenPadding,
                      textFontSize,
                    ),
                    _buildValueItem(
                      context,
                      'Innovation',
                      'Constantly developing new technologies to improve urban farming.',
                      Iconsax.cpu,
                      dark,
                      screenPadding,
                      textFontSize,
                    ),
                    _buildValueItem(
                      context,
                      'Community',
                      'Building a network of urban farmers sharing knowledge and produce.',
                      Iconsax.people,
                      dark,
                      screenPadding,
                      textFontSize,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required bool dark,
    required double titleFontSize,
    required double textFontSize,
    required double iconSize,
    List<Widget> children = const [],
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (content.isNotEmpty)
          _buildSectionHeader(
            context,
            icon: icon,
            title: title,
            dark: dark,
            titleFontSize: titleFontSize,
          ),
        if (content.isNotEmpty) SizedBox(height: 16),
        if (content.isNotEmpty)
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: textFontSize,
              color: dark ? TColors.lightgrey : TColors.darkGrey,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ...children,
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool dark,
    required double titleFontSize,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? [
                  TColors.primary.withOpacity(0.2),
                  TColors.primary.withOpacity(0.1),
                ]
              : [
                  TColors.primary.withOpacity(0.15),
                  TColors.primary.withOpacity(0.05),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.1 : 0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: TColors.primary),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w700,
              color: dark ? Colors.white : TColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(
    String imagePath,
    String name,
    String role,
    bool dark,
    double avatarSize,
    double fontSize,
  ) {
    return Column(
      children: [
        CircleAvatar(
          radius: avatarSize / 2,
          backgroundImage: AssetImage(imagePath),
        ),
        SizedBox(height: 8),
        Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: dark ? TColors.white : TColors.black,
          ),
        ),
        Text(
          role,
          style: GoogleFonts.poppins(
            fontSize: fontSize - 2,
            color: TColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildValueItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    bool dark,
    double padding,
    double fontSize,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(padding * 0.5),
            decoration: BoxDecoration(
              color: TColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: TColors.primary, size: fontSize * 1.2),
          ),
          SizedBox(width: padding * 0.8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: dark ? TColors.white : TColors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize:
                        fontSize - (ResponsiveLayout.isMobile(context) ? 0 : 1),
                    color: dark ? TColors.lightgrey : TColors.darkGrey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    IconData icon,
    String text,
    bool dark, {
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: onTap != null
                ? (dark ? TColors.dark : TColors.light)
                : Colors.transparent,
            boxShadow: onTap != null
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? 0.1 : 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: dark ? Colors.white70 : TColors.darkGrey,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: onTap != null
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: dark ? Colors.white70 : TColors.darkGrey,
                  ),
                ),
              ),
              if (onTap != null)
                Icon(
                  Iconsax.arrow_right_3,
                  size: 18,
                  color: dark ? Colors.white54 : TColors.darkGrey,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
