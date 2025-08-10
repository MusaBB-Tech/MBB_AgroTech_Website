import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../../utils/constants/colors.dart';
import '../../utils/showSnackBar.dart';
import '../responsive.dart';
import 'product_detail_screen.dart';
import 'dart:math';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> _products = [];
  List<dynamic> _filteredProducts = [];
  String _currentCategory = 'All Products';
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All Products', 'icon': Iconsax.shop},
    {'name': 'Accessories', 'icon': Iconsax.cpu},
    {'name': 'Hydroponic Systems', 'icon': Iconsax.hierarchy_square},
    {'name': 'Growing Supplies', 'icon': Iconsax.box},
    {'name': 'Seeds', 'icon': Iconsax.blur},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _fetchProducts(_currentCategory);

    _searchController.addListener(() {
      _filterProducts(_searchController.text);
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentCategory =
              _categories[_tabController.index]['name'] as String;
        });
        _fetchProducts(_currentCategory);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts(String category) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final query = supabase
          .from('products')
          .select(
            'id, name, description, price, category, image1, image2, image3, stock, rating, size, color',
          );

      final response = category == 'All Products'
          ? await query
          : await query.eq('category', category);

      setState(() {
        _products = response.map((product) {
          return {
            'id': product['id'],
            'name': product['name'] as String? ?? 'Unnamed Product',
            'description':
                product['description'] as String? ?? 'No description available',
            'price': product['price'] is num
                ? (product['price'] as num).toDouble()
                : product['price']?.toDouble() ?? 0.0,
            'category': product['category'] as String? ?? '',
            'image1': product['image1'] as String? ?? '',
            'image2': product['image2'] as String? ?? '',
            'image3': product['image3'] as String? ?? '',
            'stock': product['stock'] as int? ?? 0,
            'rating': product['rating'] as num? ?? 0,
            'size': product['size'] as String? ?? 'N/A',
            'color': product['color'] as String? ?? 'N/A',
          };
        }).toList();
        _filteredProducts = _products;
        _shuffleProducts();
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Error fetching products: $error');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        CustomSnackbar.error(context, 'Error fetching products: $error');
      }
    }
  }

  void _filterProducts(String query) {
    setState(() {
      _filteredProducts = _products
          .where(
            (product) =>
                (product['name']?.toLowerCase().contains(query.toLowerCase()) ??
                    false) ||
                (product['color']?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
      _shuffleProducts();
    });
  }

  void _shuffleProducts() {
    final random = Random();
    _filteredProducts.shuffle(random);
  }

  void _showProductDetails(Map<String, dynamic> product) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProductDetailsScreen(product: product),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.1);
          const end = Offset.zero;
          const curve = Curves.easeInOutQuart;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _addToCart(Map<String, dynamic> product) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      CustomSnackbar.error(context, 'Please sign in to add to cart');
      return;
    }

    try {
      await supabase.from('cart').upsert({
        'user_id': userId,
        'product_id': product['id'],
        'name': product['name'] ?? 'Unnamed Product',
        'price': product['price'] ?? 0.0,
        'image1': product['image1'] ?? '',
        'quantity': 1,
      });

      // Show a beautiful snackbar with animation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: TColors.primary,
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Added to cart',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            left: 20,
            right: 20,
          ),
        ),
      );
    } catch (error) {
      debugPrint('Error adding to cart: $error');
      CustomSnackbar.error(context, 'Error adding to cart');
    }
  }

  Future<void> _refreshProducts() async {
    await _fetchProducts(_currentCategory);
  }

  SliverGridDelegateWithFixedCrossAxisCount getGridDelegate(
    BuildContext context,
  ) {
    int crossAxisCount = ResponsiveLayout.isMobile(context)
        ? 2
        : ResponsiveLayout.isTablet(context)
        ? 3
        : 4;
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = 16 * 2;
    double spacing = 16 * (crossAxisCount - 1);
    double cardWidth = (screenWidth - padding - spacing) / crossAxisCount;
    double minDetailsHeight = 200;
    double aspectRatio = cardWidth / (cardWidth + minDetailsHeight);
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: aspectRatio,
    );
  }

  Widget _buildShimmerEffect() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      controller: _scrollController,
      gridDelegate: getGridDelegate(context),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: dark ? TColors.darkGrey : Colors.grey[200]!,
          highlightColor: dark ? TColors.darkerGrey : Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: dark ? TColors.darkContainer : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: dark ? TColors.darkContainer : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showProductDetails(product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child:
                        product['image1'] != null &&
                            product['image1'].isNotEmpty
                        ? Image.network(
                            product['image1'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Shimmer.fromColors(
                                baseColor: dark
                                    ? TColors.darkGrey
                                    : Colors.grey[200]!,
                                highlightColor: dark
                                    ? TColors.darkerGrey
                                    : Colors.grey[100]!,
                                child: Container(color: Colors.white),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: Icon(
                                      Iconsax.image,
                                      size: 40,
                                      color: TColors.grey,
                                    ),
                                  ),
                                ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(
                                Iconsax.image,
                                size: 40,
                                color: TColors.grey,
                              ),
                            ),
                          ),
                  ),
                ),
                if (product['stock'] != null && product['stock'] <= 5)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Low Stock',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: dark
                          ? Colors.black.withOpacity(0.6)
                          : Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.heart,
                      size: 18,
                      color: TColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name']?.toString() ?? 'Unnamed Product',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: dark ? TColors.white : TColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Rating and Price row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating Stars
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            product['rating']?.toStringAsFixed(1) ?? '0.0',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: dark
                                  ? TColors.lightgrey
                                  : TColors.darkGrey,
                            ),
                          ),
                        ],
                      ),

                      // Price
                      Text(
                        '₦${product['price']?.toStringAsFixed(2) ?? 'N/A'}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: TColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Color and Size indicators
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (product['color'] != null && product['color'] != 'N/A')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: dark ? TColors.darkerGrey : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product['color'].toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: dark ? TColors.white : TColors.black,
                            ),
                          ),
                        ),

                      if (product['size'] != null && product['size'] != 'N/A')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: dark ? TColors.darkerGrey : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Size: ${product['size'].toString()}',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: dark ? TColors.white : TColors.black,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _addToCart(product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.shopping_cart, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Add to Cart',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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

  Widget _buildCategorySidebar() {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: dark ? TColors.darkContainer : Colors.white,
        border: Border(
          right: BorderSide(
            color: dark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Sidebar Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: dark ? Colors.grey[800]! : Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Categories',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: dark ? TColors.white : TColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Browse by category',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: dark ? TColors.lightgrey : TColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),

          // Category List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _currentCategory == category['name'];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          _currentCategory = category['name'] as String;
                          _tabController.index = index;
                        });
                        _fetchProducts(_currentCategory);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? TColors.primary.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: TColors.primary.withOpacity(0.3),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              category['icon'] as IconData,
                              color: isSelected
                                  ? TColors.primary
                                  : dark
                                  ? TColors.lightgrey
                                  : TColors.darkGrey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              category['name'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? TColors.primary
                                    : dark
                                    ? TColors.white
                                    : TColors.black,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              Icon(
                                Iconsax.arrow_right_3,
                                size: 18,
                                color: TColors.primary,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabBar() {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: dark ? TColors.darkContainer : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final isSelected = _currentCategory == category['name'];

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    _currentCategory = category['name'] as String;
                    _tabController.index = index;
                  });
                  _fetchProducts(_currentCategory);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? TColors.primary
                        : dark
                        ? TColors.darkGrey
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : dark
                            ? TColors.lightgrey
                            : TColors.darkGrey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category['name'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : dark
                              ? TColors.lightgrey
                              : TColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: dark ? TColors.dark : Colors.grey[50],
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ResponsiveLayout.isDesktop(context)) _buildCategorySidebar(),
          Expanded(
            child: Column(
              children: [
                // Header with Search
                Container(
                  padding: EdgeInsets.only(
                    left: ResponsiveLayout.isDesktop(context) ? 32 : 24,
                    right: ResponsiveLayout.isDesktop(context) ? 32 : 24,
                    top: 24,
                    bottom: 16,
                  ),
                  decoration: BoxDecoration(
                    color: dark ? TColors.darkContainer : Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: dark ? Colors.grey[800]! : Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Our Products',
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveLayout.isDesktop(context)
                                  ? 28
                                  : 24,
                              fontWeight: FontWeight.w700,
                              color: dark ? TColors.white : TColors.black,
                            ),
                          ),
                          if (!ResponsiveLayout.isMobile(context))
                            SizedBox(
                              width: ResponsiveLayout.isDesktop(context)
                                  ? 400
                                  : 300,
                              child: _buildSearchField(dark),
                            ),
                        ],
                      ),

                      if (ResponsiveLayout.isMobile(context)) ...[
                        const SizedBox(height: 16),
                        _buildSearchField(dark),
                      ],

                      const SizedBox(height: 16),

                      if (ResponsiveLayout.isMobile(context) ||
                          ResponsiveLayout.isTablet(context))
                        _buildCategoryTabBar(),
                    ],
                  ),
                ),

                // Products Grid
                Expanded(
                  child: RefreshIndicator(
                    color: TColors.primary,
                    backgroundColor: dark ? TColors.dark : Colors.white,
                    onRefresh: _refreshProducts,
                    child: _isLoading
                        ? _buildShimmerEffect()
                        : _filteredProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.box_search,
                                  size: 60,
                                  color: dark
                                      ? TColors.lightgrey
                                      : TColors.darkGrey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No products found',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: dark
                                        ? TColors.lightgrey
                                        : TColors.darkGrey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try a different search or category',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: dark
                                        ? TColors.lightgrey
                                        : TColors.darkGrey,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterProducts('');
                                    setState(() {
                                      _currentCategory = 'All Products';
                                      _tabController.index = 0;
                                    });
                                    _fetchProducts(_currentCategory);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: TColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    'Reset Filters',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(16),
                            child: GridView.builder(
                              controller: _scrollController,
                              gridDelegate: getGridDelegate(context),
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = _filteredProducts[index];
                                return _buildProductCard(product);
                              },
                            ),
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

  Widget _buildSearchField(bool dark) {
    return TextField(
      controller: _searchController,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: dark ? TColors.white : TColors.black,
      ),
      decoration: InputDecoration(
        hintText: 'Search for products...',
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: dark ? TColors.lightgrey : TColors.darkGrey,
        ),
        filled: true,
        fillColor: dark ? TColors.darkerGrey : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        prefixIcon: Icon(
          Iconsax.search_normal,
          size: 18,
          color: dark ? TColors.lightgrey : TColors.darkGrey,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  _searchController.clear();
                  _filterProducts('');
                },
              )
            : null,
      ),
    );
  }
}
