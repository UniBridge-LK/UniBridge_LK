import 'package:chat_with_aks/controllers/auth_controller.dart';
import 'package:chat_with_aks/routes/app_routes.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';

enum AccountType { individual, organization }

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _universityController = TextEditingController();
  final _facultyController = TextEditingController();
  final _departmentController = TextEditingController();
  final _organizationNameController = TextEditingController();

  final AuthController _authController = Get.find<AuthController>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _currentStep = 0; // 0: Account Info, 1: Account Type, 2: Type Details
  AccountType? _selectedAccountType;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    _universityController.dispose();
    _facultyController.dispose();
    _departmentController.dispose();
    _organizationNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Row(children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    if (_currentStep > 0) {
                      setState(() {
                        _currentStep--;
                      });
                    } else {
                      Get.back();
                    }
                  },
                ),
                SizedBox(width: 8),
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
              ),
              SizedBox(height: 8),
              // Step indicator
              Text(
                _getStepTitle(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              SizedBox(height: 24),
              
              // Step content
              if (_currentStep == 0) ...[
                _buildAccountInfoStep(context),
              ] else if (_currentStep == 1) ...[
                _buildAccountTypeStep(context),
              ] else if (_currentStep == 2) ...[
                _buildTypeDetailsStep(context),
              ],

              SizedBox(height: 24),
              // Navigation buttons
              Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _currentStep--;
                          });
                        },
                        child: Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) SizedBox(width: 16),
                  Expanded(
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: _authController.isLoading ? null : _handleNextOrRegister,
                        child: _authController.isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_currentStep < 2 ? 'Next' : 'Register'),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // OR with line on each side
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Divider(color: AppTheme.borderColor)),
                  Padding(padding:  EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppTheme.borderColor)),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? '),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.login),
                    child: Text('Sign In',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Step 1 of 3: Create your account';
      case 1:
        return 'Step 2 of 3: Select your account type';
      case 2:
        return 'Step 3 of 3: Complete your profile';
      default:
        return '';
    }
  }

  Widget _buildAccountInfoStep(BuildContext context) {
    return Column(
      children: [
        Text("Create a secure account with your email, password, and display name.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        SizedBox(height: 24),
        TextFormField(
          controller: _displayNameController,
          decoration: InputDecoration(
            labelText: 'Display Name',
            hintText: 'Enter your full name',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your display name';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email address',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!GetUtils.isEmail(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            hintText: 'Re-enter your password',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAccountTypeStep(BuildContext context) {
    return Column(
      children: [
        Text("What type of account are you creating?",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        SizedBox(height: 24),
        _buildAccountTypeOption(
          context,
          AccountType.individual,
          'Individual',
          'Student or individual account',
          Icons.person,
        ),
        SizedBox(height: 16),
        _buildAccountTypeOption(
          context,
          AccountType.organization,
          'Organization',
          'Company or institution account',
          Icons.business,
        ),
      ],
    );
  }

  Widget _buildAccountTypeOption(
    BuildContext context,
    AccountType type,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedAccountType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAccountType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSelected ? AppTheme.primaryColor : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeDetailsStep(BuildContext context) {
    if (_selectedAccountType == AccountType.individual) {
      return Column(
        children: [
          Text("Complete your educational profile.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          SizedBox(height: 24),
          TextFormField(
            controller: _universityController,
            decoration: InputDecoration(
              labelText: 'University Name',
              hintText: 'Enter your university',
              prefixIcon: Icon(Icons.school_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your university name';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _facultyController,
            decoration: InputDecoration(
              labelText: 'Faculty',
              hintText: 'Enter your faculty',
              prefixIcon: Icon(Icons.category_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your faculty';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _departmentController,
            decoration: InputDecoration(
              labelText: 'Department',
              hintText: 'Enter your department',
              prefixIcon: Icon(Icons.apartment_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your department';
              }
              return null;
            },
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Text("Complete your organization profile.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          SizedBox(height: 24),
          TextFormField(
            controller: _organizationNameController,
            decoration: InputDecoration(
              labelText: 'Organization Name',
              hintText: 'Enter your organization name',
              prefixIcon: Icon(Icons.business_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your organization name';
              }
              return null;
            },
          ),
        ],
      );
    }
  }

  void _handleNextOrRegister() {
    // Validate current step
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Validate step-specific conditions
    if (_currentStep == 1 && _selectedAccountType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an account type')),
      );
      return;
    }

    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Register
      _authController.registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
        _displayNameController.text,
        accountType: _selectedAccountType?.name ?? '',
        universityName: _selectedAccountType == AccountType.individual ? _universityController.text.trim() : '',
        faculty: _selectedAccountType == AccountType.individual ? _facultyController.text.trim() : '',
        department: _selectedAccountType == AccountType.individual ? _departmentController.text.trim() : '',
        organizationName: _selectedAccountType == AccountType.organization ? _organizationNameController.text.trim() : '',
      );
    }
  }
}