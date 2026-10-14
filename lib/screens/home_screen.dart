import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../config/constants.dart';
import '../data/booking_storage.dart';
import '../data/sample_services.dart';
import '../models/service_item.dart';
import '../widgets/service_card.dart';
import 'services_list_screen.dart';
import 'service_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToBookings;

  const HomeScreen({super.key, this.onNavigateToBookings});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _offerController = PageController();
  int _activeOfferPage = 0;
  String _searchQuery = '';

  @override
  void dispose() {
    _offerController.dispose();
    super.dispose();
  }

  void _showLocalityPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Dhule Locality',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoal,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Our Dhule staff is stationed across key zones for quick dispatch.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: AppConstants.dhuleLocalities.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: AppColors.divider),
                  itemBuilder: (ctx, index) {
                    final area = AppConstants.dhuleLocalities[index];
                    final isCurrent =
                        BookingStorage().currentLocality.contains(area);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.location_on_rounded,
                        color: isCurrent
                            ? AppColors.primaryMint
                            : AppColors.textMuted,
                      ),
                      title: Text(
                        area,
                        style: TextStyle(
                          fontWeight:
                              isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: isCurrent
                              ? AppColors.primaryMintDark
                              : AppColors.charcoal,
                        ),
                      ),
                      trailing: isCurrent
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primaryMint,
                            )
                          : null,
                      onTap: () {
                        BookingStorage().updateLocality('$area, Dhule');
                        setState(() {});
                        Navigator.pop(ctx);
                      },
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

  @override
  Widget build(BuildContext context) {
    final storage = BookingStorage();
    final popularList = SampleServices.popularServices.where((s) {
      if (_searchQuery.isEmpty) return true;
      return s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.shortDescription.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: storage,
          builder: (context, _) {
            return CustomScrollView(
              slivers: [
                // Top App Bar with Greeting & Dhule Location
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row: Greeting & Locality Pill
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Namaste, Dhule! ',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.charcoal,
                                      ),
                                    ),
                                    const Text('👋',
                                        style: TextStyle(fontSize: 18)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  storage.customerName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            // Clickable Location Pill
                            InkWell(
                              onTap: _showLocalityPicker,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryMintLight,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        AppColors.primaryMint.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      size: 15,
                                      color: AppColors.primaryMintDark,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      storage.currentLocality.split(',').first,
                                      style: const TextStyle(
                                        color: AppColors.primaryMintDark,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 16,
                                      color: AppColors.primaryMintDark,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Search Bar
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextField(
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.trim();
                              });
                            },
                            decoration: InputDecoration(
                              hintText:
                                  'Search cleaning, gardening, lawn...',
                              hintStyle: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppColors.primaryMintDark,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded,
                                          size: 18),
                                      onPressed: () {
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Body Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Promotional Offers Carousel
                        _buildOffersCarousel(),

                        const SizedBox(height: 28),

                        // Service Categories Section
                        const Text(
                          'Service Categories',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Choose between our two specialized home services',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Category Buttons (Cleaning & Gardening)
                        Row(
                          children: [
                            // Cleaning Card
                            Expanded(
                              child: _buildCategoryCard(
                                title: 'Home Cleaning',
                                subtitle: '5 Services',
                                icon: Icons.cleaning_services_rounded,
                                gradientColors: const [
                                  Color(0xFF00B388),
                                  Color(0xFF008F6B),
                                ],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ServicesListScreen(
                                        category: ServiceCategory.cleaning,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Gardening Card
                            Expanded(
                              child: _buildCategoryCard(
                                title: 'Gardening Care',
                                subtitle: '5 Services',
                                icon: Icons.eco_rounded,
                                gradientColors: const [
                                  Color(0xFF10B981),
                                  Color(0xFF059669),
                                ],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ServicesListScreen(
                                        category: ServiceCategory.gardening,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Popular Services Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Popular in Dhule',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.charcoal,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Most booked by Dhule residents this month',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ServicesListScreen(
                                      category: ServiceCategory.cleaning,
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'View All',
                                style: TextStyle(
                                  color: AppColors.primaryMintDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Popular Service Cards
                        if (popularList.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            alignment: Alignment.center,
                            child: const Text(
                              'No matching services found.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        else
                          ...popularList.map((service) {
                            return ServiceCard(
                              service: service,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ServiceDetailScreen(service: service),
                                  ),
                                );
                              },
                            );
                          }),

                        const SizedBox(height: 16),

                        // Why Choose Mopster Banner
                        _buildTrustBanner(),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOffersCarousel() {
    final List<Map<String, String>> offers = [
      {
        'tag': 'SPECIAL OFFER',
        'title': 'Dhule Welcome Deal',
        'discount': 'Flat ₹200 OFF',
        'code': 'Use code: MOPDHULE',
        'color': '0xFF00B388',
      },
      {
        'tag': 'SEASONAL CARE',
        'title': 'Garden Clean + Trim',
        'discount': 'Save 15% on Combo',
        'code': 'Book any 2 services',
        'color': '0xFF059669',
      },
      {
        'tag': 'FESTIVAL READY',
        'title': 'Deep Cleaning Package',
        'discount': 'Free Bathroom Sanitization',
        'code': 'With Full Home Deep Clean',
        'color': '0xFF0D9488',
      },
    ];

    return Column(
      children: [
        SizedBox(
          height: 155,
          child: PageView.builder(
            controller: _offerController,
            onPageChanged: (idx) {
              setState(() {
                _activeOfferPage = idx;
              });
            },
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final item = offers[index];
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(int.parse(item['color']!)),
                      Color(int.parse(item['color']!)).withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(int.parse(item['color']!)).withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -10,
                      bottom: -10,
                      child: Icon(
                        Icons.local_offer_rounded,
                        size: 90,
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['tag']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['discount']!,
                          style: const TextStyle(
                            color: Color(0xFFD1FAE5),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['code']!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            offers.length,
            (idx) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _activeOfferPage == idx ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _activeOfferPage == idx
                    ? AppColors.primaryMint
                    : AppColors.borderLight,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight, width: 1.2),
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryMintLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryMint.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.shield_rounded,
                color: AppColors.primaryMintDark,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Mopster Dhule Guarantee',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '• Verified background-checked local professionals in Dhule\n• 100% Satisfaction guarantee or free re-work\n• Zero pre-payment required — pay cash after service',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.charcoal,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
