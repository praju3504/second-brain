enum LinkType {
  reference,
  embed,
  parent,
  blocks,
  relatesTo;
  
  String toJson() => name;
  
  static LinkType fromJson(String value) {
    return LinkType.values.firstWhere((e) => e.name == value);
  }
}
