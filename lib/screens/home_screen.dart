import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../config/constants.dart';
import '../data/booking_storage.dart';
import '../data/sample_services.dart';
import '../models/service_item.dart';
import '../services/auth_service.dart';
import '../widgets/service_card.dart';
import 'services_list_screen.dart';
import 'service_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToBookings;
  final VoidCallback? onNavigateToProfile;

  const HomeScreen({
    super.key,
    this.onNavigateToBookings,
    this.onNavigateToProfile,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _showLocalityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.forestGreenLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.location_city_rounded,
                            color: AppColors.forestGreen,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Select Dhule Locality',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.deepCharcoal,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.deepCharcoal),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Our Dhule crew is stationed across these zones for rapid arrival.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
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
                        contentPadding: const EdgeInsets.symmetric(vertical: 2),
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? AppColors.forestGreen
                                : AppColors.surfaceMuted,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            size: 18,
                            color: isCurrent
                                ? AppColors.electricLime
                                : AppColors.textMuted,
                          ),
                        ),
                        title: Text(
                          area,
                          style: TextStyle(
                            fontWeight:
                                isCurrent ? FontWeight.w800 : FontWeight.w600,
                            color: isCurrent
                                ? AppColors.forestGreen
                                : AppColors.deepCharcoal,
                            fontSize: 14.5,
                          ),
                        ),
                        trailing: isCurrent
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.electricLime.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.forestGreenDark,
                                  ),
                                ),
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
          animation: Listenable.merge([storage, AuthService()]),
          builder: (context, _) {
            final auth = AuthService();
            final customerDisplayName = auth.currentProfile?.fullName.isNotEmpty == true
                ? auth.currentProfile!.fullName
                : storage.customerName.isNotEmpty
                    ? storage.customerName
                    : 'Dhule Resident';

            final initials = auth.currentProfile?.initials ??
                (customerDisplayName.isNotEmpty && customerDisplayName != 'Dhule Resident'
                    ? customerDisplayName
                        .split(' ')
                        .map((n) => n.isNotEmpty ? n[0] : '')
                        .take(2)
                        .join()
                        .toUpperCase()
                    : 'M');

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Custom Header: Logo, Greeting, Locality Pill, Profile Avatar
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Logo & Greeting & Location & Profile
                        Row(
                          children: [
                            // Official Brand Emblem with Forest & Lime Accent
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.forestGreen,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.electricLime.withOpacity(0.7),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.forestGreen.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Greeting & Customer Name
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Text(
                                        'Namaste, Dhule! ',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.deepCharcoal,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                      Text('🌱', style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    customerDisplayName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // Clickable Locality Pill
                            InkWell(
                              onTap: _showLocalityPicker,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.forestGreenLight,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.forestGreen.withOpacity(0.2),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      size: 13,
                                      color: AppColors.forestGreen,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      storage.currentLocality.split(',').first,
                                      style: const TextStyle(
                                        color: AppColors.forestGreen,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 14,
                                      color: AppColors.forestGreen,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Profile Button Avatar
                            InkWell(
                              onTap: widget.onNavigateToProfile,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppColors.forestGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.electricLime,
                                    width: 1.6,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.forestGreen.withOpacity(0.22),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Search Input with Animated Focus Ring
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _isSearchFocused ? Colors.white : AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _isSearchFocused
                                  ? AppColors.forestGreen
                                  : AppColors.softBorder,
                              width: 1.5,
                            ),
                            boxShadow: _isSearchFocused
                                ? [
                                    BoxShadow(
                                      color: AppColors.forestGreen.withOpacity(0.12),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: TextField(
                            focusNode: _searchFocusNode,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.trim();
                              });
                            },
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.deepCharcoal,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search home deep clean, lawn mowing...',
                              hintStyle: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppColors.forestGreen,
                                size: 22,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.close_rounded,
                                          size: 18, color: AppColors.textSecondary),
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

                // Main Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Permanent Brand Tagline Hero
                        _buildBrandTaglineHero(),

                        const SizedBox(height: 28),

                        // Section Header: Categories
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Explore Services',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.deepCharcoal,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Two specialized professional offerings',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Category Buttons (Home Cleaning & Gardening Care)
                        Row(
                          children: [
                            // Cleaning Card
                            Expanded(
                              child: _buildCategoryCard(
                                title: 'Home Cleaning',
                                subtitle: '5 Services',
                                tagText: 'SPARKLING',
                                icon: Icons.cleaning_services_rounded,
                                isPrimary: true,
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
                                tagText: 'ORGANIC',
                                icon: Icons.eco_rounded,
                                isPrimary: false,
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
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.deepCharcoal,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Most loved by Dhule households this month',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            TextButton.icon(
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
                              label: const Text(
                                'View All',
                                style: TextStyle(
                                  color: AppColors.forestGreen,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                              icon: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: AppColors.forestGreen,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Popular Service Cards
                        if (popularList.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(28),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.softBorder),
                            ),
                            child: Column(
                              children: const [
                                Icon(Icons.search_off_rounded,
                                    size: 36, color: AppColors.textMuted),
                                SizedBox(height: 8),
                                Text(
                                  'No matching services found for your search.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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

                        const SizedBox(height: 24),

                        // Dhule Trust Guarantee Banner
                        _buildTrustBanner(),

                        const SizedBox(height: 32),
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

  Widget _buildBrandTaglineHero() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.forestGreen,
            Color(0xFF0F3629),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGreen.withOpacity(0.28),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background organic accent shapes
          Positioned(
            right: -15,
            bottom: -20,
            child: Icon(
              Icons.eco_rounded,
              size: 120,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          Positioned(
            right: 42,
            top: -12,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 48,
              color: AppColors.electricLime.withOpacity(0.18),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Branded Pill: Electric Lime highlight
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: AppColors.electricLime,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.electricLime.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.verified_rounded,
                        size: 13,
                        color: AppColors.deepCharcoal,
                      ),
                      SizedBox(width: 5),
                      Text(
                        '100% ECO-VERIFIED CARE',
                        style: TextStyle(
                          color: AppColors.deepCharcoal,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Main Tagline
                const Text(
                  'A Cleaner Home.\nA Greener Life.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    height: 1.18,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 8),

                // Supporting Line
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 290),
                  child: Text(
                    "From spotless spaces to thriving gardens, we've got your home covered.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.88),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required String tagText,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isPrimary ? AppColors.forestGreen.withOpacity(0.2) : AppColors.softBorder,
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepCharcoal.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isPrimary ? AppColors.forestGreen : const Color(0xFF15803D),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (isPrimary ? AppColors.forestGreen : const Color(0xFF15803D))
                              .withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: AppColors.electricLime, size: 26),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.freshMint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tagText,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.forestGreenDark,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.deepCharcoal,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
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
        color: AppColors.forestGreenLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.forestGreen.withOpacity(0.18),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: AppColors.electricLime,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Mopster Dhule Promise',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.deepCharcoal,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTrustPoint('Verified local Dhule specialists & background-checked crew'),
          const SizedBox(height: 6),
          _buildTrustPoint('100% Satisfaction guarantee or free revisit within 24h'),
          const SizedBox(height: 6),
          _buildTrustPoint('Zero advance needed — pay securely by cash or UPI after service'),
        ],
      ),
    );
  }

  Widget _buildTrustPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 3),
          child: Icon(
            Icons.check_circle_rounded,
            size: 15,
            color: AppColors.forestGreen,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.deepCharcoal,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
