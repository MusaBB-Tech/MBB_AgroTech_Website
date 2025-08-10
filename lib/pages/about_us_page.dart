import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
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
        : 22;
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? screenPadding : screenPadding * 1.5,
          ),
          child: Column(
            children: [
              SizedBox(height: screenPadding),
              // Mission Section
              _buildSection(
                context,
                icon: Iconsax.blur,
                title: 'Our Mission',
                content:
                    'At HydroGrow, we believe in revolutionizing agriculture through sustainable hydroponic solutions. Our mission is to make urban farming accessible to everyone, reducing water usage by up to 90% compared to traditional farming while delivering fresh, pesticide-free produce year-round.',
                dark: dark,
                screenPadding: screenPadding,
                titleFontSize: titleFontSize,
                textFontSize: textFontSize,
                iconSize: iconSize,
              ),
              SizedBox(height: sectionSpacing),

              // Team Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.people,
                        color: TColors.primary,
                        size: iconSize,
                      ),
                      SizedBox(width: screenPadding * 0.5),
                      Text(
                        'Our Team',
                        style: GoogleFonts.poppins(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          color: dark ? TColors.white : TColors.black,
                        ),
                      ),
                    ],
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
              SizedBox(height: sectionSpacing),

              // Values Section
              _buildSection(
                context,
                icon: Iconsax.like_shapes,
                title: 'Our Values',
                content: '',
                dark: dark,
                screenPadding: screenPadding,
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
              SizedBox(height: sectionSpacing),

              // Contact CTA
              Container(
                padding: EdgeInsets.all(screenPadding),
                decoration: BoxDecoration(
                  color: dark ? TColors.darkContainer : TColors.lightContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TColors.primary.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Want to learn more about hydroponics?',
                      style: GoogleFonts.poppins(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                        color: dark ? TColors.white : TColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenPadding * 0.8),
                    Text(
                      'Contact our team of experts for personalized advice on setting up your hydroponic system.',
                      style: GoogleFonts.poppins(
                        fontSize: textFontSize,
                        color: dark ? TColors.lightgrey : TColors.darkGrey,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenPadding * 1.5),
                    SizedBox(
                      width: isMobile ? double.infinity : null,
                      child: ElevatedButton(
                        onPressed: () {
                          // Add contact functionality
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenPadding * 2,
                            vertical: buttonHeight * 0.5,
                          ),
                          elevation: 0,
                          shadowColor: Colors.black.withOpacity(0.1),
                        ),
                        child: Text(
                          'Contact Us',
                          style: GoogleFonts.poppins(
                            fontSize: buttonFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenPadding * 1.5),
            ],
          ),
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
    required double screenPadding,
    required double titleFontSize,
    required double textFontSize,
    required double iconSize,
    List<Widget> children = const [],
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: TColors.primary, size: iconSize),
            SizedBox(width: screenPadding * 0.5),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: dark ? TColors.white : TColors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: screenPadding),
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
}
