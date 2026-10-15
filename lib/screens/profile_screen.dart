import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../config/constants.dart';
import '../data/booking_storage.dart';
import '../widgets/custom_button.dart';
import 'admin/admin_login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _editProfileModal() {
    final storage = BookingStorage();
    final nameCtrl = TextEditingController(text: storage.customerName);
    final phoneCtrl = TextEditingController(
      text: storage.customerPhone.replaceAll('+91 ', '').trim(),
    );
    final addrCtrl = TextEditingController(text: storage.customerAddress);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Profile & Address',
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
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  hintText: 'Enter your full name',
                  prefixIcon: const Icon(Icons.person_outline_rounded,
                      color: AppColors.primaryMint),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Mobile Phone',
                  hintText: 'Enter 10-digit mobile number',
                  prefixText: '+91 ',
                  prefixIcon: const Icon(Icons.phone_android_rounded,
                      color: AppColors.primaryMint),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: addrCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Dhule Address',
                  hintText: 'Enter your complete street address in Dhule',
                  prefixIcon: const Icon(Icons.home_outlined,
                      color: AppColors.primaryMint),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Save Changes',
                onPressed: () {
                  storage.updateProfile(
                    name: nameCtrl.text.trim(),
                    phone: '+91 ${phoneCtrl.text.trim()}',
                    address: addrCtrl.text.trim(),
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully!')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSupportDialog(String type) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          type == 'call'
              ? 'Dhule Customer Helpline'
              : type == 'email'
                  ? 'Email Support'
                  : 'WhatsApp Support',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type == 'call'
                  ? 'Phone: ${AppConstants.supportPhone}'
                  : type == 'email'
                      ? 'Email: ${AppConstants.supportEmail}'
                      : 'WhatsApp: +91 98230 XXXXX',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryMintDark,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Operating hours:\nMon - Sun: 8:00 AM to 8:00 PM\nDhule Operations Center',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = BookingStorage();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: AppColors.charcoal,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: storage,
          builder: (context, _) {
            final initials = storage.customerName.isNotEmpty
                ? storage.customerName
                    .split(' ')
                    .map((n) => n.isNotEmpty ? n[0] : '')
                    .take(2)
                    .join()
                    .toUpperCase()
                : 'G';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Avatar & Name Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primaryMintLight,
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryMintDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          storage.customerName.isNotEmpty
                              ? storage.customerName
                              : 'Guest Customer',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          storage.customerPhone.isNotEmpty
                              ? storage.customerPhone
                              : 'Tap Edit Details to set phone number',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // City Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentSoftGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: AppColors.primaryMintDark,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${storage.currentLocality.split(',').first}, Dhule',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryMintDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _editProfileModal,
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit Details'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryMintDark,
                            side: const BorderSide(
                              color: AppColors.primaryMint,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Saved Dhule Address Section
                  _buildSectionHeader('Saved Dhule Address'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.home_rounded,
                          color: AppColors.primaryMint,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Home (Default)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.charcoal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                storage.customerAddress.isNotEmpty
                                    ? storage.customerAddress
                                    : 'No address saved yet. Tap edit to save your Dhule address.',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: AppColors.textMuted,
                          ),
                          onPressed: _editProfileModal,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Support & Helpline Section
                  _buildSectionHeader('Support & Dhule Helpdesk'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.phone_in_talk_rounded,
                              color: AppColors.primaryMintDark),
                          title: const Text('Call Dhule Support'),
                          subtitle: const Text(AppConstants.supportPhone),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded,
                              size: 14),
                          onTap: () => _showSupportDialog('call'),
                        ),
                        const Divider(height: 1, color: AppColors.divider),
                        ListTile(
                          leading: const Icon(Icons.email_outlined,
                              color: AppColors.primaryMintDark),
                          title: const Text('Email Helpdesk'),
                          subtitle: const Text(AppConstants.supportEmail),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded,
                              size: 14),
                          onTap: () => _showSupportDialog('email'),
                        ),
                        const Divider(height: 1, color: AppColors.divider),
                        ListTile(
                          leading: const Icon(Icons.chat_bubble_outline_rounded,
                              color: AppColors.primaryMintDark),
                          title: const Text('WhatsApp Chat Assistance'),
                          subtitle: const Text('Quick query resolution'),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded,
                              size: 14),
                          onTap: () => _showSupportDialog('whatsapp'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // App Info & Disclaimers
                  _buildSectionHeader('About Mopster'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'City Operational Area',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              'Dhule, Maharashtra',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.charcoal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'App Version',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              'v1.0.0 (Local Build)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.charcoal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Local Data Persistence',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              'Enabled (Cloud Synced)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryMintDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Business Owner & Admin Portal Link
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryMint.withOpacity(0.3),
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryMintLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          color: AppColors.primaryMintDark,
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'Business Owner Portal',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                      ),
                      subtitle: const Text(
                        'Dispatch bookings & manage staff (Dhule)',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.primaryMintDark,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminLoginScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.charcoal,
      ),
    );
  }
}
