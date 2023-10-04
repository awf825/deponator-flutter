class Resource {
  final String name;
  final String description;
  final String uid;
  final String? rid;

  Resource({
    required this.name,
    required this.description,
    required this.uid,
    this.rid
  });
}