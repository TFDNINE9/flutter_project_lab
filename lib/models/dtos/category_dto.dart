import 'dart:convert';

class CategoryDto {
  String categoryName;

  CategoryDto({
    this.categoryName = '',
  });

  factory CategoryDto.fromMap(Map<String, dynamic> json) => CategoryDto(
        categoryName: json["category_name"],
      );

  Map<String, dynamic> toMap() => {
        "category_name": categoryName,
      };

  String toJson() => jsonEncode(toMap());
}
