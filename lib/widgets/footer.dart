import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/constants/colors.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final dark = theme.brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(maxWidth: 1440),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile
            ? 20.0
            : isTablet
            ? 48.0
            : 80.0,
        vertical: isMobile
            ? 32.0
            : isTablet
            ? 40.0
            : 48.0,
      ),
      decoration: BoxDecoration(
        color: dark ? TColors.darkContainer : TColors.lightContainer,
        border: Border(
          top: BorderSide(
            color: dark ? TColors.darkGrey : TColors.primary.withOpacity(0.3),
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        children: [
          isMobile
              ? _buildMobileFooterContent(theme, dark)
              : isTablet
              ? _buildTabletFooterContent(theme, dark)
              : _buildDesktopFooterContent(theme, dark),
          const SizedBox(height: 16.0),
          Divider(color: dark ? TColors.darkGrey : Colors.white24, height: 1.0),
          const SizedBox(height: 12.0),
          _buildSocialMediaSection(context, dark, isMobile, isTablet),
          const SizedBox(height: 12.0),
          Text(
            '© ${DateTime.now().year} MBB Agrotech. All rights reserved.',
            style: GoogleFonts.poppins(
              textStyle: theme.textTheme.bodySmall?.copyWith(
                color: dark ? TColors.white : TColors.black,
                fontSize: isMobile
                    ? 13.0
                    : isTablet
                    ? 14.0
                    : 15.0,
              ),
            ),
            textAlign: TextAlign.center,
            semanticsLabel: 'Copyright ${DateTime.now().year} MBB Agrotech',
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopFooterContent(ThemeData theme, bool dark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MBB Agrotech',
                style: GoogleFonts.poppins(
                  color: dark ? TColors.white : TColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 26.0,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                'Growing Smart, Feeding the Future - Revolutionizing agriculture through innovative technology solutions',
                style: GoogleFonts.poppins(
                  textStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: dark ? TColors.white : TColors.black,
                    height: 1.5,
                    fontSize: 15.0,
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Icon(Icons.email, size: 16, color: TColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'info@mbbagrotech.com',
                    style: GoogleFonts.poppins(
                      color: dark ? TColors.white : TColors.black,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: TColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '+234 800 000 0000',
                    style: GoogleFonts.poppins(
                      color: dark ? TColors.white : TColors.black,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 32.0),
        Expanded(
          child: _buildFooterColumn(
            'Solutions',
            [
              'Smart Farming',
              'Hydroponic Systems',
              'Greenhouse Solutions',
              'Farm Monitoring',
            ],
            theme,
            dark,
          ),
        ),
        const SizedBox(width: 32.0),
        Expanded(
          child: _buildFooterColumn(
            'Support',
            ['Documentation', 'Training Programs', 'FAQs', 'Contact Support'],
            theme,
            dark,
          ),
        ),
        const SizedBox(width: 32.0),
        Expanded(
          child: _buildFooterColumn(
            'Company',
            ['About Us', 'Our Team', 'Careers', 'Blog'],
            theme,
            dark,
          ),
        ),
      ],
    );
  }

  Widget _buildTabletFooterContent(ThemeData theme, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'MBB Agrotech',
              style: GoogleFonts.poppins(
                color: dark ? TColors.white : TColors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        Text(
          'Growing Smart, Feeding the Future - Revolutionizing agriculture through innovative technology solutions',
          style: GoogleFonts.poppins(
            textStyle: theme.textTheme.bodyMedium?.copyWith(
              color: dark ? TColors.white : TColors.black,
              height: 1.5,
              fontSize: 14.5,
            ),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildFooterColumn(
                'Solutions',
                ['Smart Farming', 'Hydroponic Systems', 'Greenhouse Solutions'],
                theme,
                dark,
                isTablet: true,
              ),
            ),
            const SizedBox(width: 20.0),
            Expanded(
              child: _buildFooterColumn(
                'Support',
                ['Documentation', 'Training Programs', 'FAQs'],
                theme,
                dark,
                isTablet: true,
              ),
            ),
            const SizedBox(width: 20.0),
            Expanded(
              child: _buildFooterColumn(
                'Company',
                ['About Us', 'Our Team', 'Careers'],
                theme,
                dark,
                isTablet: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.email, size: 16, color: TColors.primary),
            const SizedBox(width: 8),
            Text(
              'info@mbbagrotech.com',
              style: GoogleFonts.poppins(
                color: dark ? TColors.white : TColors.black,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 20),
            Icon(Icons.phone, size: 16, color: TColors.primary),
            const SizedBox(width: 8),
            Text(
              '+234 800 000 0000',
              style: GoogleFonts.poppins(
                color: dark ? TColors.white : TColors.black,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileFooterContent(ThemeData theme, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'MBB Agrotech',
          style: GoogleFonts.poppins(
            color: dark ? TColors.white : TColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22.0,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12.0),
        Text(
          'Growing Smart, Feeding the Future',
          style: GoogleFonts.poppins(
            textStyle: theme.textTheme.bodyMedium?.copyWith(
              color: dark ? TColors.white : TColors.black,
              height: 1.5,
              fontSize: 13.5,
            ),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _buildFooterColumn(
                'Solutions',
                ['Smart Farming', 'Hydroponics'],
                theme,
                dark,
                isMobile: true,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: _buildFooterColumn(
                'Support',
                ['Training', 'FAQs'],
                theme,
                dark,
                isMobile: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email, size: 16, color: TColors.primary),
                const SizedBox(width: 8),
                Text(
                  'mbbagrotech@gmail.com',
                  style: GoogleFonts.poppins(
                    color: dark ? TColors.white : TColors.black,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone, size: 16, color: TColors.primary),
                const SizedBox(width: 8),
                Text(
                  '+234 704 630 6129',
                  style: GoogleFonts.poppins(
                    color: dark ? TColors.white : TColors.black,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterColumn(
    String title,
    List<String> items,
    ThemeData theme,
    bool dark, {
    bool isMobile = false,
    bool isTablet = false,
  }) {
    return Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            textStyle: theme.textTheme.titleMedium?.copyWith(
              color: dark ? TColors.white : TColors.black,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              fontSize: isMobile
                  ? 15.0
                  : isTablet
                  ? 15.5
                  : 16.0,
            ),
          ),
        ),
        const SizedBox(height: 10.0),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: InkWell(
              hoverColor: TColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.0),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  item,
                  style: GoogleFonts.poppins(
                    textStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: dark ? TColors.white : TColors.black,
                      height: 1.5,
                      fontSize: isMobile
                          ? 13.0
                          : isTablet
                          ? 13.5
                          : 14.0,
                    ),
                  ),
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialMediaSection(
    BuildContext context,
    bool dark,
    bool isMobile,
    bool isTablet,
  ) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12.0 : 20.0,
        vertical: isMobile ? 12.0 : 16.0,
      ),
      decoration: BoxDecoration(
        color: dark
            ? TColors.dark.withOpacity(0.4)
            : TColors.light.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: dark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Connect with us',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: dark ? Colors.white70 : TColors.darkGrey,
              fontSize: isMobile ? 13.0 : 14.0,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialIcon(
                icon: FontAwesomeIcons.facebookF,
                color: const Color(0xFF1877F2),
                size: isMobile ? 16.0 : 18.0,
                onTap: () => _launchUrl(context, 'https://facebook.com'),
              ),
              _buildSocialIcon(
                icon: FontAwesomeIcons.xTwitter,
                color: const Color(0xFF000000),
                size: isMobile ? 16.0 : 18.0,
                onTap: () => _launchUrl(context, 'https://twitter.com'),
              ),
              _buildSocialIcon(
                icon: FontAwesomeIcons.instagram,
                color: const Color(0xFFE4405F),
                size: isMobile ? 16.0 : 18.0,
                onTap: () => _launchUrl(context, 'https://instagram.com'),
              ),
              _buildSocialIcon(
                icon: FontAwesomeIcons.linkedinIn,
                color: const Color(0xFF0A66C2),
                size: isMobile ? 16.0 : 18.0,
                onTap: () => _launchUrl(context, 'https://linkedin.com'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon({
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: size * 2,
        height: size * 2,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: FaIcon(icon, size: size, color: color),
        ),
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
    }
  }
}
