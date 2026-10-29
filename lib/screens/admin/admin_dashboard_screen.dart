import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/colors.dart';
import '../../data/booking_storage.dart';
import '../../models/booking_model.dart';
import '../../services/auth_service.dart';
import '../main_nav_screen.dart';

class AdminCustomerSummary {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String dhuleArea;
  final String homeAddress;
  final DateTime registrationDate;
  final List<BookingModel> bookings;

  AdminCustomerSummary({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.dhuleArea,
    required this.homeAddress,
    required this.registrationDate,
    required this.bookings,
  });

  int get bookingCount => bookings.length;
  double get totalSpend => bookings
      .where((b) => b.isCompleted)
      .fold(0.0, (sum, b) => sum + b.totalAmount);

  String get initials {
    if (name.trim().isEmpty) return 'C';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<BookingModel> _bookings = [];
  List<Map<String, dynamic>> _cloudServices = [];
  List<AdminCustomerSummary> _customerList = [];
  bool _isLoading = false;
  String _selectedStatusFilter = 'All';
  String _selectedCategoryFilter = 'All';
  DateTime? _selectedDateFilter;
  String _searchQuery = '';
  String _customerSearchQuery = '';

  final List<String> _dhuleWorkers = [
    'Unassigned / Pending Team Allocation',
    'Mopster Core Team (Dhule Operations)',
    'Owner Fulfilled (Self)',
  ];

  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (AuthService().isOwnerAuthenticated) {
      _loadData();
      _setupRealtimeSubscription();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (_realtimeChannel != null) {
      try {
        Supabase.instance.client.removeChannel(_realtimeChannel!);
      } catch (_) {}
    }
    super.dispose();
  }

  /// Subscribe to live Supabase Postgres changes on the bookings table
  void _setupRealtimeSubscription() {
    try {
      final supabase = Supabase.instance.client;
      _realtimeChannel = supabase.channel('admin_bookings_realtime_sync')
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'bookings',
          callback: (payload) {
            debugPrint('Realtime admin event detected: ${payload.eventType}');
            _loadData(silent: true);
          },
        )
        ..subscribe();
    } catch (e) {
      debugPrint('Realtime channel error in AdminDashboardScreen: $e');
    }
  }

  Future<void> _loadData({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final supabase = Supabase.instance.client;

      // 1. Fetch genuine bookings directly from Supabase (sorted newest first)
      final bookingsRes = await supabase
          .from('bookings')
          .select()
          .order('created_at', ascending: false);

      final List<dynamic> bookingsList = bookingsRes as List<dynamic>;
      _bookings = bookingsList
          .map((b) => BookingModel.fromSupabaseMap(b as Map<String, dynamic>))
          .where((b) => !BookingStorage.isDummyBooking(b))
          .toList();

      // 2. Fetch all services from Supabase
      try {
        final servicesRes = await supabase
            .from('services')
            .select()
            .order('category', ascending: true);
        _cloudServices = List<Map<String, dynamic>>.from(servicesRes);
      } catch (servicesErr) {
        debugPrint('Admin load services note: $servicesErr');
      }

      // 3. Correlate customers from Supabase profiles and genuine customer bookings
      List<Map<String, dynamic>> profilesRaw = [];
      try {
        final profilesRes = await supabase
            .from('profiles')
            .select()
            .order('created_at', ascending: false);
        profilesRaw =
            List<Map<String, dynamic>>.from(profilesRes as List<dynamic>);
      } catch (e) {
        debugPrint('Admin load profiles note: $e');
      }

      final Map<String, AdminCustomerSummary> customerMap = {};

      for (final p in profilesRaw) {
        final id = p['id']?.toString() ?? '';
        final phone = p['phone']?.toString() ?? '';
        final name = p['full_name']?.toString() ?? 'Customer';
        final email = p['email']?.toString();
        final dhuleArea = p['dhule_area']?.toString() ?? 'Deopur';
        final homeAddress = p['home_address']?.toString() ?? '';
        DateTime regDate;
        try {
          regDate = p['created_at'] != null
              ? DateTime.parse(p['created_at'].toString())
              : DateTime.now();
        } catch (_) {
          regDate = DateTime.now();
        }

        final cleanCustomerPhone =
            phone.replaceAll(' ', '').replaceAll('+91', '').trim();
        final custBookings = _bookings.where((b) {
          final matchesId = b.customerId != null && b.customerId == id;
          final bPhoneClean =
              b.customerPhone.replaceAll(' ', '').replaceAll('+91', '').trim();
          final matchesPhone = cleanCustomerPhone.isNotEmpty &&
              bPhoneClean == cleanCustomerPhone;
          return matchesId || matchesPhone;
        }).toList();

        final key = id.isNotEmpty ? id : phone;
        if (key.isNotEmpty) {
          customerMap[key] = AdminCustomerSummary(
            id: id,
            name: name,
            phone: phone,
            email: email,
            dhuleArea: dhuleArea,
            homeAddress: homeAddress,
            registrationDate: regDate,
            bookings: custBookings,
          );
        }
      }

      // Correlate genuine customers who booked from the app
      for (final b in _bookings) {
        final cleanBPhone =
            b.customerPhone.replaceAll(' ', '').replaceAll('+91', '').trim();
        final existingKey = customerMap.keys.firstWhere(
          (k) {
            final c = customerMap[k]!;
            final cClean =
                c.phone.replaceAll(' ', '').replaceAll('+91', '').trim();
            return (b.customerId != null && b.customerId == c.id) ||
                (cleanBPhone.isNotEmpty && cClean == cleanBPhone);
          },
          orElse: () => '',
        );

        if (existingKey.isEmpty && cleanBPhone.isNotEmpty) {
          final custBookings = _bookings.where((other) {
            final otherClean = other.customerPhone
                .replaceAll(' ', '')
                .replaceAll('+91', '')
                .trim();
            return otherClean == cleanBPhone;
          }).toList();

          customerMap['phone_$cleanBPhone'] = AdminCustomerSummary(
            id: b.customerId ?? 'guest_${b.id}',
            name: b.customerName,
            phone: b.customerPhone,
            email: null,
            dhuleArea: b.dhuleArea,
            homeAddress: b.fullAddress,
            registrationDate: b.createdAt,
            bookings: custBookings,
          );
        }
      }

      _customerList = customerMap.values.toList()
        ..sort((a, b) => b.registrationDate.compareTo(a.registrationDate));
    } catch (e) {
      debugPrint('Admin load error: $e');
      // If error occurs, do not fabricate demo bookings!
      _bookings = [];
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('bookings')
          .update({'booking_status': newStatus}).eq('id', bookingId);

      // Synchronize BookingStorage local store
      await BookingStorage().updateBookingStatus(bookingId, newStatus);

      // Update local state
      setState(() {
        final idx = _bookings.indexWhere((b) => b.id == bookingId);
        if (idx != -1) {
          _bookings[idx] = _bookings[idx].copyWith(bookingStatus: newStatus);
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryMintDark,
          content: Text('Booking $bookingId status updated to "$newStatus"'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.statusCancelled,
          content: Text('Failed to update status: $e'),
        ),
      );
    }
  }

  Future<void> _assignWorker(String bookingId, String workerName) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('bookings')
          .update({'assigned_staff': workerName}).eq('id', bookingId);

      // Update local state
      setState(() {
        final idx = _bookings.indexWhere((b) => b.id == bookingId);
        if (idx != -1) {
          _bookings[idx] = _bookings[idx].copyWith(assignedStaff: workerName);
        }
      });

      // Synchronize BookingStorage
      BookingStorage().refreshFromCloud();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryMintDark,
          content: Text('Assigned $workerName to booking $bookingId'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.statusCancelled,
          content: Text('Failed to assign worker: $e'),
        ),
      );
    }
  }

  Future<void> _updatePaymentStatus(
      String bookingId, String newPaymentStatus) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('bookings')
          .update({'payment_status': newPaymentStatus}).eq('id', bookingId);

      // Synchronize BookingStorage local store
      await BookingStorage().updatePaymentStatus(bookingId, newPaymentStatus);

      // Update local state
      setState(() {
        final idx = _bookings.indexWhere((b) => b.id == bookingId);
        if (idx != -1) {
          _bookings[idx] =
              _bookings[idx].copyWith(paymentStatus: newPaymentStatus);
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryMintDark,
          content: Text('Payment status updated to "$newPaymentStatus"'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.statusCancelled,
          content: Text('Failed to update payment status: $e'),
        ),
      );
    }
  }

  Future<void> _updateServicePrice(String serviceId, double newPrice) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('services')
          .update({'base_price': newPrice}).eq('id', serviceId);

      _loadData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryMintDark,
          content: Text('Price updated to ₹${newPrice.toStringAsFixed(0)}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.statusCancelled,
          content: Text('Failed to update service: $e'),
        ),
      );
    }
  }

  void _confirmApproveBooking(BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded,
                color: AppColors.statusConfirmed, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Approve Booking Request?',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Text(
          'Approve request ${booking.id} for ${booking.customerName}?\n\n'
          '• Service: ${booking.serviceTitle}\n'
          '• Preferred Date: ${DateFormat('dd MMM yyyy').format(booking.bookingDate)}\n'
          '• Preferred Time: ${booking.timeSlot}\n'
          '• Total Amount: ₹${booking.totalAmount.toStringAsFixed(0)}\n\n'
          'Status will be updated to "Confirmed" and visible to the customer.',
          style: const TextStyle(
              fontSize: 13, height: 1.4, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateBookingStatus(booking.id, 'Confirmed');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusConfirmed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Approve Booking',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _confirmRejectBooking(BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.cancel_rounded,
                color: AppColors.statusCancelled, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Reject Booking Request?',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Text(
          'Reject request ${booking.id} from ${booking.customerName}?\n\n'
          'The customer will see their booking status updated to "Rejected".',
          style: const TextStyle(
              fontSize: 13, height: 1.4, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateBookingStatus(booking.id, 'Rejected');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusCancelled,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Reject Booking',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showStatusDialog(BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) {
        final statuses = [
          'Pending Approval',
          'Confirmed',
          'In Progress',
          'Completed',
          'Rejected',
          'Cancelled',
        ];
        return SimpleDialog(
          title: Text(
            'Update Status for ${booking.id}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          children: statuses.map((status) {
            final isCurrent = booking.bookingStatus == status;
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(ctx);
                _updateBookingStatus(booking.id, status);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Icon(
                      isCurrent
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: isCurrent
                          ? AppColors.primaryMint
                          : AppColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: isCurrent
                            ? AppColors.primaryMintDark
                            : AppColors.charcoal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showAssignWorkerDialog(BookingModel booking) {
    final customWorkerCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Assign Specialist to ${booking.id}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service: ${booking.serviceTitle}\nLocality: ${booking.dhuleArea}, Dhule',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Choose from local Dhule staff:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 8),
                ..._dhuleWorkers.map((worker) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const Icon(Icons.person_rounded,
                        color: AppColors.primaryMint, size: 20),
                    title: Text(worker, style: const TextStyle(fontSize: 13)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _assignWorker(booking.id, worker);
                    },
                  );
                }),
                const SizedBox(height: 12),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 8),
                TextField(
                  controller: customWorkerCtrl,
                  decoration: InputDecoration(
                    hintText: 'Or enter worker name...',
                    hintStyle: const TextStyle(fontSize: 12),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check_rounded,
                          color: AppColors.primaryMint),
                      onPressed: () {
                        if (customWorkerCtrl.text.trim().isNotEmpty) {
                          Navigator.pop(ctx);
                          _assignWorker(
                              booking.id, customWorkerCtrl.text.trim());
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentDialog(BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) {
        final nowStr =
            DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
        return SimpleDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Record Payment for ${booking.id}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Text(
                'Total Amount: ₹${booking.totalAmount.toStringAsFixed(0)}\n'
                'Selected Method: ${booking.paymentMethod}\n'
                'Current Status: ${booking.paymentStatus}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
            const Divider(height: 16),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(ctx);
                _updatePaymentStatus(
                    booking.id, 'Paid via Direct UPI ($nowStr)');
              },
              child: Row(
                children: const [
                  Icon(Icons.qr_code_2_rounded,
                      color: AppColors.primaryMintDark, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Mark as Paid via Direct UPI',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(ctx);
                _updatePaymentStatus(booking.id, 'Paid via Cash ($nowStr)');
              },
              child: Row(
                children: const [
                  Icon(Icons.payments_rounded,
                      color: Color(0xFF0D9488), size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Mark as Paid via Cash',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(ctx);
                _updatePaymentStatus(
                    booking.id, 'Pending (Pay upon completion)');
              },
              child: Row(
                children: const [
                  Icon(Icons.hourglass_empty_rounded,
                      color: AppColors.textMuted, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Reset to Payment Pending',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditServiceDialog(Map<String, dynamic> service) {
    final priceCtrl =
        TextEditingController(text: '${service['base_price']}');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Edit ${service['title']}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category: ${service['category'].toString().toUpperCase()}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Base Price (₹)',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newPrice = double.tryParse(priceCtrl.text.trim());
                if (newPrice != null && newPrice > 0) {
                  Navigator.pop(ctx);
                  _updateServicePrice(service['id'] as String, newPrice);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryMint,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Price'),
            ),
          ],
        );
      },
    );
  }

  void _confirmExitConsole() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.exit_to_app_rounded,
                color: AppColors.primaryMintDark, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Exit Business Console?',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ],
        ),
        content: const Text(
          'Return to customer app view? You can switch back to the Business Owner Console anytime from the Profile screen.',
          style: TextStyle(
              fontSize: 13, height: 1.4, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Stay in Console'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainNavScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryMint,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Exit to App',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthService().isOwnerAuthenticated) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'Access Restricted',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.charcoal,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.charcoal),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock_rounded,
                      size: 48, color: Colors.red.shade600),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Owner Authorization Required',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.charcoal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'This portal is strictly restricted to verified Mopster business administrators.',
                  style:
                      TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryMint,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Return to Customer App'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final filteredBookings = _bookings.where((b) {
      bool matchesStatus;
      if (_selectedStatusFilter == 'All') {
        matchesStatus = true;
      } else if (_selectedStatusFilter == 'Pending Approval') {
        matchesStatus = b.isPendingApproval;
      } else if (_selectedStatusFilter == 'Confirmed') {
        matchesStatus = b.isConfirmed;
      } else if (_selectedStatusFilter == 'In Progress') {
        matchesStatus = b.isInProgress;
      } else if (_selectedStatusFilter == 'Completed') {
        matchesStatus = b.isCompleted;
      } else if (_selectedStatusFilter == 'Rejected') {
        matchesStatus = b.isRejected;
      } else if (_selectedStatusFilter == 'Cancelled') {
        matchesStatus = b.isCancelled;
      } else {
        matchesStatus = b.bookingStatus.toLowerCase() ==
            _selectedStatusFilter.toLowerCase();
      }

      bool matchesCategory = true;
      if (_selectedCategoryFilter != 'All') {
        matchesCategory = b.serviceCategory.trim().toLowerCase() ==
            _selectedCategoryFilter.trim().toLowerCase();
      }

      bool matchesDate = true;
      if (_selectedDateFilter != null) {
        matchesDate = b.bookingDate.year == _selectedDateFilter!.year &&
            b.bookingDate.month == _selectedDateFilter!.month &&
            b.bookingDate.day == _selectedDateFilter!.day;
      }

      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          b.id.toLowerCase().contains(q) ||
          b.customerName.toLowerCase().contains(q) ||
          b.customerPhone.toLowerCase().contains(q) ||
          b.dhuleArea.toLowerCase().contains(q) ||
          b.serviceTitle.toLowerCase().contains(q);
      return matchesStatus && matchesCategory && matchesDate && matchesSearch;
    }).toList();

    final totalBookings = _bookings.length;
    final pendingCount =
        _bookings.where((b) => b.isPendingApproval).length;
    final confirmedCount =
        _bookings.where((b) => b.isConfirmed).length;
    final inProgressCount =
        _bookings.where((b) => b.isInProgress).length;
    final completedCount =
        _bookings.where((b) => b.isCompleted).length;
    final totalRevenue = _bookings
        .where((b) => b.isCompleted)
        .fold(0.0, (sum, b) => sum + b.totalAmount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Mopster Business Console',
              style: TextStyle(
                color: AppColors.charcoal,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Dhule Operations & Dispatch • Supabase Cloud',
              style: TextStyle(
                color: AppColors.primaryMintDark,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.charcoal),
            tooltip: 'Refresh from Supabase',
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.charcoal),
            tooltip: 'Exit to Customer App',
            onPressed: _confirmExitConsole,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryMintDark,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryMint,
          indicatorWeight: 3,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            Tab(
              icon: const Icon(Icons.assignment_rounded, size: 18),
              text: 'Bookings ($totalBookings)',
            ),
            Tab(
              icon: const Icon(Icons.people_alt_rounded, size: 18),
              text: 'Customers (${_customerList.length})',
            ),
            Tab(
              icon: const Icon(Icons.cleaning_services_rounded, size: 18),
              text: 'Services (${_cloudServices.length})',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryMint),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  // TAB 1: Bookings & Dispatch Management
                  RefreshIndicator(
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // KPI Metric Cards
                          _buildKpiRow(
                            total: totalBookings,
                            pending: pendingCount,
                            confirmed: confirmedCount,
                            inProgress: inProgressCount,
                            completed: completedCount,
                            revenue: totalRevenue,
                          ),

                          const SizedBox(height: 20),

                          // Search & Status Filters
                          _buildFilterBar(),

                          const SizedBox(height: 16),

                          // Bookings List
                          if (_bookings.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 48),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: AppColors.borderLight),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 68,
                                    height: 68,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryMintLight
                                          .withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.inbox_outlined,
                                      size: 34,
                                      color: AppColors.primaryMintDark,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No bookings received yet.',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.charcoal,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Real customer bookings placed from the Mopster app will appear here in real-time.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  OutlinedButton.icon(
                                    onPressed: () => _loadData(),
                                    icon: const Icon(Icons.refresh_rounded,
                                        size: 18,
                                        color: AppColors.primaryMintDark),
                                    label: const Text(
                                      'Refresh from Cloud',
                                      style: TextStyle(
                                        color: AppColors.primaryMintDark,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: AppColors.primaryMint),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (filteredBookings.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(36),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: AppColors.borderLight),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.filter_alt_off_rounded,
                                      size: 40, color: AppColors.textMuted),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'No bookings matching your filter.',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.charcoal,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Try selecting a different status or clearing search.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedStatusFilter = 'All';
                                        _selectedDateFilter = null;
                                        _searchQuery = '';
                                      });
                                    },
                                    child: const Text('Reset All Filters'),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...filteredBookings.map((b) => _buildBookingRow(b)),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),

                  // TAB 2: Registered Customer Directory & History
                  _buildCustomerTab(),

                  // TAB 3: Services & Pricing Management
                  RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _cloudServices.length,
                      itemBuilder: (context, index) {
                        final s = _cloudServices[index];
                        final isCleaning = s['category'] == 'cleaning';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isCleaning
                                      ? AppColors.primaryMintLight
                                      : AppColors.accentSoftGreen,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isCleaning
                                      ? Icons.cleaning_services_rounded
                                      : Icons.eco_rounded,
                                  color: AppColors.primaryMintDark,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s['title'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.charcoal,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${s['category'].toString().toUpperCase()} • ${s['duration']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${s['base_price']}',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.charcoal,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _showEditServiceDialog(s),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColors.primaryMintLight,
                                      foregroundColor:
                                          AppColors.primaryMintDark,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      minimumSize: const Size(60, 28),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Edit Rate',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildKpiRow({
    required int total,
    required int pending,
    required int confirmed,
    required int inProgress,
    required int completed,
    required double revenue,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildKpiCard('Total Requests', '$total', Icons.assignment_rounded,
              AppColors.primaryMint),
          const SizedBox(width: 10),
          _buildKpiCard('Pending Approval', '$pending',
              Icons.hourglass_top_rounded, AppColors.statusPending),
          const SizedBox(width: 10),
          _buildKpiCard('Confirmed', '$confirmed', Icons.check_circle_rounded,
              AppColors.statusConfirmed),
          const SizedBox(width: 10),
          _buildKpiCard('In Progress', '$inProgress',
              Icons.engineering_rounded, const Color(0xFF7C3AED)),
          const SizedBox(width: 10),
          _buildKpiCard('Completed', '$completed', Icons.task_alt_rounded,
              AppColors.statusCompleted),
          const SizedBox(width: 10),
          _buildKpiCard('Settled Revenue', '₹${revenue.toStringAsFixed(0)}',
              Icons.currency_rupee_rounded, const Color(0xFF0D9488)),
        ],
      ),
    );
  }

  Widget _buildKpiCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      width: 135,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final statuses = [
      'All',
      'Pending Approval',
      'Confirmed',
      'In Progress',
      'Completed',
      'Rejected',
      'Cancelled',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: TextField(
            onChanged: (val) {
              setState(() {
                _searchQuery = val.trim();
              });
            },
            decoration: const InputDecoration(
              hintText: 'Search by Customer, Phone, Locality or ID...',
              hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
              prefixIcon: Icon(Icons.search_rounded,
                  size: 20, color: AppColors.primaryMint),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Date Filter Row
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDateFilter ?? DateTime.now(),
                  firstDate: DateTime(2025),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDateFilter = picked;
                  });
                }
              },
              icon: const Icon(Icons.calendar_month_rounded, size: 14),
              label: Text(
                _selectedDateFilter == null
                    ? 'Filter by Date'
                    : 'Date: ${DateFormat('dd MMM yyyy').format(_selectedDateFilter!)}',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _selectedDateFilter != null
                    ? AppColors.primaryMintDark
                    : AppColors.charcoal,
                backgroundColor: _selectedDateFilter != null
                    ? AppColors.primaryMintLight
                    : Colors.white,
                side: BorderSide(
                  color: _selectedDateFilter != null
                      ? AppColors.primaryMint
                      : AppColors.borderLight,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            if (_selectedDateFilter != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.cancel_rounded,
                    size: 18, color: AppColors.textMuted),
                tooltip: 'Clear Date Filter',
                onPressed: () {
                  setState(() {
                    _selectedDateFilter = null;
                  });
                },
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        // Category Filter Chips (All / Cleaning / Gardening)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentSoftGreen.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.category_rounded,
                        size: 13, color: AppColors.primaryMintDark),
                    SizedBox(width: 4),
                    Text(
                      'Category:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryMintDark,
                      ),
                    ),
                  ],
                ),
              ),
              ...['All', 'Cleaning', 'Gardening'].map((cat) {
                final isSelected = _selectedCategoryFilter == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(cat == 'All' ? 'All Categories' : cat),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedCategoryFilter = cat;
                        });
                      }
                    },
                    selectedColor: AppColors.primaryMintDark,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.charcoal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryMintDark
                            : AppColors.borderLight,
                      ),
                    ),
                    visualDensity: VisualDensity.compact,
                    showCheckmark: false,
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Status Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: statuses.map((status) {
              final isSelected = _selectedStatusFilter == status;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(status),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _selectedStatusFilter = status;
                      });
                    }
                  },
                  selectedColor: AppColors.primaryMint,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.charcoal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryMint
                          : AppColors.borderLight,
                    ),
                  ),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingRow(BookingModel booking) {
    final dateFormatted =
        DateFormat('dd MMM yyyy').format(booking.bookingDate);

    Color statusColor;
    if (booking.isPendingApproval) {
      statusColor = AppColors.statusPending;
    } else if (booking.isConfirmed) {
      statusColor = AppColors.statusConfirmed;
    } else if (booking.isInProgress) {
      statusColor = const Color(0xFF7C3AED);
    } else if (booking.isCompleted) {
      statusColor = AppColors.statusCompleted;
    } else if (booking.isRejected || booking.isCancelled) {
      statusColor = AppColors.statusCancelled;
    } else {
      statusColor = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: ID, Date & Status Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      booking.id,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateFormatted,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _showStatusDialog(booking),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        booking.bookingStatus,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down_rounded,
                          size: 16, color: statusColor),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Service Title & Total Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.serviceTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${booking.serviceCategory} • Preferred: $dateFormatted (${booking.timeSlot})',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '₹${booking.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryMintDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Customer details block
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_rounded,
                            size: 16, color: AppColors.primaryMintDark),
                        const SizedBox(width: 6),
                        Text(
                          booking.customerName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.phone_rounded,
                            size: 14, color: AppColors.primaryMintDark),
                        const SizedBox(width: 4),
                        Text(
                          booking.customerPhone,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.charcoal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 15, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${booking.fullAddress} (${booking.dhuleArea})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (booking.specialInstructions.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.notes_rounded,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Note: ${booking.specialInstructions}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Action Section: Approve / Reject for Pending Requests
          if (booking.isPendingApproval) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.hourglass_top_rounded,
                          size: 16, color: Color(0xFFD97706)),
                      SizedBox(width: 6),
                      Text(
                        'Awaiting Business Owner Action',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmApproveBooking(booking),
                          icon: const Icon(Icons.check_circle_outline_rounded,
                              size: 16),
                          label: const Text('Approve Booking',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.statusConfirmed,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmRejectBooking(booking),
                          icon: const Icon(Icons.cancel_outlined, size: 16),
                          label: const Text('Reject Booking',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.statusCancelled,
                            side: const BorderSide(
                                color: AppColors.statusCancelled),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Quick progression for Confirmed Bookings
          if (booking.isConfirmed) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    _updateBookingStatus(booking.id, 'In Progress'),
                icon: const Icon(Icons.play_arrow_rounded, size: 16),
                label: const Text('Dispatch / Start Service (In Progress)',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],

          // Quick progression for In Progress Bookings
          if (booking.isInProgress) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    _updateBookingStatus(booking.id, 'Completed'),
                icon: const Icon(Icons.task_alt_rounded, size: 16),
                label: const Text('Mark Service Completed',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusCompleted,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Assigned Staff & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Assigned Specialist Badge
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.badge_outlined,
                        size: 16, color: AppColors.primaryMintDark),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        booking.assignedStaff,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Assign Staff Button
              OutlinedButton.icon(
                onPressed: () => _showAssignWorkerDialog(booking),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 14),
                label: const Text('Assign Staff',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryMintDark,
                  side: const BorderSide(color: AppColors.primaryMint),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: const Size(60, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 10),

          // Payment Status & Method Row (Requirement 4)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          booking.paymentMethod.toLowerCase().contains('upi')
                              ? Icons.qr_code_2_rounded
                              : Icons.payments_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            booking.paymentMethod,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color:
                            booking.paymentStatus.toLowerCase().contains('paid')
                                ? const Color(0xFFD1FAE5)
                                : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        booking.paymentStatus,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: booking.paymentStatus
                                  .toLowerCase()
                                  .contains('paid')
                              ? const Color(0xFF065F46)
                              : const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Record / Update Payment Button
              OutlinedButton.icon(
                onPressed: () => _showPaymentDialog(booking),
                icon: const Icon(Icons.currency_rupee_rounded, size: 14),
                label: const Text('Record Payment',
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0D9488),
                  side: const BorderSide(color: Color(0xFF0D9488)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: const Size(60, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CUSTOMER DIRECTORY & MANAGEMENT TAB
  // ==========================================

  Widget _buildCustomerTab() {
    final query = _customerSearchQuery.toLowerCase().trim();
    final filtered = _customerList.where((c) {
      if (query.isEmpty) return true;
      return c.name.toLowerCase().contains(query) ||
          c.phone.toLowerCase().contains(query) ||
          (c.email != null && c.email!.toLowerCase().contains(query)) ||
          c.dhuleArea.toLowerCase().contains(query) ||
          c.homeAddress.toLowerCase().contains(query);
    }).toList();

    final totalWithBookings =
        _customerList.where((c) => c.bookingCount > 0).length;
    final totalBookingsPlaced = _bookings.length;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer KPI Summary Cards
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildKpiCard(
                    'Registered Users',
                    '${_customerList.length}',
                    Icons.people_alt_rounded,
                    AppColors.primaryMint,
                  ),
                  const SizedBox(width: 10),
                  _buildKpiCard(
                    'Active Bookers',
                    '$totalWithBookings',
                    Icons.verified_user_rounded,
                    AppColors.statusConfirmed,
                  ),
                  const SizedBox(width: 10),
                  _buildKpiCard(
                    'Total Bookings',
                    '$totalBookingsPlaced',
                    Icons.receipt_long_rounded,
                    const Color(0xFF7C3AED),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Search Filter Box
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _customerSearchQuery = val;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search customer name, mobile, email, locality...',
                  hintStyle:
                      TextStyle(fontSize: 13, color: AppColors.textMuted),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: AppColors.primaryMintDark, size: 20),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Customer Directory List
            if (_customerList.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 48),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColors.primaryMintLight.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.people_outline_rounded,
                        size: 34,
                        color: AppColors.primaryMintDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No registered customers yet.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Customers who book services will appear here with their contact and address details.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else if (filtered.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.person_search_rounded,
                        size: 40, color: AppColors.textMuted),
                    const SizedBox(height: 10),
                    const Text(
                      'No customers matching your search.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _customerSearchQuery = '';
                        });
                      },
                      child: const Text('Clear Search'),
                    ),
                  ],
                ),
              )
            else
              ...filtered.map((customer) => _buildCustomerCard(customer)),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(AdminCustomerSummary customer) {
    final regDateStr =
        DateFormat('dd MMM yyyy').format(customer.registrationDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Avatar, Name, Verified Mobile & Bookings Chip
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryMintLight,
                child: Text(
                  customer.initials,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryMintDark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name.isNotEmpty
                          ? customer.name
                          : 'Dhule Customer',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone_android_rounded,
                            size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          customer.phone,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: AppColors.statusConfirmed
                                    .withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.verified_rounded,
                                  size: 10, color: AppColors.statusConfirmed),
                              SizedBox(width: 3),
                              Text(
                                'VERIFIED',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.statusConfirmed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: customer.bookingCount > 0
                      ? AppColors.primaryMintLight
                      : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: customer.bookingCount > 0
                        ? AppColors.primaryMint.withOpacity(0.3)
                        : AppColors.borderLight,
                  ),
                ),
                child: Text(
                  '${customer.bookingCount} ${customer.bookingCount == 1 ? 'Booking' : 'Bookings'}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: customer.bookingCount > 0
                        ? AppColors.primaryMintDark
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 10),

          // Email block
          if (customer.email != null && customer.email!.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.email_outlined,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  customer.email!,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],

          // Locality and Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_rounded,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${customer.homeAddress.isNotEmpty ? customer.homeAddress : 'Address not specified'} (${customer.dhuleArea}, Dhule)',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Registration Date & Total Spend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    'Registered: $regDateStr',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
              if (customer.totalSpend > 0)
                Text(
                  'Settled: ₹${customer.totalSpend.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D9488),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Action Button: View Booking History
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showCustomerHistoryDialog(customer),
              icon: const Icon(Icons.history_rounded, size: 16),
              label: Text(
                customer.bookingCount > 0
                    ? 'View Customer Booking History (${customer.bookingCount})'
                    : 'Customer Booking History (None yet)',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryMintDark,
                side: const BorderSide(color: AppColors.primaryMint),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomerHistoryDialog(AdminCustomerSummary customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${customer.phone} • ${customer.dhuleArea}, Dhule',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 12),
              Text(
                'Customer Booking History (${customer.bookings.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: customer.bookings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.inbox_rounded,
                                size: 40, color: AppColors.textMuted),
                            SizedBox(height: 8),
                            Text(
                              'No bookings recorded for this customer yet.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: customer.bookings.length,
                        itemBuilder: (context, index) {
                          final b = customer.bookings[index];
                          final dateStr =
                              DateFormat('dd MMM yyyy').format(b.bookingDate);

                          Color statusColor;
                          if (b.isPendingApproval) {
                            statusColor = AppColors.statusPending;
                          } else if (b.isConfirmed) {
                            statusColor = AppColors.statusConfirmed;
                          } else if (b.isInProgress) {
                            statusColor = const Color(0xFF7C3AED);
                          } else if (b.isCompleted) {
                            statusColor = AppColors.statusCompleted;
                          } else {
                            statusColor = AppColors.statusCancelled;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: AppColors.borderLight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      b.id,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                        color: AppColors.charcoal,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        border: Border.all(
                                            color: statusColor
                                                .withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        b.bookingStatus,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      b.serviceTitle,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.charcoal,
                                      ),
                                    ),
                                    Text(
                                      '₹${b.totalAmount.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.primaryMintDark,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Scheduled: $dateStr (${b.timeSlot})',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (b.assignedStaff.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Staff: ${b.assignedStaff}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
