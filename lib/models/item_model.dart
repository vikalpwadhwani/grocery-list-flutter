import 'user_model.dart';

class ItemModel {
  final String id;
  final String name;
  final int quantity;
  final String? unit;
  final bool isChecked;
  final String listId;
  final String addedBy;
  final String? checkedBy;
  final UserModel? addedByUser;
  final UserModel? checkedByUser;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    this.unit,
    required this.isChecked,
    required this.listId,
    required this.addedBy,
    this.checkedBy,
    this.addedByUser,
    this.checkedByUser,
    this.createdAt,
    this.updatedAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 1,
      unit: json['unit'],
      isChecked: json['isChecked'] ?? json['is_checked'] ?? false,
      listId: json['listId'] ?? json['list_id'] ?? '',
      addedBy: json['addedBy'] ?? json['added_by'] ?? '',
      checkedBy: json['checkedBy'] ?? json['checked_by'],
      addedByUser: json['addedByUser'] != null
          ? UserModel.fromJson(json['addedByUser'])
          : null,
      checkedByUser: json['checkedByUser'] != null
          ? UserModel.fromJson(json['checkedByUser'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'isChecked': isChecked,
      'listId': listId,
      'addedBy': addedBy,
    };
  }

  ItemModel copyWith({
    String? id,
    String? name,
    int? quantity,
    String? unit,
    bool? isChecked,
    String? listId,
    String? addedBy,
    String? checkedBy,
    UserModel? addedByUser,
    UserModel? checkedByUser,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isChecked: isChecked ?? this.isChecked,
      listId: listId ?? this.listId,
      addedBy: addedBy ?? this.addedBy,
      checkedBy: checkedBy ?? this.checkedBy,
      addedByUser: addedByUser ?? this.addedByUser,
      checkedByUser: checkedByUser ?? this.checkedByUser,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  String get quantityDisplay {
    if (unit != null && unit!.isNotEmpty) {
      return '$quantity $unit';
    }
    return quantity.toString();
  }
}