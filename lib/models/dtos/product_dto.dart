import 'dart:convert';

class ProductDto {
  final String productName;
  final int quantity;
  final int price;
  final int salePrice;
  final int categoryId;
  final int unitId;

  ProductDto({
    required this.productName,
    required this.quantity,
    required this.price,
    required this.salePrice,
    required this.categoryId,
    required this.unitId,
  });

  factory ProductDto.fromMap(Map<String, dynamic> json) => ProductDto(
        productName: json["product_name"],
        quantity: json["quantity"],
        price: json["price"],
        salePrice: json["sale_price"],
        categoryId: json["category_id"],
        unitId: json["unit_id"],
      );

  Map<String, dynamic> toMap() => {
        "product_name": productName,
        "quantity": quantity,
        "price": price,
        "sale_price": salePrice,
        "category_id": categoryId,
        "unit_id": unitId,
      };
  String toJson() => jsonEncode(toMap());
}
