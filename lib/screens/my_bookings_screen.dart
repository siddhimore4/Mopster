import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../data/booking_storage.dart';
import '../models/service_item.dart';
import '../widgets/booking_card.dart';
import '../widgets/custom_button.dart';
import 'booking_details_screen.dart';
import 'services_list_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storage = BookingStorage();

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            color: AppColors.deepCharcoal,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: AnimatedBuilder(
            animation: storage,
            builder: (context, _) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.softBorder, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.forestGreen.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.forestGreen,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.deepCharcoal,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: -0.2,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  tabs: [
                    Tab(
                      text: 'Upcoming (${storage.upcomingBookings.length})',
                    ),
                    Tab(
                      text: 'Active (${storage.inProgressBookings.length})',
                    ),
                    Tab(
                      text: 'Past (${storage.pastBookings.length})',
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: storage,
          builder: (context, _) {
            final upcoming = storage.upcomingBookings;
            final inProgress = storage.inProgressBookings;
            final past = storage.pastBookings;
            final hasAny = storage.hasAnyBookings;

            return TabBarView(
              controller: _tabController,
              children: [
                // 1. Upcoming Tab (Pending Approval & Confirmed)
                _buildBookingList(
                  bookings: upcoming,
                  emptyTitle: hasAny
                      ? 'No Upcoming Bookings'
                      : "You haven't booked any services yet",
                  emptySubtitle: hasAny
                      ? 'You have no active requests awaiting approval or confirmed.'
                      : 'Browse our home cleaning and gardening services in Dhule and request your first booking!',
                  showExploreButton: !hasAny,
                ),

                // 2. In Progress Tab
                _buildBookingList(
                  bookings: inProgress,
                  emptyTitle: hasAny
                      ? 'No Services In Progress'
                      : "You haven't booked any services yet",
                  emptySubtitle: hasAny
                      ? 'Active cleaning or gardening visits currently underway will appear here.'
                      : 'Browse our home cleaning and gardening services in Dhule and request your first booking!',
                  showExploreButton: !hasAny,
                ),

                // 3. Past Tab (Completed, Rejected, Cancelled)
                _buildBookingList(
                  bookings: past,
                  emptyTitle: hasAny
                      ? 'No Past Service Records'
                      : "You haven't booked any services yet",
                  emptySubtitle: hasAny
                      ? 'Completed, rejected, or cancelled services will appear here.'
                      : 'Browse our home cleaning and gardening services in Dhule and request your first booking!',
                  showExploreButton: !hasAny,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingList({
    required List<dynamic> bookings,
    required String emptyTitle,
    required String emptySubtitle,
    required bool showExploreButton,
  }) {
    if (bookings.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.freshMint, Color(0xFFE8F6EE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.electricLime,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.forestGreen.withOpacity(0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.calendar_today_rounded,
                    size: 40,
                    color: AppColors.forestGreen,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                emptyTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.deepCharcoal,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                emptySubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedGrey,
                  height: 1.45,
                ),
              ),
              if (showExploreButton) ...[
                const SizedBox(height: 28),
                SizedBox(
                  width: 200,
                  child: CustomButton(
                    text: 'Book a Service',
                    icon: Icons.cleaning_services_rounded,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ServicesListScreen(
                            category: ServiceCategory.cleaning,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final item = bookings[index];
        return BookingCard(
          booking: item,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingDetailsScreen(booking: item),
              ),
            );
          },
        );
      },
    );
  }
}
