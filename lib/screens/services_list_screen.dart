import 'package:flutter/material.dart';
import '../config/colors.dart';
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
    final services = _currentCategory == ServiceCategory.cleaning
        ? SampleServices.cleaningServices
        : SampleServices.gardeningServices;

    final isCleaning = _currentCategory == ServiceCategory.cleaning;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.deepCharcoal, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isCleaning ? 'Home Cleaning Services' : 'Gardening Services',
          style: const TextStyle(
            color: AppColors.deepCharcoal,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Switcher Header
            Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
              color: Colors.white,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.softBorder, width: 1),
                ),
                child: Row(
                  children: [
                    // Cleaning Tab
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentCategory = ServiceCategory.cleaning;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isCleaning
                                ? AppColors.forestGreen
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isCleaning
                                ? [
                                    BoxShadow(
                                      color:
                                          AppColors.forestGreen.withOpacity(0.24),
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
                                Icons.cleaning_services_rounded,
                                size: 18,
                                color: isCleaning
                                    ? AppColors.electricLime
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Cleaning (${SampleServices.cleaningServices.length})',
                                style: TextStyle(
                                  color: isCleaning
                                      ? Colors.white
                                      : AppColors.deepCharcoal,
                                  fontWeight: isCleaning
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Gardening Tab
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentCategory = ServiceCategory.gardening;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !isCleaning
                                ? AppColors.forestGreen
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: !isCleaning
                                ? [
                                    BoxShadow(
                                      color:
                                          AppColors.forestGreen.withOpacity(0.24),
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
                                Icons.eco_rounded,
                                size: 18,
                                color: !isCleaning
                                    ? AppColors.electricLime
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Gardening (${SampleServices.gardeningServices.length})',
                                style: TextStyle(
                                  color: !isCleaning
                                      ? Colors.white
                                      : AppColors.deepCharcoal,
                                  fontWeight: !isCleaning
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
}
