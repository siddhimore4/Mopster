import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../config/typography.dart';
import '../data/sample_services.dart';
import '../models/service_item.dart';
import '../widgets/service_card.dart';
import 'service_detail_screen.dart';

class ServicesListScreen extends StatefulWidget {
  final ServiceCategory category;

  const ServicesListScreen({
    super.key,
    required this.category,
  });

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  late ServiceCategory _currentCategory;

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.category;
  }

  @override
  Widget build(BuildContext context) {
    final List<ServiceItem> services;
    final String screenTitle;

    switch (_currentCategory) {
      case ServiceCategory.cleaning:
        services = SampleServices.cleaningServices;
        screenTitle = 'Home Cleaning Services';
        break;
      case ServiceCategory.gardening:
        services = SampleServices.gardeningServices;
        screenTitle = 'Gardening Services';
        break;
      case ServiceCategory.carWashing:
        services = SampleServices.carWashingServices;
        screenTitle = 'Car Washing Services';
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.ivoryCard,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.softBorder, height: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.darkCharcoal, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          screenTitle,
          style: AppTypography.headingMedium(
            color: AppColors.darkCharcoal,
            fontSize: 19,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Switcher Header (3 Categories)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
              color: AppColors.ivoryCard,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.lightBeige,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.softBorder, width: 1),
                ),
                child: Row(
                  children: [
                    _buildCategoryTab(
                      category: ServiceCategory.cleaning,
                      label: 'Cleaning',
                      icon: Icons.cleaning_services_rounded,
                      count: SampleServices.cleaningServices.length,
                    ),
                    _buildCategoryTab(
                      category: ServiceCategory.gardening,
                      label: 'Gardening',
                      icon: Icons.eco_rounded,
                      count: SampleServices.gardeningServices.length,
                    ),
                    _buildCategoryTab(
                      category: ServiceCategory.carWashing,
                      label: 'Car Wash',
                      icon: Icons.local_car_wash_rounded,
                      count: SampleServices.carWashingServices.length,
                    ),
                  ],
                ),
              ),
            ),

            // Active list
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(18.0),
                children: [
                  ...services.map((item) {
                    return ServiceCard(
                      service: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ServiceDetailScreen(service: item),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTab({
    required ServiceCategory category,
    required String label,
    required IconData icon,
    required int count,
  }) {
    final isSelected = _currentCategory == category;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentCategory = category;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryForestGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryForestGreen.withOpacity(0.24),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? AppColors.secondarySage
                    : AppColors.mutedGreyText,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  '$label ($count)',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.darkCharcoal,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
