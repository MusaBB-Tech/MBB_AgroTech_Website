import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
  static const _maxContentWidth = 1000.0;
  static const _sectionPadding = EdgeInsets.symmetric(
    vertical: 60,
    horizontal: 40,
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
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  List<Map<String, dynamic>> _popularProducts = [];
  List<Map<String, dynamic>> _newProducts = [];
  List<Map<String, dynamic>> _featuredProducts = [];
  bool _darkMode = false;
  bool _isLoadingPopular = true;
  bool _isLoadingFeatured = true;
  final SupabaseClient _supabase = Supabase.instance.client;
  final Map<String, dynamic> _navigationHistory = {};

  // Data
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

  @override
  void initState() {
    super.initState();
    _startBackgroundTimer();
    _fetchPopularProducts();
    _fetchFeaturedProducts();

    // Initialize scroll controller listener for scroll-to-top button
    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showScrollToTop) {
        setState(() {
          _showScrollToTop = true;
        });
      } else if (_scrollController.offset <= 300 && _showScrollToTop) {
        setState(() {
          _showScrollToTop = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _backgroundTimer.cancel();
    _scrollController.dispose();
    // Clear cached data for memory management
    _popularProducts.clear();
    _newProducts.clear();
    _featuredProducts.clear();
    _navigationHistory.clear();
    super.dispose();
  }

  // Background image timer
  void _startBackgroundTimer() {
    _backgroundTimer = Timer.periodic(_backgroundChangeDuration, (timer) {
      setState(() {
        _currentBackgroundIndex =
            (_currentBackgroundIndex + 1) % _backgroundImages.length;
      });
    });
  }

  // Data fetching methods
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
      setState(() => _isLoadingPopular = false);
      _showErrorSnackbar('Error fetching popular products: $e');
      debugPrint('Error fetching popular products: $e');
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
      setState(() => _isLoadingFeatured = false);
      _showErrorSnackbar('Error fetching featured products: $e');
      debugPrint('Error fetching featured products: $e');
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

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    debugPrint(message);
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
      _showErrorSnackbar('Error adding to cart: $e');
    }
  }

  // Text styles
  TextStyle _headlineLarge(BuildContext context) => GoogleFonts.poppins(
    fontSize: 42,
    fontWeight: FontWeight.w800,
    color: TColors.white,
    height: 1.2,
    letterSpacing: -0.5,
  );

  TextStyle _headlineMedium(BuildContext context) => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: Theme.of(context).textTheme.headlineMedium?.color,
    height: 1.3,
    letterSpacing: -0.3,
  );

  TextStyle _headlineSmall(BuildContext context) => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: TColors.white,
    height: 1.4,
  );

  TextStyle _titleLarge(BuildContext context) => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: _darkMode ? TColors.white : TColors.black,
    height: 1.4,
  );

  TextStyle _bodyLarge(BuildContext context) => GoogleFonts.inter(
    fontSize: 16,
    color: TColors.white.withOpacity(0.9),
    height: 1.6,
    fontWeight: FontWeight.w400,
  );

  TextStyle _bodyMedium(BuildContext context) => GoogleFonts.inter(
    fontSize: 14,
    color: TColors.white.withOpacity(0.9),
    height: 1.6,
    fontWeight: FontWeight.w400,
  );

  TextStyle _labelLarge(BuildContext context) => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: TColors.white,
  );

  // Widget builders
  Widget _buildShimmerEffect() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
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
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
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
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedShimmerEffect() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        mainAxisExtent: 200,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: _darkMode ? TColors.darkGrey : TColors.grey,
        highlightColor: _darkMode ? TColors.grey : TColors.grey,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(
    String? imageUrl, {
    double height = 100,
    double width = 100,
  }) {
    return SizedBox(
      height: height,
      width: width,
      child: imageUrl != null && imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Shimmer.fromColors(
                  baseColor: _darkMode ? TColors.darkGrey : TColors.softgrey,
                  highlightColor: TColors.grey,
                  child: Container(color: Colors.white),
                );
              },
              errorBuilder: (context, error, stackTrace) =>
                  _buildPlaceholderImage(height: height, width: width),
            )
          : _buildPlaceholderImage(height: height, width: width),
    );
  }

  Widget _buildPlaceholderImage({double height = 100, double width = 100}) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: Icon(Icons.image_not_supported, size: 30, color: TColors.grey),
    );
  }

  Widget _buildVerticalProductItem(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        _navigationHistory['last_product'] = product['name'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _darkMode ? Colors.grey[900] : Colors.grey[100],
          boxShadow: [
            BoxShadow(
              color: _darkMode ? Colors.black26 : Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildProductImage(
                product['image1'],
                height: double.infinity,
                width: double.infinity,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    product['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: TColors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['description'],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: TColors.white.withOpacity(0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
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
                      ElevatedButton(
                        onPressed: () => _addToCart(product),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          backgroundColor: TColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Add',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Iconsax.add, size: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
              child: _buildProductImage(
                product['image1'],
                height: double.infinity,
                width: double.infinity,
              ),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _darkMode ? TColors.white : TColors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Stock: ${product['stock']}',
                  style: GoogleFonts.poppins(fontSize: 14, color: TColors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₦${product['price']}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: TColors.primary,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
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
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _addToCart(product),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: TColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                        const Icon(Iconsax.add, size: 14),
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.1),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  product['name'],
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: TColors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  product['description'],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: TColors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₦${product['price']}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: TColors.primary,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _addToCart(product),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        backgroundColor: TColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Add',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Iconsax.add, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndustryChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _darkMode
            ? TColors.darkContainer.withOpacity(0.4)
            : TColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _darkMode
              ? TColors.white.withOpacity(0.3)
              : TColors.primary.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _darkMode ? TColors.white : TColors.primary,
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
          color: _darkMode ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      color: _darkMode ? TColors.darkContainer : TColors.lightContainer,
      child: InkWell(
        onTap: () => _handleCardTap(offering),
        borderRadius: BorderRadius.circular(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(0),
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
                        padding: const EdgeInsets.all(12),
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
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _darkMode ? TColors.white : TColors.black,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    offering['description'],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: _darkMode ? TColors.lightgrey : TColors.darkGrey,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _handleLearnMore(),
                    child: Row(
                      children: [
                        Text(
                          'Learn more',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: TColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _darkMode ? TColors.white : TColors.black,
                      ),
                    ),
                    Text(
                      testimonial['location'],
                      style: GoogleFonts.inter(
                        fontSize: 14,
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
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: _darkMode ? TColors.white : TColors.black,
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
      onPressed: () {
        _navigationHistory['last_cta'] = label;
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: TColors.primary,
        foregroundColor: TColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
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
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
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
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: TColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Welcome to MBB Agrotech',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Growing Smart,\nFeeding the Future',
                    style: _headlineLarge(context),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 500,
                    child: Text(
                      'A forward-thinking agricultural technology company dedicated to revolutionizing farming in Nigeria and beyond through smart farming techniques and modern agri-tech solutions.',
                      style: _bodyLarge(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildIndustryChip('Smart Farming'),
                      _buildIndustryChip('Hydroponics'),
                      _buildIndustryChip('Agro-Consulting'),
                      _buildIndustryChip('Greenhouse Farming'),
                      _buildIndustryChip('Digital Agriculture'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      _buildCtaButton('Explore Solutions', () {
                        _scrollController.animateTo(
                          MediaQuery.of(context).size.height,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () {
                          _navigationHistory['last_action'] = 'contact_us';
                          // Show contact us dialog
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: TColors.white, width: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Contact Us',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
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
          ),
        ],
      ),
    );
  }

  // NEW SECTION: What Makes Us Special
  Widget _buildWhatMakesUsSpecialSection() {
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
                'What Makes Us Special',
                style: _headlineMedium(
                  context,
                ).copyWith(color: _darkMode ? TColors.white : TColors.black),
              ),
              const SizedBox(height: 12),
              Text(
                'Smart Farming & Innovation',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: TColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'At MBB Agrotech, we are on a mission to revolutionize agriculture through smart farming, hydroponics, and innovative agri-tech solutions — growing healthier food and creating sustainable systems for the betterment of humanity.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: _darkMode ? TColors.lightgrey : TColors.darkGrey,
                  height: 1.6,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/smart_farming.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
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
                'Comprehensive solutions to modernize your farming operations and maximize productivity.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: _darkMode ? TColors.lightgrey : TColors.darkGrey,
                ),
              ),
              const SizedBox(height: 32),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: _offerings.length,
                itemBuilder: (context, index) =>
                    _buildOfferingCard(_offerings[index]),
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
            'Our Products',
            style: _headlineMedium(
              context,
            ).copyWith(color: _darkMode ? TColors.white : TColors.black),
          ),
          const SizedBox(height: 12),
          Text(
            'Discover our latest and most popular agricultural products',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: _darkMode ? TColors.lightgrey : TColors.darkGrey,
            ),
          ),
          const SizedBox(height: 24),
          if (_isLoadingPopular)
            _buildShimmerEffect()
          else if (_popularProducts.isEmpty && _newProducts.isEmpty)
            _buildEmptyState(
              icon: Icons.production_quantity_limits,
              message: 'No products available at the moment',
            )
          else
            LayoutBuilder(
              builder: (context, constraints) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Products',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _darkMode ? TColors.white : TColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _newProducts.isEmpty
                      ? _buildEmptyState(
                          icon: Icons.new_releases,
                          message: 'No new products available',
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.75,
                              ),
                          itemCount: min(4, _newProducts.length),
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () {
                              _navigationHistory['last_product'] =
                                  _newProducts[index]['name'];
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailsScreen(
                                    product: _newProducts[index],
                                  ),
                                ),
                              );
                            },
                            child: _buildPopularProductCard(
                              _newProducts[index],
                            ),
                          ),
                        ),
                  const SizedBox(height: 32),
                  Text(
                    'Popular Products',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _darkMode ? TColors.white : TColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _popularProducts.isEmpty
                      ? _buildEmptyState(
                          icon: Icons.trending_up,
                          message: 'No popular products available',
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.75,
                              ),
                          itemCount: min(4, _popularProducts.length),
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () {
                              _navigationHistory['last_product'] =
                                  _popularProducts[index]['name'];
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailsScreen(
                                    product: _popularProducts[index],
                                  ),
                                ),
                              );
                            },
                            child: _buildPopularProductCard(
                              _popularProducts[index],
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
                'Specialized services to enhance your agricultural operations',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: _darkMode ? TColors.lightgrey : TColors.darkGrey,
                ),
              ),
              const SizedBox(height: 32),
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
                            mainAxisExtent: 200,
                          ),
                      itemCount: _featuredProducts.length.clamp(0, 4),
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () {
                          _navigationHistory['last_product'] =
                              _featuredProducts[index]['name'];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsScreen(
                                product: _featuredProducts[index],
                              ),
                            ),
                          );
                        },
                        child: _buildFeaturedProductCard(
                          _featuredProducts[index],
                        ),
                      ),
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
                'Hear from farmers and partners who trust MBB Agrotech.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: _darkMode ? TColors.lightgrey : TColors.darkGrey,
                ),
              ),
              const SizedBox(height: 32),
              CarouselSlider(
                options: CarouselOptions(
                  height: 250,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 2.0,
                  autoPlayInterval: const Duration(seconds: 5),
                  viewportFraction: 0.6,
                ),
                items: _testimonials
                    .map((testimonial) => _buildTestimonialCard(testimonial))
                    .toList(),
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
          width: 600,
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
                'Speak with our experts to find the best solutions for your farm.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: _darkMode ? TColors.lightgrey : TColors.darkGrey,
                ),
              ),
              const SizedBox(height: 24),
              _buildCtaButton('Book a Consultation', () {
                // Show consultation dialog
              }),
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
          const SizedBox(height: 12),
          Text(
            message,
            style: _bodyMedium(
              context,
            ).copyWith(color: _darkMode ? TColors.white : TColors.black),
          ),
        ],
      ),
    );
  }

  void _handleCardTap(Map<String, dynamic> offering) {
    _navigationHistory['last_offering'] = offering['title'];
    // Implement card tap functionality
  }

  void _handleLearnMore() {
    _navigationHistory['last_action'] = 'learn_more';
    // Implement learn more functionality
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    _darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeroSection()),
          SliverToBoxAdapter(child: _buildWhatMakesUsSpecialSection()),
          SliverToBoxAdapter(child: _buildSolutionsSection()),
          SliverToBoxAdapter(child: _buildPopularProductsSection()),
          SliverToBoxAdapter(child: _buildFeaturedServicesSection()),
          SliverToBoxAdapter(child: _buildTestimonialsSection()),
          SliverToBoxAdapter(child: _buildCtaSection()),
          const SliverToBoxAdapter(child: Footer()),
        ],
      ),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: TColors.primary,
              mini: true,
              child: const Icon(Icons.arrow_upward, color: TColors.white),
            )
          : null,
    );
  }
}
