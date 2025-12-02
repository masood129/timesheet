class TimeRecord {
  final String cardNo;
  final String date;
  final String time;

  TimeRecord({required this.cardNo, required this.date, required this.time});

  factory TimeRecord.fromJson(Map<String, dynamic> json) {
    return TimeRecord(
      cardNo: json['cardNo'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
    );
  }
}
