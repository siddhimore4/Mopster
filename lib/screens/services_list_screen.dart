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
              color: AppColors.charcoal, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isCleaning ? 'Home Cleaning Services' : 'Gardening Services',
          style: const TextStyle(
            color: AppColors.charcoal,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Switcher Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              color: Colors.white,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isCleaning
                                ? AppColors.primaryMint
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isCleaning
                                ? [
                                    BoxShadow(
                                      color:
                                          AppColors.primaryMint.withOpacity(0.3),
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
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Cleaning (${SampleServices.cleaningServices.length})',
                                style: TextStyle(
                                  color: isCleaning
                                      ? Colors.white
                                      : AppColors.charcoal,
                                  fontWeight: isCleaning
                                      ? FontWeight.w700
                                      : FontWeight.w500,
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !isCleaning
                                ? AppColors.primaryMint
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: !isCleaning
                                ? [
                                    BoxShadow(
                                      color:
                                          AppColors.primaryMint.withOpacity(0.3),
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
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Gardening (${SampleServices.gardeningServices.length})',
                                style: TextStyle(
                                  color: !isCleaning
                                      ? Colors.white
                                      : AppColors.charcoal,
                                  fontWeight: !isCleaning
                                      ? FontWeight.w700
                                      : FontWeight.w500,
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

            // Disclaimers & Active list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Notice badge
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMintLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: AppColors.primaryMintDark,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sample prices shown for Dhule city. Actual quotes depend on room size or garden area.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.charcoal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Service cards
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
