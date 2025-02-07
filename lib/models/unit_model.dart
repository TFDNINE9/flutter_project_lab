import 'dart:convert';

List<Unit> unitFromJson(String str) =>
    List<Unit>.from(json.decode(str).map((x) => Unit.fromJson(x)));

String unitToJson(List<Unit> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Unit {
  final String id;
  final int unitId;
  final String unitName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  Unit({
    required this.id,
    required this.unitId,
    required this.unitName,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Unit.fromJson(Map<String, dynamic> json) => Unit(
        id: json["_id"],
        unitId: json["unit_id"],
        unitName: json["unit_name"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "unit_id": unitId,
        "unit_name": unitName,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
      };
}
