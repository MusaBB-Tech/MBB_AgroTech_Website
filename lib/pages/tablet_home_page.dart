import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../utils/constants/colors.dart';
import '../widgets/footer.dart';
import 'product_detail_screen.dart';
import 'dart:async';
import 'dart:math';

class TabletHomePage extends StatefulWidget {
  const TabletHomePage({super.key});

  @override
  State<TabletHomePage> createState() => _TabletHomePageState();
}

class _TabletHomePageState extends State<TabletHomePage> {
  // Constants
  static const _backgroundChangeDuration = Duration(seconds: 5);
  static const _maxContentWidth = 800.0;
  static const _sectionPadding = EdgeInsets.symmetric(
    vertical: 40,
    horizontal: 32,
  );

  // State variables
  final List<String> _backgroundImages = [
    'assets/images/hydroponic_farm.jpg',
    'assets/images/greenhouse.jpg',
    'assets/images/farm_monitoring.jpg',
    'assets/images/smart_farming.jpg',
  ];
  int _currentBackgroundIndex = 0;
  late Timer _backgroundTimer;

  List<Map<String, dynamic>> _popularProducts = [];
  List<Map<String, dynamic>> _featuredProducts = [];
  bool _darkMode = false;
  bool _isLoadingPopular = true;
  bool _isLoadingFeatured = true;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Data
  final List<Map<String, dynamic>> _offerings = [
    {
      'image': 'assets/images/hydroponic_system.jpg',
      'title': 'Hydroponic Systems',
      'description':
          'Soil-less farming for high-yield crops in limited spaces.',
      'icon': Icons.water_drop_outlined,
    },
    {
      'image': 'assets/images/greenhouse.jpg',
      'title': 'Greenhouse Solutions',
      'description': 'Climate-controlled farming for year-round production.',
      'icon': Icons.grass_outlined,
    },
    {
      'image': 'assets/images/farm_monitoring.jpg',
      'title': 'Smart Monitoring',
      'description': 'Real-time farm analytics with IoT sensors.',
      'icon': Icons.monitor_heart_outlined,
    },
  ];

  final List<Map<String, dynamic>> _testimonials = [
    {
      'name': 'Chidi Okeke',
      'location': 'Lagos, Nigeria',
      'quote': 'MBB Agrotech doubled our yield with their hydroponic system!',
      'image': 'assets/images/testimonial1.jpg',
    },
    {
      'name': 'Aisha Bello',
      'location': 'Abuja, Nigeria',
      'quote': 'Their training transformed our farm with smart tech.',
      'image': 'assets/images/testimonial2.jpg',
    },
  ];

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
            'id, image1, image2, image3, name, price, rating, stock, description',
          )
          .eq('is_popular', true);

      setState(() {
        _popularProducts =
            response.map((product) => _parseProductData(product)).toList()
              ..shuffle(Random());
        _isLoadingPopular = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPopular = false;
      });
      _showErrorSnackbar('Error fetching popular products: $e');
    }
  }

  Future<void> _fetchFeaturedProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select(
            'id, image1, image2, image3, name, price, rating, stock, description',
          )
          .eq('is_featured', true);

      setState(() {
        _featuredProducts =
            response.map((product) => _parseProductData(product)).toList()
              ..shuffle(Random());
        _isLoadingFeatured = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingFeatured = false;
      });
      _showErrorSnackbar('Error fetching featured products: $e');
    }
  }

  Map<String, dynamic> _parseProductData(Map<String, dynamic> product) {
    return {
      'id': product['id'],
      'image1': product['image1'] as String? ?? '',
      'image2': product['image2'] as String? ?? '',
      'image3': product['image3'] as String? ?? '',
      'name': product['name'] as String? ?? 'Unnamed Product',
      'price': product['price'] is num
          ? (product['price'] as num).toStringAsFixed(0)
          : product['price']?.toString() ?? '0',
      'rate': product['rating']?.toInt() ?? 0,
      'stock': product['stock']?.toString() ?? 'N/A',
      'description':
          product['description'] as String? ?? 'No description available',
    };
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    debugPrint(message);
  }

  TextStyle _headlineLarge(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      color: TColors.white,
      height: 1.2,
    );
  }

  TextStyle _headlineMedium(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: Theme.of(context).textTheme.headlineMedium?.color,
      height: 1.3,
    );
  }

  TextStyle _bodyLarge(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 16,
      color: TColors.white.withOpacity(0.9),
      height: 1.5,
      fontWeight: FontWeight.w400,
    );
  }

  TextStyle _bodyMedium(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 14,
      color: _darkMode ? TColors.lightgrey : TColors.darkGrey,
      height: 1.5,
    );
  }

  Widget _buildShimmerEffect() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: _darkMode ? TColors.darkGrey : TColors.softgrey,
          highlightColor: TColors.grey,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 120, height: 16, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 80, height: 14, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 100, height: 14, color: Colors.white),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
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
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: _darkMode ? TColors.darkGrey : TColors.softgrey,
          highlightColor: TColors.grey,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addToCart(Map<String, dynamic> product) async {
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
      _showErrorSnackbar('Error adding to cart: $e');
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
                baseColor: _darkMode ? TColors.darkGrey : TColors.softgrey,
                highlightColor: TColors.grey,
                child: Container(color: Colors.white),
              );
            },
            errorBuilder: (context, error, stackTrace) =>
                _buildPlaceholderImage(),
          )
        : _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.image_not_supported,
        size: 50,
        color: TColors.grey,
      ),
    );
  }

  Widget _buildPopularProductCard(Map<String, dynamic> product) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: _darkMode ? TColors.darkContainer : TColors.lightContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: _buildProductImage(product['image1']),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _darkMode ? TColors.white : TColors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₦${product['price']}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TColors.primary,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          '${product['rate'] ?? 0}.0',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _darkMode ? TColors.white : TColors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Stock: ${product['stock']}',
                  style: GoogleFonts.poppins(fontSize: 12, color: TColors.grey),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () => _addToCart(product),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: TColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Add to Cart',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Iconsax.add, size: 16),
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.2),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    product['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: TColors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['description'],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: TColors.white.withOpacity(0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _addToCart(product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      foregroundColor: TColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Learn More'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOfferingCard(Map<String, dynamic> offering) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _darkMode ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      color: _darkMode ? TColors.darkContainer : TColors.lightContainer,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                height: 150,
                color: Colors.grey[200],
                child: Stack(
                  children: [
                    if (offering['image'] != null)
                      Image.asset(
                        offering['image'],
                        height: 150,
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
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: TColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          offering['icon'],
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offering['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _darkMode ? TColors.white : TColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    offering['description'],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _darkMode ? TColors.lightgrey : TColors.darkGrey,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {},
                    child: Row(
                      children: [
                        Text(
                          'Learn more',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: TColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          size: 14,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: _darkMode ? TColors.darkContainer : TColors.lightContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testimonial['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _darkMode ? TColors.white : TColors.black,
                      ),
                    ),
                    Text(
                      testimonial['location'],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _darkMode ? TColors.lightgrey : TColors.darkGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              testimonial['quote'],
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: _darkMode ? TColors.white : TColors.black,
                height: 1.5,
              ),
              maxLines: 3,
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildHeroSection() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
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
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: TColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'MBB Agrotech',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: TColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Smart Farming\nSolutions',
                    style: _headlineLarge(context),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 400,
                    child: Text(
                      'Revolutionizing agriculture with innovative technology for Nigerian farmers.',
                      style: _bodyLarge(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildCtaButton('Explore Now', () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionsSection() {
    return Container(
      color: _darkMode ? TColors.dark : TColors.light,
      padding: _sectionPadding,
      child: Center(
        child: SizedBox(
          width: _maxContentWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Our Solutions',
                style: _headlineMedium(
                  context,
                ).copyWith(color: _darkMode ? TColors.white : TColors.black),
              ),
              const SizedBox(height: 12),
              Text(
                'Innovative tools to enhance your farming productivity.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: _darkMode ? TColors.lightgrey : TColors.darkGrey,
                ),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: _offerings.length,
                itemBuilder: (context, index) {
                  return _buildOfferingCard(_offerings[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularProductsSection() {
    return Container(
      color: _darkMode ? TColors.dark : TColors.light,
      padding: _sectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Products',
            style: _headlineMedium(
              context,
            ).copyWith(color: _darkMode ? TColors.white : TColors.black),
          ),
          const SizedBox(height: 16),
          _isLoadingPopular
              ? _buildShimmerEffect()
              : _popularProducts.isEmpty
              ? _buildEmptyState(
                  icon: Icons.production_quantity_limits,
                  message: 'No popular products found',
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
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
    );
  }

  Widget _buildFeaturedServicesSection() {
    return Container(
      color: _darkMode ? TColors.dark : TColors.light,
      padding: _sectionPadding,
      child: Center(
        child: SizedBox(
          width: _maxContentWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Featured Services',
                style: _headlineMedium(
                  context,
                ).copyWith(color: _darkMode ? TColors.white : TColors.black),
              ),
              const SizedBox(height: 12),
              Text(
                'Specialized services for modern agriculture.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: _darkMode ? TColors.lightgrey : TColors.darkGrey,
                ),
              ),
              const SizedBox(height: 24),
              _isLoadingFeatured
                  ? _buildFeaturedShimmerEffect()
                  : _featuredProducts.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.star_border,
                      message: 'No featured services found',
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: _featuredProducts.length.clamp(0, 4),
                      itemBuilder: (context, index) {
                        final product = _featuredProducts[index];
                        return _buildFeaturedProductCard(product);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestimonialsSection() {
    return Container(
      color: _darkMode ? TColors.dark : TColors.light,
      padding: _sectionPadding,
      child: Center(
        child: SizedBox(
          width: _maxContentWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What Our Customers Say',
                style: _headlineMedium(
                  context,
                ).copyWith(color: _darkMode ? TColors.white : TColors.black),
              ),
              const SizedBox(height: 12),
              Text(
                'Hear from farmers who trust MBB Agrotech.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: _darkMode ? TColors.lightgrey : TColors.darkGrey,
                ),
              ),
              const SizedBox(height: 24),
              CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 2.0,
                  autoPlayInterval: const Duration(seconds: 5),
                  viewportFraction: 0.5,
                ),
                items: _testimonials.map((testimonial) {
                  return _buildTestimonialCard(testimonial);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCtaSection() {
    return Container(
      padding: _sectionPadding,
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
      child: Center(
        child: SizedBox(
          width: _maxContentWidth,
          child: Column(
            children: [
              Text(
                'Book a Free Consultation',
                style: _headlineMedium(
                  context,
                ).copyWith(color: _darkMode ? TColors.white : TColors.black),
              ),
              const SizedBox(height: 16),
              Text(
                'Connect with our experts for tailored farming solutions.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: _darkMode ? TColors.lightgrey : TColors.darkGrey,
                ),
              ),
              const SizedBox(height: 24),
              _buildCtaButton('Book Now', () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        children: [
          Icon(
            icon,
            size: 40,
            color: _darkMode
                ? TColors.white.withOpacity(0.6)
                : TColors.textsecondary,
          ),
          const SizedBox(height: 8),
          Text(message, style: _bodyMedium(context)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _darkMode = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeroSection()),
        SliverToBoxAdapter(child: _buildSolutionsSection()),
        SliverToBoxAdapter(child: _buildPopularProductsSection()),
        SliverToBoxAdapter(child: _buildFeaturedServicesSection()),
        SliverToBoxAdapter(child: _buildTestimonialsSection()),
        SliverToBoxAdapter(child: _buildCtaSection()),
        const SliverToBoxAdapter(child: Footer()),
      ],
    );
  }
}
