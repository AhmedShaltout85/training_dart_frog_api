import 'package:equatable/equatable.dart';

///Item model
class Item extends Equatable{
  ///Item constructor
  Item({
    required this.id,
    required this.name,
    required this.description,
  });

  ///List's from json
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  ///Item fields
  /// List's id
  final String id;

  /// List's name
  final String name;

  /// List's description
  final String description;

  ///List's to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  ///List's copy with
  Item copyWith({
    String? id,
    String? name,
    String? description,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
  
  @override
  List<Object?> get props => [id, name, description];
}
