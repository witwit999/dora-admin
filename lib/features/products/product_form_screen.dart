import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dora_admin/l10n/app_localizations.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/product_model.dart';
import '../../shared/providers/products_provider.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../../shared/widgets/image_picker_widget.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final int? productId;

  const ProductFormScreen({super.key, this.productId});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  bool _isLoadingProduct = false;
  Product? _existingProduct;
  String? _imageValidationError;
  bool _isFeatured = false;
  bool get isEditMode => widget.productId != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoadingProduct = true;
    });

    // First try to get from state
    _existingProduct = ref
        .read(productsProvider.notifier)
        .getProductById(widget.productId!);

    // If not in state, fetch from API
    if (_existingProduct == null) {
      _existingProduct = await ref
          .read(productsProvider.notifier)
          .fetchProductById(widget.productId!);
    }

    if (_existingProduct != null) {
      _nameController.text = _existingProduct!.name;
      _descriptionController.text = _existingProduct!.description;
      if (_existingProduct!.price != null) {
        _priceController.text = _existingProduct!.price.toString();
      }
      _isFeatured = _existingProduct!.isFeatured;
    }

    setState(() {
      _isLoadingProduct = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    final l10n = AppLocalizations.of(context)!;
    final formValid = _formKey.currentState!.validate();

    // For new products, image is required
    if (!isEditMode && _selectedImage == null) {
      setState(() {
        _imageValidationError = l10n.productFormImageError;
      });
      return false;
    }

    setState(() {
      _imageValidationError = null;
    });

    return formValid;
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
    });

    bool success;
    String? errorMessage;

    try {
      if (isEditMode) {
        // Update existing product
        success = await ref
            .read(productsProvider.notifier)
            .updateProduct(
              id: widget.productId!,
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              price: _priceController.text.trim().isEmpty
                  ? null
                  : double.tryParse(_priceController.text.trim()),
              newImage: _selectedImage,
              isFeatured: _isFeatured,
            );
      } else {
        // Create new product
        success = await ref
            .read(productsProvider.notifier)
            .createProduct(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              price: _priceController.text.trim().isEmpty
                  ? null
                  : double.tryParse(_priceController.text.trim()),
              image: _selectedImage!,
              isFeatured: _isFeatured,
            );
      }

      // Get error from state if operation failed
      if (!success) {
        errorMessage = ref.read(productsProvider).error;
      }
    } catch (e) {
      success = false;
      errorMessage = e.toString();
    }

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode
                ? l10n.productFormUpdateSuccess
                : l10n.productFormCreateSuccess,
          ),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? l10n.errorUnexpected),
          backgroundColor: AppTheme.errorColor,
          action: SnackBarAction(
            label: l10n.commonRetry,
            textColor: Colors.white,
            onPressed: _handleSubmit,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Show loading while fetching product in edit mode
    if (_isLoadingProduct) {
      return MainScaffold(
        title: l10n.productFormEditTitle,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Show error if product not found in edit mode
    if (isEditMode && _existingProduct == null && !_isLoadingProduct) {
      return MainScaffold(
        title: l10n.productFormEditTitle,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                l10n.productFormNotFound,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.productFormNotFoundMessage,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text(l10n.commonGoBack),
              ),
            ],
          ),
        ),
      );
    }

    return MainScaffold(
      title: isEditMode ? l10n.productFormEditTitle : l10n.productFormNewTitle,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image picker
              ImagePickerWidget(
                label: isEditMode
                    ? l10n.productFormImageLabel
                    : l10n.productFormImageRequired,
                initialImagePath: null,
                initialImageUrl: _existingProduct?.imageUrl,
                onImagePicked: (file) {
                  setState(() {
                    _selectedImage = file;
                    _imageValidationError = null;
                  });
                },
              ),

              // Image validation error
              if (_imageValidationError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    _imageValidationError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.productFormNameLabel,
                  hintText: l10n.productFormNameHint,
                  prefixIcon: const Icon(Icons.label_outline),
                ),
                textInputAction: TextInputAction.next,
                maxLength: AppConstants.maxProductNameLength,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.productFormNameError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.productFormDescriptionLabel,
                  hintText: l10n.productFormDescriptionHint,
                  prefixIcon: const Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                maxLength: AppConstants.maxDescriptionLength,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.productFormDescriptionError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price field
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: l10n.productFormPriceLabel,
                  hintText: l10n.productFormPriceHint,
                  //prefixIcon: const Icon(Icons.attach_money),
                  prefixText: '\IQD ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final price = double.tryParse(value.trim());
                    if (price == null || price < 0) {
                      return l10n.productFormPriceError;
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Featured field
              CheckboxListTile(
                title: Text(l10n.productFormFeaturedLabel),
                value: _isFeatured,
                onChanged: (value) {
                  setState(() {
                    _isFeatured = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 32),

              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        isEditMode
                            ? l10n.productFormUpdateButton
                            : l10n.productFormCreateButton,
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
