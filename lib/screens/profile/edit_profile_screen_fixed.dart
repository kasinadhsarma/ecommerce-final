import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../utils/app_utils.dart';
import '../../widgets/common_widgets.dart';
import '../../services/biometric_auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _selectedGender;
  late DateTime _selectedBirthDate;
  bool _isLoading = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _selectedGender = user?.gender;

    // Set a default birth date
    _selectedBirthDate = DateTime(1990, 1, 1);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    if (!authProvider.isAuthenticated || authProvider.user == null) {
      return const Scaffold(
        body: Center(
          child: Text('You need to be logged in to edit your profile.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              Center(
                child: _buildProfileImage(authProvider.user!),
              ),
              SizedBox(height: isTablet ? 40 : 30),

              // Personal Information
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: isTablet ? 22 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isTablet ? 24 : 16),

              // Name
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                prefixIcon: const Icon(Icons.person),
                validator: Validators.validateName,
              ),
              SizedBox(height: isTablet ? 24 : 16),

              // Email
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter your email address',
                prefixIcon: const Icon(Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                enabled: false, // Email cannot be changed
              ),
              SizedBox(height: isTablet ? 24 : 16),

              // Phone
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: 'Enter your phone number',
                prefixIcon: const Icon(Icons.phone),
                keyboardType: TextInputType.phone,
                validator: Validators.validatePhone,
              ),
              SizedBox(height: isTablet ? 24 : 16),

              // Gender
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: const Icon(Icons.people),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                items: ['Male', 'Female', 'Other', 'Prefer not to say']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),
              SizedBox(height: isTablet ? 24 : 16),

              // Birth Date
              _buildDatePicker(context),
              SizedBox(height: isTablet ? 40 : 30),

              // Additional Settings
              Text(
                'Account Settings',
                style: TextStyle(
                  fontSize: isTablet ? 22 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isTablet ? 24 : 16),

              // Marketing Preferences Card
              _buildPreferencesCard(),
              SizedBox(height: isTablet ? 24 : 16),

              // Security Settings Card
              _buildSecurityCard(context),
              SizedBox(height: isTablet ? 40 : 30),

              // Save Button
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      text: 'Save Changes',
                      onPressed: () => _saveProfile(context),
                    ),
              SizedBox(height: isTablet ? 24 : 16),

              // Delete Account Button
              Center(
                child: TextButton.icon(
                  icon: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Delete Account',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () => _showDeleteAccountDialog(context),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(User user) {
    return Stack(
      children: [
        // Profile Image
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey.shade200,
          child:
              user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.network(
                        user.profileImageUrl!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey,
                    ),
        ),

        // Edit button
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: InkWell(
              onTap: () => _showImageSourceDialog(context),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Birth Date',
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isTablet ? 20 : 16,
            ),
          ),
          controller: TextEditingController(
            text: DateFormat('MMM dd, yyyy').format(_selectedBirthDate),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select your birth date';
            }
            return null;
          },
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPreferencesCard() {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 15 : 10),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Marketing Preferences',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isTablet ? 24 : 16),
            _buildSwitchTile(
              'Email Notifications',
              'Receive offers and updates via email',
              true,
              (value) {
                // Update preference
              },
            ),
            _buildSwitchTile(
              'Push Notifications',
              'Get notified about deals and new products',
              true,
              (value) {
                // Update preference
              },
            ),
            _buildSwitchTile(
              'Order Updates',
              'Stay informed about your orders status',
              true,
              (value) {
                // Update preference
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 15 : 10),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security Settings',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isTablet ? 24 : 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to change password screen
                showSnackBar(
                  context,
                  'Change password functionality will be implemented soon!',
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.fingerprint),
              title: const Text('Enable Biometric Login'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to biometric login setup
                if (Provider.of<AuthProvider>(context, listen: false).user !=
                    null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BiometricSetupScreen(
                        userId:
                            Provider.of<AuthProvider>(context, listen: false)
                                .user!
                                .id,
                      ),
                    ),
                  );
                }
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.phone_android),
              title: const Text('Two-Factor Authentication'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to 2FA setup
                showSnackBar(
                  context,
                  '2FA setup will be implemented soon!',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.deepPurple,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (Provider.of<AuthProvider>(context, listen: false)
                    .user
                    ?.profileImageUrl !=
                null) ...[
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfileImage();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });

        // In a real app, you would upload this image to a server
        // and get back a URL to save to the user's profile
        _uploadProfileImage();
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(
          context,
          'Error picking image: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  void _uploadProfileImage() {
    // For demo purposes, we'll just show a success message
    // In a real app, you would upload the image to a server and get a URL back

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Update the user profile with the new image URL
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentUser = authProvider.user;

        if (currentUser != null) {
          // In a real app, you would get this URL from your server after uploading
          const newImageUrl = 'https://example.com/profile_image.jpg';

          final updatedUser = currentUser.copyWith(
            profileImageUrl: newImageUrl,
          );

          authProvider.updateUserProfile(updatedUser);

          showSnackBar(
            context,
            'Profile image updated successfully!',
          );
        }
      }
    });
  }

  void _removeProfileImage() {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _imageFile = null;
        });

        // Update the user profile with null image URL
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentUser = authProvider.user;

        if (currentUser != null) {
          final updatedUser = currentUser.copyWith(
            profileImageUrl: null,
          );

          authProvider.updateUserProfile(updatedUser);

          showSnackBar(
            context,
            'Profile image removed successfully!',
          );
        }
      }
    });
  }

  void _saveProfile(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user;

      if (currentUser == null) {
        throw Exception('User not found');
      }

      // Create updated user object
      final updatedUser = User(
        id: currentUser.id,
        email: currentUser.email,
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        gender: _selectedGender,
        birthDate: _selectedBirthDate,
        profileImageUrl: currentUser.profileImageUrl,
        photoUrl: currentUser.photoUrl,
        loyaltyPoints: currentUser.loyaltyPoints,
        favoriteProductIds: currentUser.favoriteProductIds,
        isBiometricEnabled: currentUser.isBiometricEnabled,
      );

      // Update user in provider
      authProvider.updateUserProfile(updatedUser);

      if (mounted) {
        showSnackBar(
          context,
          'Profile updated successfully!',
        );

        // Navigate back
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(
          context,
          'Failed to update profile: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement delete account functionality
              showSnackBar(
                context,
                'Delete account functionality will be implemented soon!',
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

void showSnackBar(BuildContext context, String message,
    {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 3),
    ),
  );
}
