import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../config/constants.dart';

class PrivacyDialog extends StatelessWidget {
  const PrivacyDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const PrivacyDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryMintLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.privacy_tip_outlined,
              color: AppColors.primaryMintDark,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Privacy & Data Policy',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: AppColors.charcoal,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Mopster • Dhule, Maharashtra',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryMintDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildPoint(
              icon: Icons.person_pin_circle_outlined,
              title: 'Data Collection & Purpose',
              description:
                  'We only collect your name, phone number, locality (e.g., Deopur, Walwadi, Old Dhule), and street address strictly to coordinate and fulfill home cleaning and gardening services.',
            ),
            const SizedBox(height: 12),
            _buildPoint(
              icon: Icons.security_rounded,
              title: 'Customer Data Isolation',
              description:
                  'Your booking records, addresses, and contact numbers are private to your authenticated session. We never sell, rent, or monetize customer data to advertising brokers.',
            ),
            const SizedBox(height: 12),
            _buildPoint(
              icon: Icons.shield_outlined,
              title: 'Secure Cloud Infrastructure',
              description:
                  'Customer profiles, authentication tokens, and service requests are secured using PostgreSQL Row-Level Security (RLS) on Supabase Cloud.',
            ),
            const SizedBox(height: 12),
            _buildPoint(
              icon: Icons.support_agent_rounded,
              title: 'Support & Data Requests',
              description:
                  'To modify your saved information or request account deletion, contact our support team at ${AppConstants.supportEmail}.',
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryMint,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Understood',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _buildPoint({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primaryMintDark),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
