import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spinza/data/models/product_model.dart';
import 'package:spinza/presentation/bloc/product/product_bloc.dart';
import 'package:spinza/presentation/bloc/product/product_event.dart';

class AdminProductFormScreen extends StatefulWidget {
  final Product? product; // Null if adding, has a value if editing

  const AdminProductFormScreen({super.key, this.product});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- IMPORTANT: This is the list of your bundled images ---
  // You must manually add the paths to any images in your assets folder here.
  final List<String> _availableImages = [
    'assets/images/500ml_bottle.png',
    'assets/images/500ml_carton.png',
    'assets/images/1.5_bottle.jpg',
    'assets/images/1.5_carton.jpg'
    // Add more paths here as you add more images to your project
  ];

  late String _name;
  late String _description;
  late double _price;
  late String _selectedImageAssetPath;
  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _name = widget.product!.name;
      _description = widget.product!.description;
      _price = widget.product!.price;
      _selectedImageAssetPath = widget.product!.imageUrl;
    } else {
      _name = '';
      _description = '';
      _price = 0.0;
      _selectedImageAssetPath = _availableImages.isNotEmpty ? _availableImages[0] : '';
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_isEditing) {
        context.read<ProductBloc>().add(UpdateProduct(
            productId: widget.product!.id,
            name: _name,
            description: _description,
            price: _price,
            imageAssetPath: _selectedImageAssetPath
        ));
      } else {
        context.read<ProductBloc>().add(AddProduct(
            name: _name,
            description: _description,
            price: _price,
            imageAssetPath: _selectedImageAssetPath
        ));
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _submitForm),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a name' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a description' : null,
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _price.toString(),
                decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => (value == null || double.tryParse(value) == null) ? 'Please enter a valid price' : null,
                onSaved: (value) => _price = double.parse(value!),
              ),
              const SizedBox(height: 24),
              Text('Select Product Image', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              // --- THIS IS THE IMAGE SELECTOR WIDGET ---
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableImages.length,
                  itemBuilder: (context, index) {
                    final imagePath = _availableImages[index];
                    final isSelected = imagePath == _selectedImageAssetPath;
                    return GestureDetector(
                      onTap: () {
                        setState(() { _selectedImageAssetPath = imagePath; });
                      },

                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade400,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(imagePath, fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}