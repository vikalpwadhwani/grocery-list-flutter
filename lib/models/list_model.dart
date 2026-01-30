import 'item_model.dart';
import 'user_model.dart';

class GroceryListModel {
  final String id;
  final String name;
  final String inviteCode;
  final String createdBy;
  final String? role;
  final UserModel? creator;
  final List<ItemModel>? items;
  final List<ListMemberModel>? members;
  final int? itemCount;
  final int? checkedCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GroceryListModel({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdBy,
    this.role,
    this.creator,
    this.items,
    this.members,
    this.itemCount,
    this.checkedCount,
    this.createdAt,
    this.updatedAt,
  });

  factory GroceryListModel.fromJson(Map<String, dynamic> json) {
    return GroceryListModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      inviteCode: json['inviteCode'] ?? json['invite_code'] ?? '',
      createdBy: json['createdBy'] ?? json['created_by'] ?? '',
      role: json['role'],
      creator: json['creator'] != null
          ? UserModel.fromJson(json['creator'])
          : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => ItemModel.fromJson(item))
              .toList()
          : null,
      members: json['listMembers'] != null
          ? (json['listMembers'] as List)
              .map((m) => ListMemberModel.fromJson(m))
              .toList()
          : null,
      itemCount: json['itemCount'],
      checkedCount: json['checkedCount'],
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
      'inviteCode': inviteCode,
      'createdBy': createdBy,
    };
  }

  GroceryListModel copyWith({
    String? id,
    String? name,
    String? inviteCode,
    String? createdBy,
    String? role,
    UserModel? creator,
    List<ItemModel>? items,
    List<ListMemberModel>? members,
    int? itemCount,
    int? checkedCount,
  }) {
    return GroceryListModel(
      id: id ?? this.id,
      name: name ?? this.name,
      inviteCode: inviteCode ?? this.inviteCode,
      createdBy: createdBy ?? this.createdBy,
      role: role ?? this.role,
      creator: creator ?? this.creator,
      items: items ?? this.items,
      members: members ?? this.members,
      itemCount: itemCount ?? this.itemCount,
      checkedCount: checkedCount ?? this.checkedCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  double get progress {
    if (itemCount == null || itemCount == 0) return 0;
    return (checkedCount ?? 0) / itemCount!;
  }
}

class ListMemberModel {
  final String id;
  final String userId;
  final String listId;
  final String role;
  final UserModel? user;

  ListMemberModel({
    required this.id,
    required this.userId,
    required this.listId,
    required this.role,
    this.user,
  });

  factory ListMemberModel.fromJson(Map<String, dynamic> json) {
    return ListMemberModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      listId: json['listId'] ?? json['list_id'] ?? '',
      role: json['role'] ?? 'member',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}