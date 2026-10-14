class BookingModel {
  final String id;
  final String serviceId;
  final String serviceTitle;
  final String serviceCategory;
  final double totalAmount;
  final String customerName;
  final String customerPhone;
  final String dhuleArea;
  final String fullAddress;
  final DateTime bookingDate;
  final String timeSlot;
  final String specialInstructions;
  final String paymentMethod;
  final String paymentStatus;
  final String bookingStatus; // 'Confirmed', 'In Progress', 'Completed', 'Cancelled'
  final String assignedStaff;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.serviceId,
    required this.serviceTitle,
    required this.serviceCategory,
    required this.totalAmount,
    required this.customerName,
    required this.customerPhone,
    required this.dhuleArea,
    required this.fullAddress,
    required this.bookingDate,
    required this.timeSlot,
    this.specialInstructions = '',
    this.paymentMethod = 'Cash on Delivery (Pay after service)',
    this.paymentStatus = 'Pending (Pay upon completion)',
    this.bookingStatus = 'Confirmed',
    this.assignedStaff = 'Mopster Dhule Specialist Team',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isUpcoming =>
      bookingStatus == 'Confirmed' || bookingStatus == 'Pending';

  bool get canCancel =>
      bookingStatus == 'Confirmed' || bookingStatus == 'Pending';

  String get formattedAmount => '₹${totalAmount.toStringAsFixed(0)}';

  BookingModel copyWith({
    String? bookingStatus,
    String? paymentStatus,
    String? assignedStaff,
  }) {
    return BookingModel(
      id: id,
      serviceId: serviceId,
      serviceTitle: serviceTitle,
      serviceCategory: serviceCategory,
      totalAmount: totalAmount,
      customerName: customerName,
      customerPhone: customerPhone,
      dhuleArea: dhuleArea,
      fullAddress: fullAddress,
      bookingDate: bookingDate,
      timeSlot: timeSlot,
      specialInstructions: specialInstructions,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      assignedStaff: assignedStaff ?? this.assignedStaff,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'serviceTitle': serviceTitle,
      'serviceCategory': serviceCategory,
      'totalAmount': totalAmount,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'dhuleArea': dhuleArea,
      'fullAddress': fullAddress,
      'bookingDate': bookingDate.toIso8601String(),
      'timeSlot': timeSlot,
      'specialInstructions': specialInstructions,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'bookingStatus': bookingStatus,
      'assignedStaff': assignedStaff,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      serviceId: json['serviceId'] as String,
      serviceTitle: json['serviceTitle'] as String,
      serviceCategory: json['serviceCategory'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      dhuleArea: json['dhuleArea'] as String? ?? 'Dhule Central',
      fullAddress: json['fullAddress'] as String,
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      timeSlot: json['timeSlot'] as String,
      specialInstructions: json['specialInstructions'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? 'Cash on Delivery',
      paymentStatus: json['paymentStatus'] as String? ?? 'Pending',
      bookingStatus: json['bookingStatus'] as String? ?? 'Confirmed',
      assignedStaff: json['assignedStaff'] as String? ?? 'Dhule Local Specialist',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
