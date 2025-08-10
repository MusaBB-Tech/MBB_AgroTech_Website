import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../utils/constants/colors.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: dark ? TColors.dark : Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 56,
                bottom: 24,
              ),
              decoration: BoxDecoration(
                color: dark ? TColors.darkContainer : Colors.white,
                boxShadow: [
                  if (!dark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(
                      Iconsax.arrow_left,
                      color: dark ? TColors.white : TColors.black,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'About Us',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: dark ? TColors.white : TColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Learn more about our hydroponic mission',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: dark ? TColors.lightgrey : TColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),

            // Mission Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Iconsax.blur, color: TColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Our Mission',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: dark ? TColors.white : TColors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'At HydroGrow, we believe in revolutionizing agriculture through sustainable hydroponic solutions. Our mission is to make urban farming accessible to everyone, reducing water usage by up to 90% compared to traditional farming while delivering fresh, pesticide-free produce year-round.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: dark ? TColors.lightgrey : TColors.darkGrey,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),

            // Image Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/hydroponic_farm.jpg', // Replace with your image
                  fit: BoxFit.cover,
                  height: size.height * 0.25,
                  width: double.infinity,
                ),
              ),
            ),

            // Stats Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(
                  color: dark ? TColors.darkContainer : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (!dark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      '10K+',
                      'Customers',
                      Iconsax.people,
                    ),
                    _buildStatItem(context, '90%', 'Water Saved', Iconsax.drop),
                    _buildStatItem(
                      context,
                      '5Y',
                      'Experience',
                      Iconsax.calendar,
                    ),
                  ],
                ),
              ),
            ),

            // Team Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Iconsax.people, color: TColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Our Team',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: dark ? TColors.white : TColors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We are a passionate team of agricultural engineers, sustainability experts, and tech enthusiasts dedicated to making hydroponic farming accessible to everyone.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: dark ? TColors.lightgrey : TColors.darkGrey,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildTeamMember(
                          'assets/images/team1.jpg', // Replace with your images
                          'Alex',
                          'Founder',
                          dark,
                        ),
                        const SizedBox(width: 16),
                        _buildTeamMember(
                          'assets/images/team2.jpg',
                          'Sarah',
                          'Lead Engineer',
                          dark,
                        ),
                        const SizedBox(width: 16),
                        _buildTeamMember(
                          'assets/images/team3.jpg',
                          'Jamal',
                          'Agronomist',
                          dark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Values Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.like_shapes,
                        color: TColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Our Values',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: dark ? TColors.white : TColors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildValueItem(
                    context,
                    'Sustainability',
                    'We prioritize eco-friendly solutions that minimize environmental impact.',
                    Iconsax.blur,
                  ),
                  _buildValueItem(
                    context,
                    'Innovation',
                    'Constantly developing new technologies to improve urban farming.',
                    Iconsax.cpu,
                  ),
                  _buildValueItem(
                    context,
                    'Community',
                    'Building a network of urban farmers sharing knowledge and produce.',
                    Iconsax.people,
                  ),
                ],
              ),
            ),

            // Contact CTA
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: TColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Want to learn more about hydroponics?',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: dark ? TColors.white : TColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Contact our team of experts for personalized advice on setting up your hydroponic system.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: dark ? TColors.lightgrey : TColors.darkGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Add contact functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      'Contact Us',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Icon(icon, color: TColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: TColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: dark ? TColors.lightgrey : TColors.darkGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamMember(
    String imagePath,
    String name,
    String role,
    bool dark,
  ) {
    return Column(
      children: [
        CircleAvatar(radius: 32, backgroundImage: AssetImage(imagePath)),
        const SizedBox(height: 8),
        Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: dark ? TColors.white : TColors.black,
          ),
        ),
        Text(
          role,
          style: GoogleFonts.poppins(fontSize: 12, color: TColors.primary),
        ),
      ],
    );
  }

  Widget _buildValueItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: TColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: dark ? TColors.white : TColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: dark ? TColors.lightgrey : TColors.darkGrey,
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
