import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/constants/colors.dart';
import '../responsive.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _pageController = PageController();
  final SupabaseClient _supabase = Supabase.instance.client;
  int _currentImageIndex = 0;
  int _quantity = 1;
  String? _selectedSize;
  String? _selectedColor;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double? _parsePrice(dynamic price) {
    if (price == null) return null;
    if (price is num) return price.toDouble();
    if (price is String) {
      try {
        return double.parse(price);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  void _addToCart() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to add to cart')),
      );
      return;
    }

    if (_selectedSize == null || _selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select size and color')),
      );
      return;
    }

    final price = _parsePrice(widget.product['price']) ?? 0.0;

    try {
      await _supabase.from('cart').upsert({
        'user_id': userId,
        'product_id': widget.product['id'] ?? '',
        'name': widget.product['name'] ?? 'Unknown Product',
        'price': price,
        'image1': widget.product['image1'] ?? '',
        'quantity': _quantity,
        'size': _selectedSize,
        'color': _selectedColor,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added $_quantity ${widget.product['name'] ?? 'item'} to cart',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: TColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to cart: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _incrementQuantity() => setState(() => _quantity++);

  void _decrementQuantity() {
    if (_quantity > 1) setState(() => _quantity--);
  }

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
    final double imageHeight = isDesktop
        ? 450
        : isTablet
        ? 350
        : 280;
    final double titleFontSize = isDesktop
        ? 26
        : isTablet
        ? 22
        : 18;
    final double productNameFontSize = isDesktop
        ? 22
        : isTablet
        ? 18
        : 16;
    final double priceFontSize = isDesktop
        ? 20
        : isTablet
        ? 18
        : 16;
    final double descriptionFontSize = isDesktop
        ? 15
        : isTablet
        ? 13
        : 12;
    final double buttonFontSize = isDesktop
        ? 14
        : isTablet
        ? 13
        : 12;
    final double containerPadding = isDesktop
        ? 20
        : isTablet
        ? 16
        : 12;
    final double buttonHeight = isDesktop
        ? 40
        : isTablet
        ? 44
        : 40;

    List images = [
      widget.product['image1'] ?? '',
      widget.product['image2'] ?? '',
      widget.product['image3'] ?? '',
    ].where((image) => image.isNotEmpty).toList();

    // Sample sizes and colors (modify based on your product data structure)
    List<String> sizes =
        widget.product['sizes']?.cast<String>() ?? ['S', 'M', 'L', 'XL'];
    List<String> colors =
        widget.product['colors']?.cast<String>() ??
        ['Red', 'Blue', 'Black', 'White'];

    return Scaffold(
      backgroundColor: dark ? TColors.dark : TColors.light,
      appBar: AppBar(
        titleSpacing: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Iconsax.arrow_left_2,
            color: dark ? TColors.white : TColors.black,
            size: isDesktop ? 22 : 18,
          ),
          style: IconButton.styleFrom(
            backgroundColor: dark
                ? TColors.darkContainer
                : TColors.lightContainer,
            padding: EdgeInsets.all(isDesktop ? 10 : 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        title: Text(
          "Product Details",
          style: GoogleFonts.poppins(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
            color: dark ? TColors.white : TColors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: dark ? TColors.dark : TColors.light,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenPadding),
          child: isMobile
              ? _buildMobileLayout(
                  context,
                  dark,
                  images,
                  imageHeight,
                  screenPadding,
                  containerPadding,
                  productNameFontSize,
                  priceFontSize,
                  descriptionFontSize,
                  buttonHeight,
                  buttonFontSize,
                  sizes,
                  colors,
                )
              : _buildTabletDesktopLayout(
                  context,
                  dark,
                  images,
                  imageHeight,
                  screenPadding,
                  containerPadding,
                  productNameFontSize,
                  priceFontSize,
                  descriptionFontSize,
                  buttonHeight,
                  buttonFontSize,
                  isDesktop,
                  sizes,
                  colors,
                ),
        ),
      ),
      bottomNavigationBar: !isMobile
          ? Container(
              padding: EdgeInsets.all(screenPadding * 0.75),
              decoration: BoxDecoration(
                color: dark ? TColors.darkContainer : TColors.lightContainer,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildQuantitySelector(
                    dark,
                    height: buttonHeight,
                    iconSize: isDesktop ? 18 : 16,
                    textWidth: isDesktop ? 36 : 32,
                    fontSize: isDesktop ? 14 : 13,
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 180,
                    child: _buildPrimaryButton(
                      text: "Add to Cart",
                      onPressed: _addToCart,
                      height: buttonHeight,
                      fontSize: buttonFontSize,
                      dark: dark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 180,
                    child: _buildSecondaryButton(
                      text: "Buy Now",
                      onPressed: () {},
                      height: buttonHeight,
                      fontSize: buttonFontSize,
                      dark: dark,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    bool dark,
    List images,
    double imageHeight,
    double screenPadding,
    double containerPadding,
    double productNameFontSize,
    double priceFontSize,
    double descriptionFontSize,
    double buttonHeight,
    double buttonFontSize,
    List<String> sizes,
    List<String> colors,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenPadding),
          _buildImageCarousel(context, dark, images, imageHeight),
          SizedBox(height: screenPadding * 1.2),
          _buildProductDetails(
            dark,
            containerPadding,
            productNameFontSize,
            priceFontSize,
            descriptionFontSize,
            sizes,
            colors,
          ),
          SizedBox(height: screenPadding * 1.2),
          _buildDescriptionSection(
            dark,
            productNameFontSize,
            descriptionFontSize,
            screenPadding,
          ),
          SizedBox(height: screenPadding),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenPadding),
            child: Row(
              children: [
                _buildQuantitySelector(
                  dark,
                  height: buttonHeight,
                  iconSize: 16,
                  textWidth: 32,
                  fontSize: 13,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    width: 150,
                    child: _buildPrimaryButton(
                      text: "Add to Cart",
                      onPressed: _addToCart,
                      height: buttonHeight,
                      fontSize: buttonFontSize,
                      dark: dark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenPadding * 0.5),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenPadding),
            child: SizedBox(
              width: 150,
              child: _buildSecondaryButton(
                text: "Buy Now",
                onPressed: () {},
                height: buttonHeight,
                fontSize: buttonFontSize,
                dark: dark,
              ),
            ),
          ),
          SizedBox(height: screenPadding * 1.5),
        ],
      ),
    );
  }

  Widget _buildTabletDesktopLayout(
    BuildContext context,
    bool dark,
    List images,
    double imageHeight,
    double screenPadding,
    double containerPadding,
    double productNameFontSize,
    double priceFontSize,
    double descriptionFontSize,
    double buttonHeight,
    double buttonFontSize,
    bool isDesktop,
    List<String> sizes,
    List<String> colors,
  ) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: isDesktop ? 5 : 4,
            child: Column(
              children: [
                SizedBox(height: screenPadding),
                _buildImageCarousel(context, dark, images, imageHeight),
              ],
            ),
          ),
          SizedBox(width: screenPadding * 1.2),
          Expanded(
            flex: isDesktop ? 4 : 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenPadding),
                _buildProductDetails(
                  dark,
                  containerPadding,
                  productNameFontSize,
                  priceFontSize,
                  descriptionFontSize,
                  sizes,
                  colors,
                ),
                SizedBox(height: screenPadding * 1.2),
                _buildDescriptionSection(
                  dark,
                  productNameFontSize,
                  descriptionFontSize,
                  screenPadding,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(
    BuildContext context,
    bool dark,
    List images,
    double imageHeight,
  ) {
    return Container(
      height: imageHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.isEmpty ? 1 : images.length,
            onPageChanged: (index) =>
                setState(() => _currentImageIndex = index),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: dark ? Colors.grey.shade900 : Colors.grey.shade100,
                  child: images.isEmpty
                      ? Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 100,
                            color: TColors.grey,
                          ),
                        )
                      : GestureDetector(
                          onTap: () {},
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Image.network(
                              images[index],
                              fit: BoxFit.contain,
                              width: double.infinity,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: TColors.primary,
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 100,
                                      color: TColors.grey,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                ),
              );
            },
          ),
          if (images.length > 1)
            Positioned(
              bottom: 12,
              child: SmoothPageIndicator(
                controller: _pageController,
                count: images.length,
                effect: WormEffect(
                  dotHeight: 6,
                  dotWidth: 6,
                  activeDotColor: TColors.primary,
                  dotColor: dark ? Colors.grey.shade600 : Colors.grey.shade300,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductDetails(
    bool dark,
    double containerPadding,
    double productNameFontSize,
    double priceFontSize,
    double descriptionFontSize,
    List<String> sizes,
    List<String> colors,
  ) {
    final price = _parsePrice(widget.product['price']);
    final rating = widget.product['rating']?.toDouble() ?? 0.0;

    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: dark ? TColors.darkContainer : TColors.lightContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.product['name'] ?? 'Unknown Product',
                  style: GoogleFonts.poppins(
                    fontSize: productNameFontSize,
                    fontWeight: FontWeight.w700,
                    color: dark ? TColors.white : TColors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.favorite_border,
                  size: productNameFontSize,
                  color: dark ? TColors.white : TColors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: containerPadding * 0.5),
          Text(
            '₦${price != null ? price.toStringAsFixed(2) : 'N/A'}',
            style: GoogleFonts.poppins(
              fontSize: priceFontSize,
              fontWeight: FontWeight.w700,
              color: TColors.primary,
            ),
          ),
          SizedBox(height: containerPadding * 0.8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: dark ? Colors.grey.shade800 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: descriptionFontSize,
                      color: TColors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.product['stock'] ?? 'N/A'} in stock',
                      style: GoogleFonts.poppins(
                        fontSize: descriptionFontSize - 2,
                        color: TColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: dark ? Colors.grey.shade800 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: descriptionFontSize,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      rating.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: descriptionFontSize - 2,
                        color: TColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: containerPadding * 0.8),
          // Size selection
          Text(
            'Size',
            style: GoogleFonts.poppins(
              fontSize: descriptionFontSize,
              fontWeight: FontWeight.w600,
              color: dark ? TColors.white : TColors.black,
            ),
          ),
          SizedBox(height: containerPadding * 0.4),
          Wrap(
            spacing: 8,
            children: sizes.map((size) {
              return ChoiceChip(
                label: Text(
                  size,
                  style: GoogleFonts.poppins(
                    fontSize: descriptionFontSize - 2,
                    color: _selectedSize == size
                        ? TColors.white
                        : dark
                        ? TColors.white
                        : TColors.black,
                  ),
                ),
                selected: _selectedSize == size,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedSize = size;
                    });
                  }
                },
                selectedColor: TColors.primary,
                backgroundColor: dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: containerPadding * 0.8),
          // Color selection
          Text(
            'Color',
            style: GoogleFonts.poppins(
              fontSize: descriptionFontSize,
              fontWeight: FontWeight.w600,
              color: dark ? TColors.white : TColors.black,
            ),
          ),
          SizedBox(height: containerPadding * 0.4),
          Wrap(
            spacing: 8,
            children: colors.map((color) {
              return ChoiceChip(
                label: Text(
                  color,
                  style: GoogleFonts.poppins(
                    fontSize: descriptionFontSize - 2,
                    color: _selectedColor == color
                        ? TColors.white
                        : dark
                        ? TColors.white
                        : TColors.black,
                  ),
                ),
                selected: _selectedColor == color,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedColor = color;
                    });
                  }
                },
                selectedColor: TColors.primary,
                backgroundColor: dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: containerPadding * 0.8),
          Divider(
            color: dark ? Colors.grey.shade800 : Colors.grey.shade200,
            height: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(
    bool dark,
    double productNameFontSize,
    double descriptionFontSize,
    double screenPadding,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.poppins(
            fontSize: productNameFontSize - 2,
            fontWeight: FontWeight.w600,
            color: dark ? TColors.white : TColors.black,
          ),
        ),
        SizedBox(height: screenPadding * 0.6),
        Container(
          padding: EdgeInsets.all(screenPadding * 0.75),
          decoration: BoxDecoration(
            color: dark ? TColors.darkContainer : TColors.lightContainer,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            widget.product['description'] ?? 'No description available.',
            style: GoogleFonts.poppins(
              fontSize: descriptionFontSize,
              color: dark
                  ? TColors.white.withOpacity(0.9)
                  : TColors.textsecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector(
    bool dark, {
    required double height,
    required double iconSize,
    required double textWidth,
    required double fontSize,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: dark ? TColors.darkContainer : TColors.lightContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: dark ? Colors.grey.shade800 : Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: _decrementQuantity,
            icon: Icon(
              Icons.remove,
              size: iconSize,
              color: dark ? TColors.white : TColors.black,
            ),
          ),
          Container(
            width: textWidth,
            alignment: Alignment.center,
            child: Text(
              '$_quantity',
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: dark ? TColors.white : TColors.black,
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: _incrementQuantity,
            icon: Icon(
              Icons.add,
              size: iconSize,
              color: dark ? TColors.white : TColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    required double height,
    required double fontSize,
    required bool dark,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: TColors.primary,
        foregroundColor: TColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,

        shadowColor: Colors.black.withOpacity(0.2),
        minimumSize: Size(double.infinity, height),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: TColors.white,
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String text,
    required VoidCallback onPressed,
    required double height,
    required double fontSize,
    required bool dark,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: dark ? TColors.darkContainer : TColors.lightContainer,
        foregroundColor: TColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: TColors.primary, width: 1.5),
        ),
        elevation: 0,

        shadowColor: Colors.black.withOpacity(0.2),
        minimumSize: Size(double.infinity, height),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: TColors.primary,
        ),
      ),
    );
  }
}
