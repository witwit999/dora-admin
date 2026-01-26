class Product {
  final int id;
  final String name;
  final String description;
  final String? imagePath; // File path for local images
  final String? imageUrl; // URL for remote images
  final double? price;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFeatured;
  Product({
    required this.id,
    required this.name,
    required this.description,
    this.imagePath,
    this.imageUrl,
    this.price,
    required this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
  });

  // Get image source (prioritize URL for API images, fallback to local path)
  String? get imageSource => imageUrl ?? imagePath;

  // Copy with method for updates
  Product copyWith({
    int? id,
    String? name,
    String? description,
    String? imagePath,
    String? imageUrl,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFeatured,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }

  // Convert to JSON for API (update endpoint)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'isFeatured': isFeatured,
    };
  }

  // Create from JSON (API response)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isFeatured: json['isFeatured'] as bool,
    );
  }
}
