class Interest {
  final String id;
  final String name;
  final String icon;
  bool selected;

  Interest({
    required this.id,
    required this.name,
    required this.icon,
    required this.selected,
  });

  Interest copyWith({bool? selected}) {
    return Interest(
      id: id,
      name: name,
      icon: icon,
      selected: selected ?? this.selected,
    );
  }
}
