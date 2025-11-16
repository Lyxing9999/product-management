class Product {
  final int id;
  final String name;
  final double price;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['PRODUCTID'] ?? 0,
        name: json['PRODUCTNAME'] ?? '',
        price: (json['PRICE'] ?? 0).toDouble(),
        stock: json['STOCK'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'PRODUCTID': id,
        'PRODUCTNAME': name,
        'PRICE': price,
        'STOCK': stock,
      };
}