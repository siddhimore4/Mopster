import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/colors.dart';
import '../config/constants.dart';
import '../data/booking_storage.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/privacy_dialog.dart';
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.softBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Edit Profile & Address',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.deepCharcoal,
                            letterSpacing: -0.3,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: AppColors.deepCharcoal),
                          onPressed: () => Navigator.pop(modalCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Verified Phone Banner (Read-only for security)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.freshMint,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.forestGreen.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: AppColors.forestGreen,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Verified Mobile: ${profile?.formattedPhone ?? storage.customerPhone}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.forestGreen,
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
                        labelStyle: const TextStyle(color: AppColors.mutedGrey),
                        hintText: 'Enter your full name',
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.forestGreen,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.softBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: AppColors.forestGreen, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address (Optional)',
                        labelStyle: const TextStyle(color: AppColors.mutedGrey),
                        hintText: 'e.g. yourname@example.com',
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColors.forestGreen,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.softBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: AppColors.forestGreen, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: selectedArea,
                      decoration: InputDecoration(
                        labelText: 'Dhule Locality *',
                        labelStyle: const TextStyle(color: AppColors.mutedGrey),
                        prefixIcon: const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.forestGreen,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.softBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: AppColors.forestGreen, width: 1.5),
                        ),
                      ),
                      items: AppConstants.dhuleLocalities.map((loc) {
                        return DropdownMenuItem<String>(
                          value: loc,
                          child: Text(
                            '$loc, Dhule',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.deepCharcoal,
                            ),
                          ),
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
                        labelText: 'Home / Flat / Society Address',
                        labelStyle: const TextStyle(color: AppColors.mutedGrey),
                        hintText: 'e.g. Flat 302, Green Palms, Wadi Bhokar Road',
                        prefixIcon: const Icon(
                          Icons.home_outlined,
                          color: AppColors.forestGreen,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.softBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: AppColors.forestGreen, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Save Changes',
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: () async {
                        final newName = nameCtrl.text.trim();
                        final newEmail = emailCtrl.text.trim();
                        final newAddress = addrCtrl.text.trim();

                        if (newName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              content:
                                  const Text('Please enter your full name'),
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
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              backgroundColor: AppColors.forestGreen,
                              content:
                                  const Text('Profile updated successfully!'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              backgroundColor: const Color(0xFFDC2626),
                              content:
                                  const Text('Update failed. Please try again.'),
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

  Future<void> _contactSupportEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: AppConstants.supportEmail,
      queryParameters: {
        'subject': 'Mopster Customer Support',
      },
    );
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
                'Could not open email client. Please email us at ${AppConstants.supportEmail}'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Support email: ${AppConstants.supportEmail}'),
          ),
        );
      }
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Log Out of Mopster?',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.deepCharcoal,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out? You can sign back in anytime using your registered email and password.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.mutedGrey,
            height: 1.45,
          ),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.deepCharcoal,
                fontWeight: FontWeight.w600,
              ),
            ),
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
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Log Out',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
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
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: AppColors.deepCharcoal,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Avatar & Name Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.softBorder, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.forestGreen.withOpacity(0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Avatar with glowing Forest & Lime ring
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 82,
                              height: 82,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.electricLime,
                                    AppColors.freshMint,
                                    AppColors.forestGreen,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                            CircleAvatar(
                              radius: 37,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 34,
                                backgroundColor: AppColors.forestGreen,
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.electricLime,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.deepCharcoal,
                            letterSpacing: -0.3,
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
                              color: AppColors.mutedGrey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              displayPhone,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.deepCharcoal,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.freshMint,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.verified_rounded,
                                    size: 11,
                                    color: AppColors.forestGreen,
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    'VERIFIED',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.forestGreen,
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
                                color: AppColors.mutedGrey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                displayEmail,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.mutedGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        // Locality Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.freshMint,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: AppColors.forestGreen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$displayLocality, Dhule',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.forestGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _editProfileModal,
                          icon: const Icon(Icons.edit_outlined, size: 15),
                          label: const Text('Edit Details'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.forestGreen,
                            side: const BorderSide(
                              color: AppColors.forestGreen,
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Saved Dhule Address Section
                  _buildSectionHeader('Saved Dhule Address'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.softBorder, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.forestGreen.withOpacity(0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.freshMint,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.home_rounded,
                            color: AppColors.forestGreen,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Home ($displayLocality)',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.deepCharcoal,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                displayAddress.isNotEmpty
                                    ? displayAddress
                                    : 'No address saved yet. Tap edit to save your Dhule address.',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.mutedGrey,
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
                            color: AppColors.mutedGrey,
                          ),
                          onPressed: _editProfileModal,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Support & Helpdesk Section
                  _buildSectionHeader('Support & Helpdesk'),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.softBorder, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.forestGreen.withOpacity(0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.freshMint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.email_outlined,
                          color: AppColors.forestGreen,
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'Email Support',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.deepCharcoal,
                        ),
                      ),
                      subtitle: const Text(
                        AppConstants.supportEmail,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.forestGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 13,
                        color: AppColors.mutedGrey,
                      ),
                      onTap: _contactSupportEmail,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Legal & App Info
                  _buildSectionHeader('Legal & App Info'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.softBorder, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.forestGreen.withOpacity(0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'App Version',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.mutedGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'v1.0.0 (Dhule)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.deepCharcoal,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24, color: AppColors.softBorder),
                        InkWell(
                          onTap: () => PrivacyDialog.show(context),
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Row(
                                  children: [
                                    Icon(Icons.shield_outlined,
                                        size: 18, color: AppColors.forestGreen),
                                    SizedBox(width: 10),
                                    Text(
                                      'Customer Privacy Policy',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.deepCharcoal,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(Icons.arrow_forward_ios_rounded,
                                    size: 13, color: AppColors.mutedGrey),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Customer Logout Option
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.red.shade200,
                        width: 1.2,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
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
                          fontWeight: FontWeight.w800,
                          color: Colors.red.shade700,
                        ),
                      ),
                      subtitle: const Text(
                        'Sign out from this account on this device',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedGrey,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 13,
                        color: Colors.red.shade400,
                      ),
                      onTap: _confirmLogout,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Mopster Brand Signature Footer
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.forestGreen,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.electricLime,
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Mopster • Dhule, Maharashtra',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.deepCharcoal,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'A Cleaner Home. A Greener Life.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.forestGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.electricLime,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.deepCharcoal,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
