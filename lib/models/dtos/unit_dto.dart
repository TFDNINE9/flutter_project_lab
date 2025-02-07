import 'dart:convert';

class UnitDto {
  final String unitName;

  UnitDto({
    required this.unitName,
  });

  factory UnitDto.fromMap(Map<String, dynamic> json) => UnitDto(
        unitName: json["unit_name"],
      );

  Map<String, dynamic> toMap() => {
        "unit_name": unitName,
      };

  String toJson() => jsonEncode(toMap());
}
