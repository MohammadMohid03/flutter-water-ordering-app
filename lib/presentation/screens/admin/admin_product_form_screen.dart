import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spinza/data/models/product_model.dart';
import 'package:spinza/presentation/bloc/product/product_bloc.dart';
import 'package:spinza/presentation/bloc/product/product_event.dart';
import 'package:spinza/presentation/widgets/smart_image.dart';
import 'dart:math' as math;

class AdminProductFormScreen extends StatefulWidget {
  final Product? product;
  const AdminProductFormScreen({super.key, this.product});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen>
    with TickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImageFile;
  String? _existingImageUrl;

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  bool get _isEditing => widget.product != null;

  // Animation controllers
  late AnimationController _waveController;
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _waveAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _isEditing ? widget.product!.name : '');
    _descriptionController = TextEditingController(text: _isEditing ? widget.product!.description : '');
    _priceController = TextEditingController(text: _isEditing ? widget.product!.price.toString() : '');
    if (_isEditing) {
      _existingImageUrl = widget.product!.imageUrl;
    }

    // Initialize animations
    _waveController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(begin: 0, end: 2 * math.pi)
        .animate(_waveController);

    _fadeAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    _floatAnimation = Tween<double>(begin: -8, end: 8)
        .animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi)
        .animate(_rotateController);

    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _waveController.dispose();
    _fadeController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
      });
    }
  }

  // --- THIS IS THE CORRECTED SUBMIT LOGIC ---
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // For ADDING a product, a new image is mandatory.
      if (!_isEditing && _selectedImageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select an image for the new product.'),
            backgroundColor: Colors.red.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
        return;
      }

      final name = _nameController.text;
      final description = _descriptionController.text;
      final price = double.parse(_priceController.text);

      if (_isEditing) {
        context.read<ProductBloc>().add(UpdateProduct(
          productId: widget.product!.id,
          name: name,
          description: description,
          price: price,
          imageFile: _selectedImageFile, // Pass the new file (can be null if not changed)
          existingImageUrl: _existingImageUrl, // Pass the old URL/path
        ));
      } else {
        context.read<ProductBloc>().add(AddProduct(
          name: name,
          description: description,
          price: price,
          imageFile: _selectedImageFile!, // Pass the new file (guaranteed non-null)
        ));
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3C72),
              Color(0xFF2A5298),
              Color(0xFF4FC3F7),
              Color(0xFF29B6F6),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated wave background
            AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavePainter(_waveAnimation.value),
                  size: Size.infinite,
                );
              },
            ),

            // Enhanced floating bubbles with different sizes and movements
            ...List.generate(8, (index) =>
                AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return Positioned(
                      left: 20 + (index * 45) +
                          math.sin(_waveAnimation.value + index) * 25,
                      top: 100 + (index * 80) +
                          math.cos(_waveAnimation.value + index * 0.7) * 30,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: index % 3 == 0 ? _pulseAnimation.value * 0.4 : 1.0,
                            child: Container(
                              width: 12 + (index * 2),
                              height: 12 + (index * 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.05 + (index * 0.008)),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
            ),

            // Rotating geometric shapes in background
            ...List.generate(3, (index) =>
                AnimatedBuilder(
                  animation: _rotateAnimation,
                  builder: (context, child) {
                    return Positioned(
                      left: 80 + (index * 120),
                      top: 200 + (index * 200),
                      child: Transform.rotate(
                        angle: _rotateAnimation.value + (index * math.pi / 3),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: index % 2 == 0 ? BoxShape.rectangle : BoxShape.circle,
                            color: Colors.white.withOpacity(0.02),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.06),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ),

            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: CustomScrollView(
                  slivers: [
                    // Glass-morphism AppBar as Sliver
                    SliverToBoxAdapter(
                      child: AnimatedBuilder(
                        animation: _floatAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatAnimation.value),
                            child: Container(
                              margin: EdgeInsets.all(16),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Back button
                                  AnimatedBuilder(
                                    animation: _pulseAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _pulseAnimation.value * 0.1 + 0.9,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.15),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: IconButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            icon: Icon(
                                              Iconsax.arrow_left,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(width: 12),
                                  // Title section
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _isEditing ? 'Edit Product' : 'Add Product',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        Text(
                                          _isEditing ? 'Update product details' : 'Create a new product',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 12,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Save button
                                  AnimatedBuilder(
                                    animation: _pulseAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _pulseAnimation.value * 0.1 + 0.9,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.15),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: IconButton(
                                            onPressed: _submitForm,
                                            icon: Icon(
                                              Iconsax.tick_circle,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Form container as Sliver
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: _buildFormContent(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image picker section
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: _buildImagePicker(),
                );
              },
            ),
            SizedBox(height: 32),

            // Product name field
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 1000),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(50 * (1 - value), 0),
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: _buildGlassTextField(
                      controller: _nameController,
                      label: 'Product Name',
                      icon: Iconsax.box,
                      validator: (value) => (value == null || value.isEmpty) ? 'Please enter a name' : null,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),

            // Description field
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 1200),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(50 * (1 - value), 0),
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: _buildGlassTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      icon: Iconsax.document_text,
                      maxLines: 3,
                      validator: (value) => (value == null || value.isEmpty) ? 'Please enter a description' : null,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),

            // Price field
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 1400),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(50 * (1 - value), 0),
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: _buildGlassTextField(
                      controller: _priceController,
                      label: 'Price (PKR)',
                      icon: Iconsax.money_3,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => (value == null || double.tryParse(value) == null) ? 'Please enter a valid price' : null,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white.withOpacity(0.9),
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          errorStyle: TextStyle(
            color: Colors.red.shade300,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    Widget imageWidget;
    if (_selectedImageFile != null) {
      imageWidget = Image.file(_selectedImageFile!, fit: BoxFit.cover);
    } else if (_existingImageUrl != null) {
      imageWidget = SmartImage(imageUrl: _existingImageUrl!, fit: BoxFit.cover);
    } else {
      imageWidget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.gallery_add, size: 40, color: Colors.white.withOpacity(0.6)),
          SizedBox(height: 8),
          Text(
            'Tap to select image',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    return Center(
      child: AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value * 0.5),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: imageWidget,
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value * 0.1 + 0.9,
                      child: Container(
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF1E3C72),
                              Color(0xFF2A5298),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _pickImage,
                          icon: Icon(
                            Iconsax.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Wave painter class (same as dashboard)
class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    final path = Path();

    for (int i = 0; i < 3; i++) {
      path.reset();

      final waveHeight = 40.0 + (i * 15);
      final frequency = 0.015 + (i * 0.008);
      final phase = animationValue + (i * math.pi / 4);

      path.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x += 5) {
        final y = size.height - 150 - (i * 80) +
            math.sin((x * frequency) + phase) * waveHeight;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}