enum EntityType {
  note,
  task,
  file,
  folder;
  
  String toJson() => name;
  
  static EntityType fromJson(String value) {
    return EntityType.values.firstWhere((e) => e.name == value);
  }
}
