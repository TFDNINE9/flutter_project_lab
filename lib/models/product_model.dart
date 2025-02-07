import 'dart:convert';
import 'package:flutter_project_lab/models/category_model.dart';
import 'package:flutter_project_lab/models/unit_model.dart';

List<Product> productFromJson(String str) =>
    List<Product>.from(json.decode(str).map((x) => Product.fromJson(x)));

String productToJson(List<Product> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Product {
  final String id;
  final int productId;
  final String productName;
  final int quantity;
  final int price;
  final int salePrice;
  final int categoryId;
  final int unitId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;
  final Category category;
  final Unit unit;

  Product({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.salePrice,
    required this.categoryId,
    required this.unitId,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.category,
    required this.unit,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["_id"],
        productId: json["product_id"],
        productName: json["product_name"],
        quantity: json["quantity"],
        price: json["price"],
        salePrice: json["sale_price"],
        categoryId: json["category_id"],
        unitId: json["unit_id"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        category: Category.fromJson(json["category"]),
        unit: Unit.fromJson(json["unit"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "product_id": productId,
        "product_name": productName,
        "quantity": quantity,
        "price": price,
        "sale_price": salePrice,
        "category_id": categoryId,
        "unit_id": unitId,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
        "category": category.toJson(),
        "unit": unit.toJson(),
      };
}
