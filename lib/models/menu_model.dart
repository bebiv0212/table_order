class MenuModel {
  final String id;
  final String name;
  final int price;
  final String category;
  final String description;
  final String imageUrl;
  final bool isAvailable;

  MenuModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.isAvailable,
  });

  factory MenuModel.fromMap(Map<String, dynamic> map, String id) {
    return MenuModel(
      id: id,
      name: map['name'],
      price: map['price'],
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
    };
  }

  MenuModel copyWith({
    String? id,
    String? name,
    int? price,
    String? category,
    String? description,
    String? imageUrl,
    bool? isAvailable,
  }) {
    return MenuModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
