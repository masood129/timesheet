class Project {
  final String code;
  final String name;

  Project({required this.code, required this.name});

  @override
  String toString() => '$code - $name';
}
