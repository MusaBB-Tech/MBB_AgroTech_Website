import 'dart:async';
import 'dart:math';

// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Local imports
import '../utils/constants/colors.dart';
import '../widgets/book_consultaion_dialog.dart';
import '../widgets/contact_us_dialog.dart';
import '../widgets/footer.dart';
import 'product_detail_screen.dart';

class MobileHomePage extends StatefulWidget {
  const MobileHomePage({super.key});

  @override
  State<MobileHomePage> createState() => _MobileHomePageState();
}

class _MobileHomePageState extends State<MobileHomePage> {
  // Constants
  static const _backgroundChangeDuration = Duration(seconds: 5);
  final List<String> _backgroundImages = [
    'assets/images/hydroponic_farm.jpg',
    'assets/images/greenhouse.jpg',
    'assets/images/farm_monitoring.jpg',
    'assets/images/smart_farming.jpg',
  ];
  int _currentBackgroundIndex = 0;
  late Timer _backgroundTimer;

  final List<Map<String, dynamic>> _offerings = [
    {
      'image': 'assets/images/hydroponic_system.jpg',
      'title': 'Hydroponic Systems',
      'description':
          'Soil-less farming solutions for high-yield crop production in limited spaces.',
      'icon': Icons.water_drop_outlined,
    },
    {
      'image': 'assets/images/greenhouse.jpg',
      'title': 'Greenhouse Solutions',
      'description':
          'Climate-controlled environments for year-round farming and optimal plant growth.',
      'icon': Icons.grass_outlined,
    },
    {
      'image': 'assets/images/farm_monitoring.jpg',
      'title': 'Smart Monitoring',
      'description':
          'Real-time tracking of farm conditions with IoT sensors and analytics.',
      'icon': Icons.monitor_heart_outlined,
    },
    {
      'image': 'assets/images/agro_consulting.jpg',
      'title': 'Agro Consulting',
      'description':
          'Expert advice on modern farming techniques and business strategies.',
      'icon': Icons.business_center_outlined,
    },
    {
      'image': 'assets/images/farm_training.jpg',
      'title': 'Farmer Training',
      'description':
          'Comprehensive programs to build capacity in modern agricultural practices.',
      'icon': Icons.school_outlined,
    },
    {
      'image': 'assets/images/irrigation.jpg',
      'title': 'Smart Irrigation',
      'description':
          'Water-efficient systems that optimize usage based on crop needs.',
      'icon': Icons.invert_colors_on_outlined,
    },
  ];

  final List<Map<String, dynamic>> _testimonials = [
    {
      'name': 'Chidi Okeke',
      'location': 'Lagos, Nigeria',
      'quote':
          'MBB Agrotech\'s hydroponic system doubled our yield in just six months!',
      'image': 'assets/person.png',
    },
    {
      'name': 'Aisha Bello',
      'location': 'Abuja, Nigeria',
      'quote':
          'Their training program transformed our farm operations with smart technology.',
      'image': 'assets/person.png',
    },
    {
      'name': 'Emeka Nwosu',
      'location': 'Ogun, Nigeria',
      'quote':
          'The smart irrigation system saved us 40% on water costs. Highly recommend!',
      'image': 'assets/person.png',
    },
  ];

  List<Map<String, dynamic>> _popularProducts = [];
  List<Map<String, dynamic>> _newProducts = [];
  List<Map<String, dynamic>> _featuredProducts = [];
  bool dark = false;
  bool _isLoadingPopular = true;
  bool _isLoadingFeatured = true;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Standard padding values for mobile
  final double _screenPadding = 16.0;
  final double _sectionPadding = 24.0;
  final double _cardPadding = 12.0;
  final double _elementPadding = 8.0;

  @override
  void initState() {
    super.initState();
    _backgroundTimer = Timer.periodic(_backgroundChangeDuration, (timer) {
      setState(() {
        _currentBackgroundIndex =
            (_currentBackgroundIndex + 1) % _backgroundImages.length;
      });
    });
    _fetchPopularProducts();
    _fetchFeaturedProducts();
  }

  @override
  void dispose() {
    _backgroundTimer.cancel();
    super.dispose();
  }

  Future<void> _fetchPopularProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select(
            'id, image1, image2, image3, name, price, rating, stock, description, is_popular, is_new',
          )
          .or('is_popular.eq.true,is_new.eq.true');

      setState(() {
        final products = response.map(_parseProductData).toList();
        _popularProducts =
            products.where((p) => p['is_popular'] == true).toList()
              ..shuffle(Random());
        _newProducts = products.where((p) => p['is_new'] == true).toList()
          ..shuffle(Random());
        _isLoadingPopular = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPopular = false;
      });
      debugPrint('Error fetching popular products: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching popular products: $e')),
        );
      }
    }
  }

  Future<void> _fetchFeaturedProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select(
            'id, image1, image2, image3, name, price, rating, stock, description, is_featured',
          )
          .eq('is_featured', true);

      setState(() {
        _featuredProducts = response.map(_parseProductData).toList()
          ..shuffle(Random());
        _isLoadingFeatured = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingFeatured = false;
      });
      debugPrint('Error fetching featured products: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching featured products: $e')),
        );
      }
    }
  }

  Map<String, dynamic> _parseProductData(Map<String, dynamic> product) {
    return {
      'id': product['id'],
      'image1': product['image1'] ?? '',
      'image2': product['image2'] ?? '',
      'image3': product['image3'] ?? '',
      'name': product['name'] ?? 'Unnamed Product',
      'price': product['price'] is num
          ? (product['price'] as num).toStringAsFixed(0)
          : product['price']?.toString() ?? '0',
      'rate': product['rating']?.toInt() ?? 0,
      'stock': product['stock']?.toString() ?? 'N/A',
      'description': product['description'] ?? 'No description available',
      'is_popular': product['is_popular'] ?? false,
      'is_new': product['is_new'] ?? false,
      'is_best': product['is_best'] ?? false,
      'is_featured': product['is_featured'] ?? false,
    };
  }

  TextStyle _headlineLarge(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: TColors.white,
      height: 1.2,
    );
  }

  TextStyle _headlineMedium(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).textTheme.headlineMedium?.color,
      height: 1.3,
    );
  }

  TextStyle _bodyLarge(BuildContext context) {
    return GoogleFonts.openSans(
      fontSize: 14,
      color: TColors.white.withOpacity(0.9),
      height: 1.5,
    );
  }

  TextStyle _bodyMedium(BuildContext context) {
    return GoogleFonts.openSans(
      fontSize: 12,
      color: TColors.textsecondary,
      height: 1.5,
    );
  }

  Widget _buildShimmerEffect() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.65,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: dark ? TColors.darkGrey : TColors.softgrey,
          highlightColor: TColors.grey,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(_cardPadding * 0.8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 80, height: 12, color: Colors.white),
                      SizedBox(height: _elementPadding * 0.5),
                      Container(width: 50, height: 10, color: Colors.white),
                      SizedBox(height: _elementPadding * 0.5),
                      Container(width: 60, height: 10, color: Colors.white),
                      SizedBox(height: _elementPadding),
                      Container(
                        width: double.infinity,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedShimmerEffect() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: dark ? TColors.darkGrey : TColors.softgrey,
          highlightColor: TColors.grey,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.all(_cardPadding * 0.8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 100, height: 14, color: Colors.white),
                      SizedBox(height: _elementPadding * 0.5),
                      Container(width: 120, height: 10, color: Colors.white),
                      Container(width: 100, height: 10, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addToCart(Map<String, dynamic> product) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to add to cart')),
        );
      }
      return;
    }

    try {
      await _supabase.from('cart').upsert({
        'user_id': userId,
        'product_id': product['id'],
        'name': product['name'],
        'price': product['price'],
        'image1': product['image1'],
        'quantity': 1,
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Added to cart')));
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding to cart: $e')));
      }
    }
  }

  Widget _buildProductImage(String? imageUrl) {
    return imageUrl != null && imageUrl.isNotEmpty
        ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Shimmer.fromColors(
                baseColor: dark ? TColors.darkGrey : TColors.softgrey,
                highlightColor: TColors.grey,
                child: Container(color: Colors.white),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[200],
              child: const Icon(
                Icons.image_not_supported,
                size: 40,
                color: TColors.grey,
              ),
            ),
          )
        : Container(
            color: Colors.grey[200],
            child: const Icon(
              Icons.image_not_supported,
              size: 40,
              color: TColors.grey,
            ),
          );
  }

  Widget _buildPopularProductCard(Map<String, dynamic> product) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: dark ? TColors.darkContainer : TColors.lightContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: _buildProductImage(product['image1']),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(_cardPadding * 0.8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: dark ? TColors.white : TColors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: _elementPadding * 0.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₦${product['price']}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: TColors.primary,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 12),
                        SizedBox(width: _elementPadding * 0.25),
                        Text(
                          '${product['rate'] ?? 0}.0',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: dark ? TColors.white : TColors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: _elementPadding * 0.5),
                Text(
                  'Stock: ${product['stock']}',
                  style: GoogleFonts.poppins(fontSize: 9, color: TColors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: _elementPadding * 0.75),
                SizedBox(
                  width: double.infinity,
                  height: 28,
                  child: ElevatedButton(
                    onPressed: () => _addToCart(product),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: _cardPadding * 0.8,
                      ),
                      backgroundColor: TColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Add to Cart',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: _elementPadding * 0.5),
                        const Icon(Iconsax.add, size: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProductCard(Map<String, dynamic> product) {
    final imageUrl = product['image1'] ?? '';
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: imageUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) =>
                    Container(color: Colors.grey[200]),
              )
            : null,
        color: imageUrl.isEmpty ? Colors.grey[200] : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.3),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.all(_cardPadding * 0.8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: TColors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: _elementPadding * 0.5),
                  Text(
                    product['description'],
                    style: GoogleFonts.openSans(
                      fontSize: 9,
                      color: TColors.white.withOpacity(0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndustryChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: dark
            ? TColors.darkContainer.withOpacity(0.4)
            : TColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark
              ? TColors.white.withOpacity(0.3)
              : TColors.primary.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: dark ? TColors.white : TColors.primary,
        ),
      ),
    );
  }

  Widget _buildOfferingCard(Map<String, dynamic> offering) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: BorderSide(
          color: dark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      color: dark ? TColors.darkContainer : TColors.lightContainer,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(0),
              ),
              child: Container(
                height: 120,
                color: Colors.grey[200],
                child: Stack(
                  children: [
                    if (offering['image'] != null)
                      Image.asset(
                        offering['image'],
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: TColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          offering['icon'],
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(_cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offering['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: dark ? TColors.white : TColors.black,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    offering['description'],
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: dark ? TColors.lightgrey : TColors.darkGrey,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),
                  InkWell(
                    onTap: () {},
                    child: Row(
                      children: [
                        Text(
                          'Learn more',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: TColors.primary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 12,
                          color: TColors.primary,
                        ),
                      ],
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

  Widget _buildTestimonialCard(Map<String, dynamic> testimonial) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: dark ? TColors.darkContainer : TColors.lightContainer,
      child: Padding(
        padding: EdgeInsets.all(_cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (testimonial['image'] != null)
                  ClipOval(
                    child: Image.asset(
                      testimonial['image'],
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testimonial['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: dark ? TColors.white : TColors.black,
                      ),
                    ),
                    Text(
                      testimonial['location'],
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: dark ? TColors.lightgrey : TColors.darkGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              testimonial['quote'],
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: dark ? TColors.white : TColors.black,
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCtaButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: TColors.primary,
        foregroundColor: TColors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildHeroSection() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Container(
              key: ValueKey<int>(_currentBackgroundIndex),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_backgroundImages[_currentBackgroundIndex]),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.2),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: TColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Welcome to MBB Agrotech',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: TColors.white,
                    ),
                  ),
                ),
                SizedBox(height: _elementPadding * 2),
                Text(
                  'Growing Smart,\nFeeding the Future',
                  style: _headlineLarge(context),
                ),
                SizedBox(height: _elementPadding * 2),
                Text(
                  'A forward-thinking agricultural technology company dedicated to revolutionizing farming in Nigeria and beyond.',
                  style: _bodyLarge(context).copyWith(fontSize: 12),
                ),
                SizedBox(height: _elementPadding * 2),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildIndustryChip('Smart Farming'),
                    _buildIndustryChip('Hydroponics'),
                    _buildIndustryChip('Agro-Consulting'),
                    _buildIndustryChip('Greenhouse Farming'),
                    _buildIndustryChip('Digital Agriculture'),
                  ],
                ),
                SizedBox(height: _elementPadding * 3),
                Row(
                  children: [
                    _buildCtaButton('Explore Solutions', () {}),
                    SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => const ContactUsDialog(),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        side: BorderSide(color: TColors.white, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Contact Us',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: TColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionsSection() {
    return Container(
      color: dark ? TColors.dark : TColors.light,
      padding: EdgeInsets.symmetric(
        vertical: _sectionPadding,
        horizontal: _screenPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Solutions',
            style: _headlineMedium(
              context,
            ).copyWith(color: dark ? TColors.white : TColors.black),
          ),
          SizedBox(height: _elementPadding),
          Text(
            'Comprehensive solutions to modernize your farming operations.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: dark ? TColors.lightgrey : TColors.darkGrey,
            ),
          ),
          SizedBox(height: _elementPadding * 2),
          SizedBox(
            height: 260, // Increased height to accommodate card content
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _offerings.length,
              itemBuilder: (context, index) {
                return Container(
                  width:
                      MediaQuery.of(context).size.width *
                      0.6, // Responsive width
                  margin: EdgeInsets.only(right: _elementPadding),
                  child: _buildOfferingCard(_offerings[index]),
                );
              },
              separatorBuilder: (context, index) =>
                  SizedBox(width: _elementPadding),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection() {
    return Container(
      color: dark ? TColors.dark : TColors.light,
      padding: EdgeInsets.symmetric(
        vertical: _sectionPadding,
        horizontal: _screenPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Products',
            style: _headlineMedium(
              context,
            ).copyWith(color: dark ? TColors.white : TColors.black),
          ),
          SizedBox(height: _elementPadding * 1.5),
          Text(
            'Discover our latest and most popular agricultural products',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: dark ? TColors.lightgrey : TColors.darkGrey,
            ),
          ),
          SizedBox(height: _elementPadding * 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Products',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: dark ? TColors.white : TColors.black,
                ),
              ),
              SizedBox(height: _elementPadding),
              _isLoadingPopular
                  ? _buildShimmerEffect()
                  : _newProducts.isEmpty
                  ? Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.new_releases,
                            size: 30,
                            color: dark
                                ? TColors.white.withOpacity(0.6)
                                : TColors.textsecondary,
                          ),
                          SizedBox(height: _elementPadding),
                          Text(
                            'No new products available',
                            style: _bodyMedium(context),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.65,
                          ),
                      itemCount: _newProducts.length.clamp(0, 4),
                      itemBuilder: (context, index) {
                        final product = _newProducts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailsScreen(product: product),
                              ),
                            );
                          },
                          child: _buildPopularProductCard(product),
                        );
                      },
                    ),
              SizedBox(height: _sectionPadding),
              Text(
                'Popular Products',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: dark ? TColors.white : TColors.black,
                ),
              ),
              SizedBox(height: _elementPadding),
              _isLoadingPopular
                  ? _buildShimmerEffect()
                  : _popularProducts.isEmpty
                  ? Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.production_quantity_limits,
                            size: 30,
                            color: dark
                                ? TColors.white.withOpacity(0.6)
                                : TColors.textsecondary,
                          ),
                          SizedBox(height: _elementPadding),
                          Text(
                            'No popular products available',
                            style: _bodyMedium(context),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.65,
                          ),
                      itemCount: _popularProducts.length.clamp(0, 4),
                      itemBuilder: (context, index) {
                        final product = _popularProducts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailsScreen(product: product),
                              ),
                            );
                          },
                          child: _buildPopularProductCard(product),
                        );
                      },
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedServicesSection() {
    return Container(
      color: dark ? TColors.dark : TColors.light,
      padding: EdgeInsets.symmetric(
        vertical: _sectionPadding,
        horizontal: _screenPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Featured Services',
            style: _headlineMedium(
              context,
            ).copyWith(color: dark ? TColors.white : TColors.black),
          ),
          SizedBox(height: _elementPadding * 1.5),
          _isLoadingFeatured
              ? _buildFeaturedShimmerEffect()
              : _featuredProducts.isEmpty
              ? Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.star_border,
                        size: 30,
                        color: dark
                            ? TColors.white.withOpacity(0.6)
                            : TColors.textsecondary,
                      ),
                      SizedBox(height: _elementPadding),
                      Text(
                        'No featured services found',
                        style: _bodyMedium(context),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _featuredProducts.length.clamp(0, 4),
                  itemBuilder: (context, index) {
                    final product = _featuredProducts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailsScreen(product: product),
                          ),
                        );
                      },
                      child: _buildFeaturedProductCard(product),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection() {
    return Container(
      color: dark ? TColors.dark : TColors.light,
      padding: EdgeInsets.symmetric(
        vertical: _sectionPadding,
        horizontal: _screenPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What Our Customers Say',
            style: _headlineMedium(
              context,
            ).copyWith(color: dark ? TColors.white : TColors.black),
          ),
          SizedBox(height: _elementPadding),
          Text(
            'Hear from farmers and partners who trust MBB Agrotech.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: dark ? TColors.lightgrey : TColors.darkGrey,
            ),
          ),
          SizedBox(height: _elementPadding * 2),
          CarouselSlider(
            options: CarouselOptions(
              height: 200,
              autoPlay: true,
              enlargeCenterPage: true,
              aspectRatio: 16 / 9,
              viewportFraction: 0.8,
            ),
            items: _testimonials.map((testimonial) {
              return _buildTestimonialCard(testimonial);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: _sectionPadding,
        horizontal: _screenPadding,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TColors.primary.withOpacity(0.1),
            TColors.primary.withOpacity(0.3),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'Book a Free Consultation',
            style: _headlineMedium(
              context,
            ).copyWith(color: dark ? TColors.white : TColors.black),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: _elementPadding),
          Text(
            'Speak with our experts to find the best solutions for your farm.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: dark ? TColors.lightgrey : TColors.darkGrey,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: _elementPadding * 2),
          _buildCtaButton('Book a Consultation', () {
            showDialog(
              context: context,
              builder: (context) => const BookConsultationDialog(),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    dark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeroSection()),
        SliverToBoxAdapter(child: _buildSolutionsSection()),
        SliverToBoxAdapter(child: _buildProductsSection()),
        SliverToBoxAdapter(child: _buildFeaturedServicesSection()),
        SliverToBoxAdapter(child: _buildTestimonialsSection()),
        SliverToBoxAdapter(child: _buildCtaSection()),
        const SliverToBoxAdapter(child: Footer()),
      ],
    );
  }
}
