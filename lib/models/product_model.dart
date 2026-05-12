class Store {
  final int id;
  final String name;
  final String username;

  Store({
    required this.id,
    required this.name,
    required this.username,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
    );
  }
}

class ProductClass {
  final int id;
  final String name;

  ProductClass({
    required this.id,
    required this.name,
  });

  factory ProductClass.fromJson(Map<String, dynamic> json) {
    return ProductClass(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class Product {
  final int id;
  final String name;
  final int price;
  final String description;
  final String? createdAt;
  final String? updatedAt;
  final Store? store;
  final ProductClass? productClass;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    this.createdAt,
    this.updatedAt,
    this.store,
    this.productClass,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _parseInt(json['id']),
      name: json['name'] ?? 'No Name',
      price: _parseInt(json['price']),
      description: json['description'] ?? '',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      store: json['store'] != null ? Store.fromJson(json['store']) : null,
      productClass:
          json['class'] != null ? ProductClass.fromJson(json['class']) : null,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return double.tryParse(value)?.toInt() ?? 0;
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
    };
  }
}