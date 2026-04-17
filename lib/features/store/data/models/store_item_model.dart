/// نموذج عنصر في المتجر (Store Item)
class StoreItemModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String? imageUrl;
  final String category; // e.g., 'books', 'quizzes', 'notes'
  final bool isActive;
  final String createdDate;
  final String updatedDate;

  const StoreItemModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.price,
    this.imageUrl,
    this.category = 'notes',
    this.isActive = true,
    required this.createdDate,
    required this.updatedDate,
  });

  factory StoreItemModel.fromMap(Map<String, dynamic> map) {
    return StoreItemModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['image_url'] as String?,
      category: map['category'] as String? ?? 'notes',
      isActive: map['is_active'] as bool? ?? true,
      createdDate: map['created_date'] as String? ?? '',
      updatedDate: map['updated_date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'is_active': isActive,
      'created_date': createdDate,
      'updated_date': updatedDate,
    };
  }

  StoreItemModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    bool? isActive,
    String? createdDate,
    String? updatedDate,
  }) {
    return StoreItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }
}
