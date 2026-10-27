import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../config/constants.dart';
import '../data/booking_storage.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/privacy_dialog.dart';
import 'admin/admin_login_screen.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _editProfileModal() {
    final auth = AuthService();
    final profile = auth.currentProfile;
    final storage = BookingStorage();

    final nameCtrl = TextEditingController(
      text: profile?.fullName.isNotEmpty == true
          ? profile!.fullName
          : storage.customerName,
    );
    final emailCtrl = TextEditingController(
      text: profile?.email ?? '',
    );
    String selectedArea = profile?.dhuleArea.isNotEmpty == true
        ? profile!.dhuleArea
        : storage.currentLocality.split(',').first.trim();
    if (!AppConstants.dhuleLocalities.contains(selectedArea)) {
      selectedArea = AppConstants.dhuleLocalities.first;
    }
    final addrCtrl = TextEditingController(
      text: profile?.homeAddress.isNotEmpty == true
          ? profile!.homeAddress
          : storage.customerAddress,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
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
                          onPressed: () => Navigator.pop(modalCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Verified Phone Banner (Read-only for security)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.statusConfirmed.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: AppColors.statusConfirmed,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Verified Mobile: ${profile?.formattedPhone ?? storage.customerPhone}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Customer Full Name *',
                        hintText: 'Enter your full name',
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.primaryMint,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address (Optional)',
                        hintText: 'e.g. yourname@example.com',
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColors.primaryMint,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: selectedArea,
                      decoration: InputDecoration(
                        labelText: 'Dhule Locality *',
                        prefixIcon: const Icon(
                          Icons.location_city_rounded,
                          color: AppColors.primaryMint,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: AppConstants.dhuleLocalities.map((area) {
                        return DropdownMenuItem(
                          value: area,
                          child: Text(area, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            selectedArea = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: addrCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Complete Dhule Address *',
                        hintText: 'House / Flat number, Landmark, Dhule',
                        prefixIcon: const Icon(
                          Icons.home_outlined,
                          color: AppColors.primaryMint,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Save Changes',
                      onPressed: () async {
                        final newName = nameCtrl.text.trim();
                        final newEmail = emailCtrl.text.trim();
                        final newAddress = addrCtrl.text.trim();

                        if (newName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter your full name'),
                            ),
                          );
                          return;
                        }

                        Navigator.pop(modalCtx);

                        final res = await auth.updateProfile(
                          fullName: newName,
                          email: newEmail.isNotEmpty ? newEmail : null,
                          dhuleArea: selectedArea,
                          homeAddress: newAddress,
                        );

                        if (!mounted) return;
                        if (res) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.statusConfirmed,
                              content: Text('Profile updated successfully!'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.statusCancelled,
                              content: Text('Update failed. Please try again.'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
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

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log Out of Mopster?',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.charcoal,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out? You can sign back in anytime using your registered mobile number and OTP.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService().signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = BookingStorage();
    final auth = AuthService();

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
          animation: Listenable.merge([storage, auth]),
          builder: (context, _) {
            final profile = auth.currentProfile;
            final displayName = profile?.fullName.isNotEmpty == true
                ? profile!.fullName
                : storage.customerName.isNotEmpty
                    ? storage.customerName
                    : 'Customer';

            final displayPhone = profile?.formattedPhone.isNotEmpty == true
                ? profile!.formattedPhone
                : storage.customerPhone.isNotEmpty
                    ? storage.customerPhone
                    : 'No Phone';

            final displayEmail = profile?.email ?? '';
            final displayLocality = profile?.dhuleArea.isNotEmpty == true
                ? profile!.dhuleArea
                : storage.currentLocality.split(',').first.trim();

            final displayAddress = profile?.homeAddress.isNotEmpty == true
                ? profile!.homeAddress
                : storage.customerAddress;

            final initials = profile?.initials ??
                (displayName.isNotEmpty && displayName != 'Customer'
                    ? displayName
                        .split(' ')
                        .map((n) => n.isNotEmpty ? n[0] : '')
                        .take(2)
                        .join()
                        .toUpperCase()
                    : 'M');

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
                          displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Verified Phone Row
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.phone_android_rounded,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              displayPhone,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.charcoal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.statusConfirmed
                                      .withOpacity(0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.verified_rounded,
                                    size: 11,
                                    color: AppColors.statusConfirmed,
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    'VERIFIED',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.statusConfirmed,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (displayEmail.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.email_outlined,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                displayEmail,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
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
                                '$displayLocality, Dhule',
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
                              Text(
                                'Home ($displayLocality)',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.charcoal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                displayAddress.isNotEmpty
                                    ? displayAddress
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
                        const Divider(height: 22, color: AppColors.divider),
                        InkWell(
                          onTap: () => PrivacyDialog.show(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Row(
                                  children: [
                                    Icon(Icons.shield_outlined,
                                        size: 16,
                                        color: AppColors.primaryMintDark),
                                    SizedBox(width: 8),
                                    Text(
                                      'Customer Privacy Policy',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.charcoal,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(Icons.arrow_forward_ios_rounded,
                                    size: 13, color: AppColors.textMuted),
                              ],
                            ),
                          ),
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

                  const SizedBox(height: 16),

                  // Customer Logout Option
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.red.shade200,
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.logout_rounded,
                          color: Colors.red.shade700,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.red.shade700,
                        ),
                      ),
                      subtitle: const Text(
                        'Sign out from this account on this device',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Colors.red.shade400,
                      ),
                      onTap: _confirmLogout,
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
