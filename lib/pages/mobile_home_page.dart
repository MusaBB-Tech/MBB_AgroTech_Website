import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/constants/colors.dart';
import '../widgets/footer.dart';
import 'product_detail_screen.dart';

class MobileHomePage extends StatefulWidget {
  const MobileHomePage({super.key});

  @override
  State<MobileHomePage> createState() => _MobileHomePageState();
}

class _MobileHomePageState extends State<MobileHomePage> {
  final List<Map<String, String>> _carouselItems = [
    {
      'image': 'assets/images/dress.jpg',
      'title': 'Elegant Dresses',
      'description': 'Explore our stunning collection of dresses',
    },
    {
      'image': 'assets/images/blouses.jpg',
      'title': 'Chic Tops',
      'description': 'Discover trendy tops and blouses',
    },
    {
      'image': 'assets/images/accessories.jpg',
      'title': 'Accessories',
      'description': 'Complete your look with stylish accessories',
    },
  ];

  List<Map<String, dynamic>> _popularProducts = [];
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
    _fetchPopularProducts();
    _fetchFeaturedProducts();
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
        }).toList();
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
        }).toList();
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
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: TColors.white,
      height: 1.2,
    );
  }

  TextStyle _headlineMedium(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).textTheme.headlineMedium?.color,
      height: 1.3,
    );
  }

  TextStyle _bodyLarge(BuildContext context) {
    return GoogleFonts.openSans(
      fontSize: 11,
      color: TColors.white.withOpacity(0.9),
      height: 1.5,
    );
  }

  TextStyle _bodyMedium(BuildContext context) {
    return GoogleFonts.openSans(
      fontSize: 10,
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

  @override
  Widget build(BuildContext context) {
    dark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: _screenPadding),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
              margin: EdgeInsets.all(_elementPadding),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[500],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: double.infinity,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    autoPlayInterval: const Duration(seconds: 5),
                    viewportFraction: 1.0,
                  ),
                  items: _carouselItems.map((item) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                dark
                                    ? TColors.dark.withOpacity(0.9)
                                    : TColors.light.withOpacity(0.9),
                                dark
                                    ? TColors.darkGrey.withOpacity(0.7)
                                    : TColors.lightgrey.withOpacity(0.7),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: dark
                                    ? Colors.black.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.2),
                                blurRadius: 6,
                                spreadRadius: 1,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                flex: 3,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: TColors.primary.withOpacity(0.5),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Image.asset(
                                      item['image']!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: EdgeInsets.all(_cardPadding),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title']!,
                                        style: _headlineLarge(context).copyWith(
                                          fontSize: 18,
                                          color: dark
                                              ? TColors.white
                                              : TColors.black,
                                          shadows: [
                                            Shadow(
                                              color: dark
                                                  ? Colors.black.withOpacity(
                                                      0.5,
                                                    )
                                                  : Colors.white.withOpacity(
                                                      0.5,
                                                    ),
                                              blurRadius: 6,
                                              offset: const Offset(1, 1),
                                            ),
                                          ],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: _elementPadding * 0.5),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: TColors.primary.withOpacity(
                                            0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          'New Collection',
                                          style: _bodyMedium(context).copyWith(
                                            color: TColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: _elementPadding),
                                      Text(
                                        item['description']!,
                                        style: _bodyLarge(context).copyWith(
                                          fontSize: 10,
                                          color: dark
                                              ? TColors.white.withOpacity(0.9)
                                              : TColors.black.withOpacity(0.9),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: _elementPadding),
                                      ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: TColors.primary,
                                          foregroundColor: TColors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          elevation: 0,
                                          shadowColor: TColors.primary
                                              .withOpacity(0.5),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Shop Now',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(
                                              width: _elementPadding * 0.5,
                                            ),
                                            const Icon(
                                              Iconsax.arrow_right_3,
                                              size: 14,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _screenPadding,
              vertical: _sectionPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Popular Products',
                  style: _headlineMedium(
                    context,
                  ).copyWith(color: dark ? TColors.white : TColors.black),
                ),
                SizedBox(height: _elementPadding * 1.5),
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
                              'No popular products found',
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
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _screenPadding,
              vertical: _sectionPadding,
            ),
            color: dark ? TColors.dark : TColors.light,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Featured Products',
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
                              'No featured products found',
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
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: _screenPadding,
              vertical: _sectionPadding,
            ),
            padding: EdgeInsets.all(_cardPadding),
            decoration: BoxDecoration(
              color: TColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: TColors.primary, width: 0.5),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    // Replace with valid URL or asset
                    'https://via.placeholder.com/150',
                    fit: BoxFit.cover,
                    height: 120,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                SizedBox(height: _elementPadding),
                Text(
                  'Special Offer',
                  style: _headlineMedium(context).copyWith(
                    fontSize: 16,
                    color: dark ? TColors.white : TColors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: _elementPadding * 0.5),
                Text(
                  'Get 20% off your first purchase! Limited time offer.',
                  style: _bodyLarge(context).copyWith(
                    fontSize: 10,
                    color: dark ? TColors.white : TColors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: _elementPadding),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: TColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Buy Now',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: Footer()),
      ],
    );
  }
}
