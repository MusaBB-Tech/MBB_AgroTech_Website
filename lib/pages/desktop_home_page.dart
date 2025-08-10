import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/constants/colors.dart';
import '../widgets/footer.dart';
import 'product_detail_screen.dart';
import 'dart:async';
import 'dart:math';

class DesktopHomePage extends StatefulWidget {
  const DesktopHomePage({super.key});

  @override
  State<DesktopHomePage> createState() => _DesktopHomePageState();
}

class _DesktopHomePageState extends State<DesktopHomePage> {
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
  bool dark = false;
  bool _isLoadingPopular = true;
  bool _isLoadingFeatured = true;
  final SupabaseClient _supabase = Supabase.instance.client;

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

  @override
  void initState() {
    super.initState();
    _backgroundTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
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
        _popularProducts = response.map((product) {
          String imageUrl = product['image1'] as String? ?? '';
          return {
            'id': product['id'],
            'image1': imageUrl,
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
        }).toList()..shuffle(Random());
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
            'id, image1, image2, image3, name, price, rating, stock, description',
          )
          .eq('is_featured', true);

      setState(() {
        _featuredProducts = response.map((product) {
          String imageUrl = product['image1'] as String? ?? '';
          return {
            'id': product['id'],
            'image1': imageUrl,
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
        }).toList()..shuffle(Random());
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

  TextStyle _headlineLarge(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 52,
      fontWeight: FontWeight.w800,
      color: TColors.white,
      height: 1.2,
      letterSpacing: -0.5,
    );
  }

  TextStyle _headlineMedium(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      color: Theme.of(context).textTheme.headlineMedium?.color,
      height: 1.3,
      letterSpacing: -0.3,
    );
  }

  TextStyle _headlineSmall(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: TColors.white,
      height: 1.4,
    );
  }

  TextStyle _titleLarge(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: dark ? TColors.white : TColors.black,
      height: 1.4,
    );
  }

  TextStyle _bodyLarge(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 18,
      color: TColors.white.withOpacity(0.9),
      height: 1.6,
      fontWeight: FontWeight.w400,
    );
  }

  TextStyle _bodyMedium(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 16,
      color: TColors.white.withOpacity(0.9),
      height: 1.6,
      fontWeight: FontWeight.w400,
    );
  }

  TextStyle _labelLarge(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: TColors.white,
    );
  }

  Widget _buildShimmerEffect() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: dark ? TColors.darkGrey : TColors.softgrey,
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
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        mainAxisExtent: 200,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: dark ? TColors.darkGrey : TColors.grey,
          highlightColor: dark ? TColors.grey : TColors.grey,
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
                size: 50,
                color: TColors.grey,
              ),
            ),
          )
        : Container(
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
      color: dark ? TColors.darkContainer : TColors.lightContainer,
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
                    color: dark ? TColors.white : TColors.black,
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
                            color: dark ? TColors.white : TColors.black,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    product['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 24,
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
                      fontSize: 16,
                      color: TColors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
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

  Widget _buildIndustryChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: dark
            ? TColors.darkContainer.withOpacity(0.4)
            : TColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
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
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: dark ? TColors.white : TColors.primary,
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: dark ? TColors.darkContainer : TColors.lightContainer,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: TColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: dark ? TColors.lightgrey : TColors.darkGrey,
              ),
            ),
          ],
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
          color: dark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      color: dark ? TColors.darkContainer : TColors.lightContainer,
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
                height: 180,
                color: Colors.grey[200],
                child: Stack(
                  children: [
                    if (offering['image'] != null)
                      Image.asset(
                        offering['image'],
                        height: 180,
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
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: TColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          offering['icon'],
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offering['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: dark ? TColors.white : TColors.black,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    offering['description'],
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: dark ? TColors.lightgrey : TColors.darkGrey,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {},
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

  @override
  Widget build(BuildContext context) {
    dark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
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
                        image: AssetImage(
                          _backgroundImages[_currentBackgroundIndex],
                        ),
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
                    constraints: const BoxConstraints(maxWidth: 1200),
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
                        const SizedBox(height: 24),
                        Text(
                          'Growing Smart,\nFeeding the Future',
                          style: _headlineLarge(context),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 600,
                          child: Text(
                            'A forward-thinking agricultural technology company dedicated to revolutionizing farming in Nigeria and beyond through smart farming techniques and modern agri-tech solutions.',
                            style: _bodyLarge(context),
                          ),
                        ),
                        const SizedBox(height: 32),
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
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: TColors.primary,
                                foregroundColor: TColors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                'Explore Solutions',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                side: BorderSide(
                                  color: TColors.white,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
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
          ),
        ),

        SliverToBoxAdapter(
          child: Container(
            color: dark ? TColors.dark : TColors.light,
            padding: const EdgeInsets.symmetric(vertical: 80),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: 1200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Our Solutions',
                        style: _headlineMedium(
                          context,
                        ).copyWith(color: dark ? TColors.white : TColors.black),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Comprehensive solutions to modernize your farming operations and maximize productivity.',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: dark ? TColors.lightgrey : TColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 48),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
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
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Container(
            color: dark ? TColors.dark : TColors.light,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Popular Products',
                  style: _headlineMedium(
                    context,
                  ).copyWith(color: dark ? TColors.white : TColors.black),
                ),
                const SizedBox(height: 20),
                _isLoadingPopular
                    ? _buildShimmerEffect()
                    : _popularProducts.isEmpty
                    ? Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.production_quantity_limits,
                              size: 48,
                              color: dark
                                  ? TColors.white.withOpacity(0.6)
                                  : TColors.textsecondary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No popular products found',
                              style: _bodyMedium(context).copyWith(
                                color: dark ? TColors.white : TColors.black,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.7,
                            ),
                        itemCount: _popularProducts.length.clamp(0, 10),
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
          ),
        ),

        SliverToBoxAdapter(
          child: Container(
            color: dark ? TColors.dark : TColors.light,
            padding: const EdgeInsets.symmetric(vertical: 80),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: 1200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Featured Services',
                        style: _headlineMedium(
                          context,
                        ).copyWith(color: dark ? TColors.white : TColors.black),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Specialized services to enhance your agricultural operations',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: dark ? TColors.lightgrey : TColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 48),
                      _isLoadingFeatured
                          ? _buildFeaturedShimmerEffect()
                          : _featuredProducts.isEmpty
                          ? Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.star_border,
                                    size: 50,
                                    color: dark
                                        ? TColors.white.withOpacity(0.6)
                                        : TColors.textsecondary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No featured services found',
                                    style: _bodyMedium(context).copyWith(
                                      color: dark
                                          ? TColors.white
                                          : TColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 1.5,
                                    crossAxisSpacing: 24,
                                    mainAxisSpacing: 24,
                                    mainAxisExtent: 200,
                                  ),
                              itemCount: _featuredProducts.length.clamp(0, 6),
                              itemBuilder: (context, index) {
                                final product = _featuredProducts[index];
                                return _buildFeaturedProductCard(product);
                              },
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 120),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: 800,
                  child: Column(
                    children: [
                      Text(
                        'Ready to Transform Your Farming?',
                        style: _headlineMedium(
                          context,
                        ).copyWith(color: dark ? TColors.white : TColors.black),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Join hundreds of farmers who are already benefiting from our innovative solutions',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: dark ? TColors.lightgrey : TColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          foregroundColor: TColors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Get Started Today',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: Footer()),
      ],
    );
  }
}
