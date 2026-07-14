class Event {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String memberName;
  final int colorValue;

  Event({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.memberName,
    required this.colorValue,
  });
}
