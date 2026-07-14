class MailItem {
  final String id;
  final String sender;
  final DateTime receivedDate;
  final bool isRead;

  MailItem({
    required this.id,
    required this.sender,
    required this.receivedDate,
    this.isRead = false,
  });
}
