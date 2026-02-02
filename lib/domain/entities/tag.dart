import 'package:equatable/equatable.dart';

class Tag extends Equatable {
  final String id;
  final String name;
  final String color;
  
  const Tag({
    required this.id,
    required this.name,
    required this.color,
  });
  
  Tag copyWith({
    String? id,
    String? name,
    String? color,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }
  
  @override
  List<Object?> get props => [id, name, color];
}
