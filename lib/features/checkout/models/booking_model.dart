class Booking {
  final int id;
  final int classId;
  final String className;
  final String fullName;
  final String email;
  final String phoneNumber;
  final int participants;
  final double totalPrice;
  final String paymentStatus;
  final DateTime bookingDate;

  Booking({
    required this.id,
    required this.classId,
    required this.className,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.participants,
    required this.totalPrice,
    required this.paymentStatus,
    required this.bookingDate,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      classId: json["class_id"],
      className: json['class_name'],
      fullName: json['full_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      participants: json['participants'],
      totalPrice: (json['total_price'] as num).toDouble(),
      paymentStatus: json['payment_status'],
      bookingDate: DateTime.parse(json['booking_date']),
    );
  }
}
