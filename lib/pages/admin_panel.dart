import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:file_picker/file_picker.dart';
import '../../utils/constants/colors.dart';
import '../../utils/showSnackBar.dart';
import '../responsive.dart';
import 'dart:io';
import 'dart:math';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel>
    with SingleTickerProviderStateMixin {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> _products = [];
  List<dynamic> _filteredProducts = [];
  List<dynamic> _orders = [];
  String _currentCategory = 'All Products';
  bool _isLoadingProducts = true;
  bool _isLoadingOrders = true;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _image1Controller = TextEditingController();
  final TextEditingController _image2Controller = TextEditingController();
  final TextEditingController _image3Controller = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  late TabController _tabController;
  PlatformFile? _image1File;
  PlatformFile? _image2File;
  PlatformFile? _image3File;

  // Define allowed extensions and MIME types
  static const Map<String, String> _allowedExtensions = {
    'image/png': 'png',
    'image/jpeg': 'jpeg',
    'image/jpg': 'jpg',
  };

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All Products', 'icon': Iconsax.shop},
    {'name': 'Orders', 'icon': Iconsax.box},
    {'name': 'Add New Product', 'icon': Iconsax.additem},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchProducts(_currentCategory);
    _fetchOrders();

    _searchController.addListener(() {
      _filterProducts(_searchController.text);
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          if (_tabController.index == 0) {
            _currentCategory = 'All Products';
            _fetchProducts(_currentCategory);
          } else {
            _currentCategory = 'Orders';
            _fetchOrders();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _image1Controller.dispose();
    _image2Controller.dispose();
    _image3Controller.dispose();
    _stockController.dispose();
    _sizeController.dispose();
    _colorController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hintText, IconData icon) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hintText,
      hintStyle: Theme.of(context).textTheme.bodySmall,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      prefixIcon: Icon(icon, color: TColors.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: dark ? TColors.dark : TColors.light,
    );
  }

  Future<void> _fetchProducts(String category) async {
    setState(() {
      _isLoadingProducts = true;
    });

    try {
      final query = supabase
          .from('products')
          .select(
            'id, name, description, price, category, image1, image2, image3, stock, rating, size, color',
          );
      final response = await query;

      setState(() {
        _products = List<Map<String, dynamic>>.from(response);
        _filteredProducts = _products;
        _shuffleProducts();
        _isLoadingProducts = false;
      });
    } catch (error) {
      debugPrint('Error fetching products: $error');
      setState(() {
        _isLoadingProducts = false;
      });
      if (mounted) {
        showCustomSnackbar(context, 'Error fetching products: $error');
      }
    }
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoadingOrders = true;
    });
    try {
      final response = await supabase
          .from('order_headers')
          .select('*, order_items(product_id, quantity, price, name, image)')
          .order('created_at', ascending: false);
      setState(() {
        _orders = List<Map<String, dynamic>>.from(response);
        _isLoadingOrders = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingOrders = false;
      });
      if (mounted) {
        showCustomSnackbar(context, 'Error fetching orders: $e');
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

  Future<String?> _uploadImage(
    PlatformFile? imageFile,
    String productName,
    int imageNumber,
  ) async {
    if (imageFile == null || productName.isEmpty) return null;

    try {
      // Validate file extension
      final extension = imageFile.extension?.toLowerCase();
      if (extension == null || !_allowedExtensions.values.contains(extension)) {
        throw Exception(
          'Invalid file format. Only PNG, JPEG, and JPG are allowed.',
        );
      }

      // Validate file size (5MB limit)
      if (imageFile.size > 5 * 1024 * 1024) {
        throw Exception('Image size must be less than 5MB');
      }

      final fileBytes = kIsWeb
          ? imageFile.bytes
          : await File(imageFile.path!).readAsBytes();
      if (fileBytes == null) {
        throw Exception('Failed to read image data');
      }

      // Generate unique filename
      final cleanProductName = productName
          .replaceAll(' ', '-')
          .replaceAll(RegExp(r'[^a-zA-Z0-9-]'), '')
          .toLowerCase();
      final fileName =
          '$cleanProductName-image$imageNumber-${DateTime.now().millisecondsSinceEpoch}.$extension';
      final filePath = 'products/$fileName';

      // Determine content type based on extension
      final contentType = _allowedExtensions.entries
          .firstWhere(
            (entry) => entry.value == extension,
            orElse: () => MapEntry('image/jpeg', 'jpeg'),
          )
          .key;

      // Upload to Supabase storage
      await supabase.storage
          .from('product-images')
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );

      // Get the public URL
      final response = supabase.storage
          .from('product-images')
          .getPublicUrl(filePath);

      return response;
    } catch (e) {
      debugPrint('Error uploading image $imageNumber: $e');
      if (mounted) {
        showCustomSnackbar(context, 'Error uploading image: ${e.toString()}');
      }
      return null;
    }
  }

  Future<void> _addProduct() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _stockController.text.isEmpty) {
      showCustomSnackbar(context, 'Please fill in all required fields');
      return;
    }

    try {
      // Validate numeric inputs
      final price = double.tryParse(_priceController.text);
      final stock = int.tryParse(_stockController.text);
      if (price == null || stock == null) {
        throw Exception('Invalid price or stock value');
      }

      // Upload images concurrently
      final imageUploads = await Future.wait([
        _uploadImage(_image1File, _nameController.text, 1),
        _uploadImage(_image2File, _nameController.text, 2),
        _uploadImage(_image3File, _nameController.text, 3),
      ]);

      // Insert product into database
      await supabase.from('products').insert({
        'name': _nameController.text,
        'price': price,
        'description': _descriptionController.text,
        'image1': imageUploads[0] ?? _image1Controller.text,
        'image2': imageUploads[1] ?? _image2Controller.text,
        'image3': imageUploads[2] ?? _image3Controller.text,
        'stock': stock,
        'size': _sizeController.text,
        'color': _colorController.text,
        'category': 'Others',
      });

      // Clear form
      setState(() {
        _image1File = null;
        _image2File = null;
        _image3File = null;
      });

      _nameController.clear();
      _priceController.clear();
      _descriptionController.clear();
      _image1Controller.clear();
      _image2Controller.clear();
      _image3Controller.clear();
      _stockController.clear();
      _sizeController.clear();
      _colorController.clear();

      await _fetchProducts(_currentCategory);
      if (mounted) {
        showCustomSnackbar(context, 'Product added successfully');
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(context, 'Error adding product: $e');
      }
    }
  }

  Future<void> _updateProduct(String id) async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _stockController.text.isEmpty) {
      showCustomSnackbar(context, 'Please fill in all required fields');
      return;
    }

    try {
      // Validate numeric inputs
      final price = double.tryParse(_priceController.text);
      final stock = int.tryParse(_stockController.text);
      if (price == null || stock == null) {
        throw Exception('Invalid price or stock value');
      }

      // Upload new images if provided
      final imageUploads = await Future.wait([
        _uploadImage(_image1File, _nameController.text, 1),
        _uploadImage(_image2File, _nameController.text, 2),
        _uploadImage(_image3File, _nameController.text, 3),
      ]);

      // Prepare update data
      final updateData = {
        'name': _nameController.text,
        'price': price,
        'description': _descriptionController.text,
        'stock': stock,
        'size': _sizeController.text,
        'color': _colorController.text,
        'category': 'Others',
      };

      // Only include image URLs if they exist
      if (imageUploads[0] != null) updateData['image1'] = imageUploads[0]!;
      if (imageUploads[1] != null) updateData['image2'] = imageUploads[1]!;
      if (imageUploads[2] != null) updateData['image3'] = imageUploads[2]!;

      // Update product in database
      await supabase.from('products').update(updateData).eq('id', id);

      // Clear form
      setState(() {
        _image1File = null;
        _image2File = null;
        _image3File = null;
      });

      _nameController.clear();
      _priceController.clear();
      _descriptionController.clear();
      _image1Controller.clear();
      _image2Controller.clear();
      _image3Controller.clear();
      _stockController.clear();
      _sizeController.clear();
      _colorController.clear();

      await _fetchProducts(_currentCategory);
      if (mounted) {
        showCustomSnackbar(context, 'Product updated successfully');
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(context, 'Error updating product: $e');
      }
    }
  }

  Future<void> _deleteProduct(String id) async {
    try {
      // Fetch product to get image URLs
      final product = await supabase
          .from('products')
          .select('image1, image2, image3')
          .eq('id', id)
          .single();

      // Delete images from storage
      final imagePaths =
          [
            product['image1'],
            product['image2'],
            product['image3'],
          ].where((url) => url != null && url.isNotEmpty).map((url) {
            final uri = Uri.parse(url!);
            return uri.pathSegments.last;
          }).toList();

      for (final path in imagePaths) {
        try {
          await supabase.storage.from('product-images').remove([
            'products/$path',
          ]);
        } catch (e) {
          debugPrint('Error deleting image $path: $e');
        }
      }

      // Delete product from database
      await supabase.from('products').delete().eq('id', id);
      await _fetchProducts(_currentCategory);
      if (mounted) {
        showCustomSnackbar(context, 'Product deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(context, 'Error deleting product: $e');
      }
    }
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await supabase
          .from('order_headers')
          .update({'status': status})
          .eq('id', orderId);
      await _fetchOrders();
      if (mounted) {
        showCustomSnackbar(context, 'Order status updated successfully');
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(context, 'Error updating order status: $e');
      }
    }
  }

  Future<void> _deleteOrder(String orderId) async {
    try {
      await supabase.from('order_items').delete().eq('order_id', orderId);
      await supabase.from('order_headers').delete().eq('id', orderId);
      await _fetchOrders();
      if (mounted) {
        showCustomSnackbar(context, 'Order deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(context, 'Error deleting order: $e');
      }
    }
  }

  Future<void> _pickImage(int imageNumber) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        // Validate file size (5MB limit)
        if (file.size > 5 * 1024 * 1024) {
          if (mounted) {
            showCustomSnackbar(context, 'Image size must be less than 5MB');
          }
          return;
        }

        // Validate file extension
        String? extension = file.extension?.toLowerCase();
        if (extension == null || !['jpg', 'jpeg', 'png'].contains(extension)) {
          if (mounted) {
            showCustomSnackbar(
              context,
              'Only JPG, JPEG, and PNG images are allowed',
            );
          }
          return;
        }

        setState(() {
          switch (imageNumber) {
            case 1:
              _image1File = file;
              _image1Controller.text = file.name;
              break;
            case 2:
              _image2File = file;
              _image2Controller.text = file.name;
              break;
            case 3:
              _image3File = file;
              _image3Controller.text = file.name;
              break;
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        showCustomSnackbar(context, 'Error picking image: ${e.toString()}');
      }
    }
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? TColors.darkContainer
              : TColors.lightContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Add New Product',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? TColors.white
                  : TColors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: _inputDecoration('Product Name *', Iconsax.text),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _priceController,
                  decoration: _inputDecoration('Price *', Iconsax.money),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  decoration: _inputDecoration('Description', Iconsax.note),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _image1Controller,
                  readOnly: true,
                  decoration: _inputDecoration('Image 1', Iconsax.image)
                      .copyWith(
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Iconsax.image,
                            color: TColors.primary,
                          ),
                          onPressed: () => _pickImage(1),
                        ),
                      ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _image2Controller,
                  readOnly: true,
                  decoration: _inputDecoration('Image 2', Iconsax.image)
                      .copyWith(
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Iconsax.image,
                            color: TColors.primary,
                          ),
                          onPressed: () => _pickImage(2),
                        ),
                      ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _image3Controller,
                  readOnly: true,
                  decoration: _inputDecoration('Image 3', Iconsax.image)
                      .copyWith(
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Iconsax.image,
                            color: TColors.primary,
                          ),
                          onPressed: () => _pickImage(3),
                        ),
                      ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _stockController,
                  decoration: _inputDecoration('Stock *', Iconsax.box),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _sizeController,
                  decoration: _inputDecoration('Size', Iconsax.ruler),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _colorController,
                  decoration: _inputDecoration('Color', Iconsax.color_swatch),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? TColors.white
                      : TColors.black,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _addProduct();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Add',
                style: GoogleFonts.poppins(color: TColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProductDialog(Map<String, dynamic> product) {
    // Pre-fill controllers with existing product data
    _nameController.text = product['name'] ?? '';
    _priceController.text = product['price']?.toString() ?? '';
    _descriptionController.text = product['description'] ?? '';
    _image1Controller.text = product['image1']?.split('/').last ?? '';
    _image2Controller.text = product['image2']?.split('/').last ?? '';
    _image3Controller.text = product['image3']?.split('/').last ?? '';
    _stockController.text = product['stock']?.toString() ?? '';
    _sizeController.text = product['size'] ?? '';
    _colorController.text = product['color'] ?? '';

    showDialog(
      context: context,
      builder: (context) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? TColors.darkContainer
              : TColors.lightContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Edit Product',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? TColors.white
                  : TColors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: _inputDecoration('Product Name *', Iconsax.text),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _priceController,
                  decoration: _inputDecoration('Price *', Iconsax.money),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  decoration: _inputDecoration('Description', Iconsax.note),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _image1Controller,
                  readOnly: true,
                  decoration: _inputDecoration('Image 1', Iconsax.image)
                      .copyWith(
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Iconsax.image,
                            color: TColors.primary,
                          ),
                          onPressed: () => _pickImage(1),
                        ),
                      ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _image2Controller,
                  readOnly: true,
                  decoration: _inputDecoration('Image 2', Iconsax.image)
                      .copyWith(
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Iconsax.image,
                            color: TColors.primary,
                          ),
                          onPressed: () => _pickImage(2),
                        ),
                      ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _image3Controller,
                  readOnly: true,
                  decoration: _inputDecoration('Image 3', Iconsax.image)
                      .copyWith(
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Iconsax.image,
                            color: TColors.primary,
                          ),
                          onPressed: () => _pickImage(3),
                        ),
                      ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _stockController,
                  decoration: _inputDecoration('Stock *', Iconsax.box),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _sizeController,
                  decoration: _inputDecoration('Size', Iconsax.ruler),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _colorController,
                  decoration: _inputDecoration('Color', Iconsax.color_swatch),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? TColors.white
                      : TColors.black,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateProduct(product['id'].toString());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Update',
                style: GoogleFonts.poppins(color: TColors.white),
              ),
            ),
          ],
        ),
      ),
    );
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
        return Shimmer.fromColors(
          baseColor: Theme.of(context).brightness == Brightness.dark
              ? TColors.darkGrey
              : TColors.softgrey,
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
                      borderRadius: BorderRadius.vertical(
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
                      Container(width: 140, height: 18, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 100, height: 16, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 120, height: 16, color: Colors.white),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 40,
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

  Widget _buildProductCard(Map<String, dynamic> product) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final images = [
      product['image1'],
      product['image2'],
      product['image3'],
    ].where((url) => url != null && url.isNotEmpty).cast<String>().toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: dark ? TColors.darkContainer : TColors.lightContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                images.isEmpty
                    ? Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Iconsax.image,
                            size: 60,
                            color: TColors.grey,
                          ),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: PageView.builder(
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
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
                                    child: const Center(
                                      child: Icon(
                                        Iconsax.image,
                                        size: 60,
                                        color: TColors.grey,
                                      ),
                                    ),
                                  ),
                            );
                          },
                        ),
                      ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Iconsax.edit, color: TColors.primary),
                        onPressed: () => _showEditProductDialog(product),
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.trash, color: Colors.red),
                        onPressed: () =>
                            _deleteProduct(product['id'].toString()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                      '₦${product['price']?.toString() ?? 'N/A'}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: TColors.primary,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < (product['rating']?.toInt() ?? 0)
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 18,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Stock: ${product['stock']?.toString() ?? 'N/A'} | Size: ${product['size']?.toString() ?? 'N/A'}',
                  style: GoogleFonts.poppins(fontSize: 14, color: TColors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: dark ? TColors.darkContainer : TColors.lightContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order['id']}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: dark ? TColors.white : TColors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Iconsax.trash, color: Colors.red),
                  onPressed: () => _deleteOrder(order['id'].toString()),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'User ID: ${order['user_id']}',
              style: GoogleFonts.poppins(fontSize: 14, color: TColors.grey),
            ),
            Text(
              'Total: ₦${order['total_amount']?.toStringAsFixed(2) ?? '0.00'}',
              style: GoogleFonts.poppins(fontSize: 14, color: TColors.grey),
            ),
            Text(
              'Payment: ${order['payment_method']} (${order['payment_status']})',
              style: GoogleFonts.poppins(fontSize: 14, color: TColors.grey),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: order['status'] ?? 'Processing',
              items: <String>['Processing', 'Shipped', 'Delivered', 'Cancelled']
                  .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    );
                  })
                  .toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _updateOrderStatus(order['id'].toString(), newValue);
                }
              },
              style: GoogleFonts.poppins(
                color: dark ? TColors.white : TColors.black,
              ),
              dropdownColor: dark
                  ? TColors.darkContainer
                  : TColors.lightContainer,
            ),
            const SizedBox(height: 12),
            Text(
              'Items:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: dark ? TColors.white : TColors.black,
              ),
            ),
            ...List.generate(order['order_items'].length, (index) {
              final item = order['order_items'][index];
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    item['image'] != null && item['image'].isNotEmpty
                        ? Image.network(
                            item['image'],
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
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
                                const Icon(
                                  Iconsax.image,
                                  size: 40,
                                  color: TColors.grey,
                                ),
                          )
                        : const Icon(
                            Iconsax.image,
                            size: 40,
                            color: TColors.grey,
                          ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] ?? 'Unknown Product',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: dark ? TColors.white : TColors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Qty: ${item['quantity']} @ ₦${item['price']}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: TColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySidebar() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: dark ? TColors.darkContainer : TColors.lightContainer,
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _currentCategory == category['name'];
          return ListTile(
            leading: Icon(
              category['icon'] as IconData,
              color: isSelected
                  ? TColors.primary
                  : dark
                  ? TColors.white.withOpacity(0.6)
                  : TColors.black.withOpacity(0.6),
            ),
            title: Text(
              category['name'] as String,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? TColors.primary
                    : dark
                    ? TColors.white
                    : TColors.black,
              ),
            ),
            onTap: () {
              setState(() {
                _currentCategory = category['name'] as String;
                if (_currentCategory == 'Add New Product') {
                  _showAddProductDialog();
                } else {
                  _tabController.index = _currentCategory == 'All Products'
                      ? 0
                      : 1;
                  if (_currentCategory == 'All Products') {
                    _fetchProducts(_currentCategory);
                  } else {
                    _fetchOrders();
                  }
                }
              });
            },
            tileColor: isSelected
                ? TColors.primary.withOpacity(0.1)
                : Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryTabBar() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: dark ? TColors.darkContainer : TColors.lightContainer,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: TabBar(
          controller: _tabController,
          isScrollable: false,
          unselectedLabelColor: dark
              ? TColors.white.withOpacity(0.6)
              : TColors.black.withOpacity(0.6),
          labelColor: TColors.white,
          labelStyle: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: TColors.primary,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.symmetric(
            horizontal: 5.0,
            vertical: 5.0,
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 5.0),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Products'),
            Tab(text: 'Orders'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? TColors.dark : TColors.light,
      body: Row(
        children: [
          if (ResponsiveLayout.isDesktop(context)) _buildCategorySidebar(),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Admin Panel',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: dark ? TColors.white : TColors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_tabController.index == 0)
                        SizedBox(
                          width: 400,
                          child: TextField(
                            controller: _searchController,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: dark ? TColors.white : TColors.black,
                            ),
                            decoration: _inputDecoration(
                              'Search products...',
                              Iconsax.search_normal_1,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (ResponsiveLayout.isMobile(context) ||
                    ResponsiveLayout.isTablet(context))
                  _buildCategoryTabBar(),
                Expanded(
                  child: RefreshIndicator(
                    color: TColors.primary,
                    backgroundColor: dark ? TColors.dark : TColors.light,
                    onRefresh: () => _tabController.index == 0
                        ? _fetchProducts(_currentCategory)
                        : _fetchOrders(),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _isLoadingProducts
                            ? _buildShimmerEffect()
                            : _filteredProducts.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Iconsax.box,
                                      size: 60,
                                      color: dark
                                          ? TColors.white.withOpacity(0.6)
                                          : TColors.textsecondary,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No products found',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: dark
                                            ? TColors.white
                                            : TColors.textsecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.all(24),
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 300,
                                      crossAxisSpacing: 24,
                                      mainAxisSpacing: 24,
                                      childAspectRatio: 0.75,
                                    ),
                                itemCount: _filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = _filteredProducts[index];
                                  return _buildProductCard(product);
                                },
                              ),
                        _isLoadingOrders
                            ? _buildShimmerEffect()
                            : _orders.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Iconsax.box,
                                      size: 60,
                                      color: dark
                                          ? TColors.white.withOpacity(0.6)
                                          : TColors.textsecondary,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No orders found',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: dark
                                            ? TColors.white
                                            : TColors.textsecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(24),
                                itemCount: _orders.length,
                                itemBuilder: (context, index) {
                                  final order = _orders[index];
                                  return _buildOrderCard(order);
                                },
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
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _showAddProductDialog,
              backgroundColor: TColors.primary,
              child: const Icon(Iconsax.add, color: TColors.white),
            )
          : null,
    );
  }
}
