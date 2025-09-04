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
  int _selectedIndex = 0;

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
          _selectedIndex = _tabController.index;
        });
        _fetchProducts(_currentCategory);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
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
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
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

  Widget _buildShimmerEffect() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        return Shimmer.fromColors(
          baseColor: dark ? TColors.darkGrey : TColors.softgrey,
          highlightColor: TColors.grey,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: dark ? TColors.darkContainer : TColors.lightContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: dark ? TColors.darkGrey : Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 140,
                        height: 18,
                        color: dark ? TColors.darkGrey : Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 16,
                        color: dark ? TColors.darkGrey : Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 120,
                        height: 16,
                        color: dark ? TColors.darkGrey : Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 40,
                        decoration: BoxDecoration(
                          color: dark ? TColors.darkGrey : Colors.white,
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

  Widget _buildMobileShimmerEffect() {
    return GridView.builder(
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Show 2 products horizontally
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        return Shimmer.fromColors(
          baseColor: dark ? TColors.darkGrey : TColors.softgrey,
          highlightColor: TColors.grey,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: dark ? TColors.darkContainer : TColors.lightContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: AspectRatio(
                      aspectRatio: 2,
                      child: Container(color: Colors.white),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 100, height: 16, color: Colors.white),
                      SizedBox(height: 8),
                      Container(width: 150, height: 14, color: Colors.white),
                      SizedBox(height: 8),
                      Container(width: 80, height: 14, color: Colors.white),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
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

  Widget _buildProductCard(Map<String, dynamic> product) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: dark ? TColors.darkContainer : TColors.lightContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child:
                      product['image1'] != null && product['image1'].isNotEmpty
                      ? Image.network(
                          product['image1'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Shimmer.fromColors(
                              baseColor: dark
                                  ? TColors.darkGrey
                                  : TColors.softgrey,
                              highlightColor: TColors.grey,
                              child: Container(color: Colors.white),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Iconsax.image,
                                  size: 60,
                                  color: TColors.grey,
                                ),
                              ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Iconsax.image,
                            size: 60,
                            color: TColors.grey,
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
              ],
            ),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: dark ? TColors.white : TColors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₦${product['price']?.toStringAsFixed(2) ?? 'N/A'}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: TColors.primary,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          product['rating']?.toStringAsFixed(1) ?? '0.0',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: dark ? TColors.lightgrey : TColors.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Stock: ${product['stock']?.toString() ?? 'N/A'} | Size: ${product['size']?.toString() ?? 'N/A'}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: dark ? TColors.lightgrey : TColors.darkGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => _addToCart(product),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Iconsax.add, size: 18),
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

  Widget _buildMobileProductCard(Map<String, dynamic> product) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: dark ? TColors.darkContainer : TColors.lightContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child:
                      product['image1'] != null && product['image1'].isNotEmpty
                      ? Image.network(
                          product['image1'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Shimmer.fromColors(
                              baseColor: dark
                                  ? TColors.darkGrey
                                  : TColors.softgrey,
                              highlightColor: TColors.grey,
                              child: Container(color: Colors.white),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Iconsax.image,
                                  size: 60,
                                  color: TColors.grey,
                                ),
                              ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Iconsax.image,
                            size: 60,
                            color: TColors.grey,
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '₦${product['price']?.toStringAsFixed(2) ?? 'N/A'}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TColors.primary,
                      ),
                    ),
                    SizedBox(width: 8),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < (product['rating'] ?? 0)
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 14,
                        );
                      }),
                    ),
                  ],
                ),
                Text(
                  product['name']?.toString() ?? 'Unnamed Product',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: dark ? TColors.white : TColors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Stock: ${product['stock']?.toString() ?? 'N/A'} | Size: ${product['size']?.toString() ?? 'N/A'}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: dark ? TColors.lightgrey : TColors.darkGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _addToCart(product),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      backgroundColor: TColors.primary,
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: TColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Add to Cart',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.add_shopping_cart,
                          color: Colors.white,
                          size: 16,
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
    );
  }

  Widget _buildCategorySidebar() {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 280, // Increased width for better spacing
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: dark ? TColors.darkContainer : TColors.lightContainer,
        border: Border(
          right: BorderSide(
            color: dark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Categories',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: dark ? TColors.white : TColors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: _categories.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: dark ? Colors.grey[800] : Colors.grey[200],
                indent: 24,
                endIndent: 24,
              ),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _currentCategory == category['name'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          _currentCategory = category['name'] as String;
                          _selectedIndex = index;
                          _tabController.index = index;
                        });
                        _fetchProducts(_currentCategory);
                      },
                      child: Container(
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
                                  ? TColors.white.withOpacity(0.8)
                                  : TColors.black.withOpacity(0.8),
                              size: 20,
                            ),
                            const SizedBox(width: 16),
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
                                Icons.chevron_right,
                                color: TColors.primary,
                                size: 20,
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

  Widget _buildNavigationRail() {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (int index) {
        setState(() {
          _selectedIndex = index;
          _currentCategory = _categories[index]['name'] as String;
          _tabController.index = index;
        });
        _fetchProducts(_currentCategory);
      },
      labelType: NavigationRailLabelType.all,
      backgroundColor: dark ? TColors.darkContainer : TColors.lightContainer,
      destinations: _categories.map((category) {
        return NavigationRailDestination(
          icon: Icon(category['icon'] as IconData, size: 20),
          label: Text(
            category['name'] as String,
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryTabBar() {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: dark ? TColors.darkContainer : TColors.lightContainer,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        unselectedLabelColor: dark
            ? TColors.white.withOpacity(0.6)
            : TColors.darkGrey,
        labelColor: TColors.white,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: TColors.primary,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        dividerColor: Colors.transparent,
        tabs: _categories.map((category) {
          return Tab(
            iconMargin: const EdgeInsets.only(bottom: 4),
            icon: Icon(category['icon'] as IconData, size: 20),
            text: category['name'] as String,
          );
        }).toList(),
      ),
    );
  }

  // New method to build choice chips for mobile view
  Widget _buildCategoryChoiceChips() {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((category) {
            final isSelected = _currentCategory == category['name'];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : TColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category['name'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : dark
                            ? TColors.white
                            : TColors.black,
                      ),
                    ),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _currentCategory = category['name'] as String;
                    _selectedIndex = _categories.indexWhere(
                      (cat) => cat['name'] == category['name'],
                    );
                    _tabController.index = _selectedIndex;
                  });
                  _fetchProducts(_currentCategory);
                },
                backgroundColor: dark
                    ? TColors.darkContainer
                    : TColors.lightContainer,
                selectedColor: TColors.primary,
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? TColors.primary
                        : dark
                        ? Colors.grey[700]!
                        : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileView() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hydroponic Store',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: dark ? TColors.white : TColors.black,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: dark ? TColors.dark : TColors.light,
      ),
      backgroundColor: dark ? TColors.dark : TColors.light,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: dark ? TColors.white : TColors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: dark
                      ? TColors.white.withOpacity(0.6)
                      : TColors.darkGrey,
                ),
                filled: true,
                fillColor: dark
                    ? TColors.darkContainer
                    : TColors.lightContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                prefixIcon: Icon(
                  Iconsax.search_normal_1,
                  color: dark ? TColors.white : TColors.black,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close,
                          color: dark
                              ? TColors.white.withOpacity(0.6)
                              : TColors.darkGrey,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _filterProducts('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Replaced TabBar with Choice Chips
          _buildCategoryChoiceChips(),
          Expanded(
            child: RefreshIndicator(
              color: TColors.primary,
              backgroundColor: Colors.transparent,
              onRefresh: _refreshProducts,
              child: _isLoading
                  ? _buildMobileShimmerEffect()
                  : _filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.box_search,
                            size: 60,
                            color: dark
                                ? TColors.white.withOpacity(0.6)
                                : TColors.darkGrey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No products found',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: dark ? TColors.white : TColors.darkGrey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Try a different search term or category',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: dark
                                  ? TColors.lightgrey
                                  : TColors.darkGrey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Show 2 products horizontally
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return GestureDetector(
                          onTap: () => _showProductDetails(product),
                          child: _buildMobileProductCard(product),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    if (isMobile) {
      return _buildMobileView();
    }

    final isTablet = ResponsiveLayout.isTablet(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? TColors.dark
          : TColors.light,
      body: Row(
        children: [
          if (isDesktop) _buildCategorySidebar(),
          if (isTablet) _buildNavigationRail(),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 32 : 24,
                    32,
                    isDesktop ? 32 : 24,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hydroponic Store',
                        style: GoogleFonts.poppins(
                          fontSize: isDesktop ? 36 : 32,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? TColors.white
                              : TColors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Premium hydroponic equipment and supplies',
                        style: GoogleFonts.poppins(
                          fontSize: isDesktop ? 16 : 14,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? TColors.lightgrey
                              : TColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: isDesktop ? 500 : double.infinity,
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? TColors.white
                                : TColors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 16,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? TColors.white.withOpacity(0.6)
                                  : TColors.darkGrey,
                            ),
                            filled: true,
                            fillColor:
                                Theme.of(context).brightness == Brightness.dark
                                ? TColors.darkContainer
                                : TColors.lightContainer,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            prefixIcon: Icon(
                              Iconsax.search_normal_1,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? TColors.white
                                  : TColors.black,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? TColors.white.withOpacity(0.6)
                                          : TColors.darkGrey,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _filterProducts('');
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isDesktop && !isTablet) _buildCategoryTabBar(),
                Expanded(
                  child: RefreshIndicator(
                    color: TColors.primary,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? TColors.dark
                        : TColors.light,
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
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? TColors.white.withOpacity(0.6)
                                      : TColors.darkGrey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No products found',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? TColors.white
                                        : TColors.darkGrey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try a different search term or category',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? TColors.lightgrey
                                        : TColors.darkGrey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(24),
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: isDesktop ? 280 : 300,
                                  crossAxisSpacing: 24,
                                  mainAxisSpacing: 24,
                                  childAspectRatio: 0.75,
                                ),
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              return GestureDetector(
                                onTap: () => _showProductDetails(product),
                                child: _buildProductCard(product),
                              );
                            },
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
}
