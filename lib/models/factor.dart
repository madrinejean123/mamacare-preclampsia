class Factor {
  final String label;
  final String value;
  final double contribution; // -1.0..1.0, negative = protective
  final bool isRisk;

  const Factor({
    required this.label,
    required this.value,
    required this.contribution,
    required this.isRisk,
  });
}
