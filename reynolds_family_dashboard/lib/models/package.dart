class Package {
  final String id;
  final String description;
  final String carrier;
  final DateTime estimatedDelivery;
  final double progress; // 0.0 to 1.0

  Package({
    required this.id,
    required this.description,
    required this.carrier,
    required this.estimatedDelivery,
    required this.progress,
  });
}
