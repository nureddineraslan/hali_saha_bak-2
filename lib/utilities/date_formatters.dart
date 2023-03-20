extension MyExtension on DateTime {
  String toDateString() {
    try {
      return '${day.toString().padLeft(2, '0')} / ${month.toString().padLeft(2, '0')} / ${year.toString().padLeft(2, '0')}';
    } catch (e) {
      return '$e';
    }
  }

  String toDateStringWithTime() {
    try {
      return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/${year.toString().padLeft(2, '0')} ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '$e';
    }
  }

  bool isToday() {
    final now = DateTime.now();
    return now.day == this.day && now.month == this.month && now.year == this.year;
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return yesterday.day == this.day && yesterday.month == this.month && yesterday.year == this.year;
  }

  String toHour() {
    String formattedText = '${this.hour.toString().padLeft(2, '0')}:${this.minute.toString().padLeft(2, '0')}';
    return formattedText;
  }

  DateTime daysDate() {
    return DateTime(this.year, this.month, this.day);
  }
}
