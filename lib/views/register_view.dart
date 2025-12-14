import 'package:chat_with_aks/controllers/auth_controller.dart';
import 'package:chat_with_aks/routes/app_routes.dart';
import 'package:chat_with_aks/services/firestore_service.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';

enum UserRole {
  schoolStudent,
  undergraduate,
  academicStaff,
  institution,
  other,
}

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
  
  // Controllers for custom "Others" input
  final _customUniversityController = TextEditingController();
  final _customFacultyController = TextEditingController();
  final _customDepartmentController = TextEditingController();

  final AuthController _authController = Get.find<AuthController>();
  final FirestoreService _firestoreService = FirestoreService();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _currentStep = 0; // 0: Account Info, 1: Academic Details (conditional)
  UserRole? _selectedRole;
  
  // Dropdown data
  List<Map<String, dynamic>> _universities = [];
  List<Map<String, dynamic>> _faculties = [];
  List<Map<String, dynamic>> _departments = [];
  
  // Selected values
  String? _selectedUniversityId;
  String? _selectedFacultyId;
  String? _selectedDepartmentId;
  
  // "Others" flags
  bool _isUniversityOthers = false;
  bool _isFacultyOthers = false;
  bool _isDepartmentOthers = false;
  
  // Loading state
  bool _isLoadingUniversities = true;
  
  @override
  void initState() {
    super.initState();
    _loadUniversities();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    _customUniversityController.dispose();
    _customFacultyController.dispose();
    _customDepartmentController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUniversities() async {
    print('=== Starting to load universities ===');
    setState(() {
      _isLoadingUniversities = true;
    });
    try {
      final unis = await _firestoreService.getUniversities();
      print('=== Loaded ${unis.length} universities ===');
      if (unis.isEmpty) {
        print('WARNING: No universities found in Firestore!');
        print('Please add universities through the Admin page first.');
      } else {
        for (var uni in unis) {
          print('University: id=${uni['id']}, name=${uni['name']}');
        }
      }
      setState(() {
        _universities = unis;
        _isLoadingUniversities = false;
      });
    } catch (e) {
      print('=== ERROR loading universities: $e ===');
      setState(() {
        _isLoadingUniversities = false;
      });
    }
  }
  
  Future<void> _loadFaculties(String universityId) async {
    try {
      final facs = await _firestoreService.getFacultiesByUniversity(universityId);
      print('Loaded ${facs.length} faculties for university $universityId: $facs');
      setState(() {
        _faculties = facs;
        _selectedFacultyId = null;
        _departments = [];
        _selectedDepartmentId = null;
      });
    } catch (e) {
      print('Error loading faculties: $e');
    }
  }
  
  Future<void> _loadDepartments(String facultyId) async {
    try {
      final depts = await _firestoreService.getDepartmentsByFaculty(facultyId);
      print('Loaded ${depts.length} departments for faculty $facultyId: $depts');
      setState(() {
        _departments = depts;
        _selectedDepartmentId = null;
      });
    } catch (e) {
      print('Error loading departments: $e');
    }
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
                _buildAcademicDetailsStep(context),
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
                            : Text(_primaryButtonLabel()),
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

  bool get _requiresAcademicDetails =>
      _selectedRole == UserRole.undergraduate || _selectedRole == UserRole.academicStaff;

  int get _totalSteps => _requiresAcademicDetails ? 2 : 1;

  String _primaryButtonLabel() {
    if (_currentStep == 0 && _requiresAcademicDetails) return 'Next';
    return 'Register';
  }

  String _getStepTitle() {
    if (_currentStep == 0) {
      return 'Step 1 of $_totalSteps: Create your account';
    }
    return 'Step 2 of $_totalSteps: Academic details';
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.schoolStudent:
        return 'School Student';
      case UserRole.undergraduate:
        return 'Undergraduates';
      case UserRole.academicStaff:
        return 'Academic Staff';
      case UserRole.institution:
        return 'Institutions / Organizations';
      case UserRole.other:
        return 'Others';
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
        SizedBox(height: 16),
        DropdownButtonFormField<UserRole>(
          initialValue: _selectedRole,
          items: UserRole.values
              .map(
                (role) => DropdownMenuItem(
                  value: role,
                  child: Text(_roleLabel(role)),
                ),
              )
              .toList(),
          decoration: InputDecoration(
            labelText: 'Select Role',
            prefixIcon: Icon(Icons.assignment_ind_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (role) {
            setState(() {
              _selectedRole = role;
              _currentStep = 0; // Keep on first step when role changes
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a role';
            }
            return null;
          },
        ),
      ],
    );
  }
  Widget _buildAcademicDetailsStep(BuildContext context) {
    return Column(
      children: [
        Text("Provide your academic details.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        SizedBox(height: 24),
        
        // University Dropdown
        _isLoadingUniversities
          ? TextFormField(
              enabled: false,
              decoration: InputDecoration(
                labelText: 'University',
                hintText: 'Loading universities...',
                prefixIcon: SizedBox(
                  width: 20,
                  height: 20,
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : DropdownButtonFormField<String>(
          initialValue: _selectedUniversityId,
          isExpanded: true,
          items: [
            ..._universities.map<DropdownMenuItem<String>>((uni) => DropdownMenuItem<String>(
              value: uni['id'] as String,
              child: Text(
                uni['name'] ?? 'Unknown',
                overflow: TextOverflow.ellipsis,
              ),
            )),
            DropdownMenuItem<String>(
              value: 'others',
              child: Text('Others'),
            ),
          ],
          decoration: InputDecoration(
            labelText: 'University',
            hintText: 'Select your university',
            prefixIcon: Icon(Icons.school_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _selectedUniversityId = value;
              _isUniversityOthers = value == 'others';
              if (value != null && value != 'others') {
                _loadFaculties(value);
              } else {
                _faculties = [];
                _selectedFacultyId = null;
                _departments = [];
                _selectedDepartmentId = null;
              }
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a university';
            }
            return null;
          },
        ),
        
        // Custom University TextField (shown when \"Others\" selected)
        if (_isUniversityOthers) ...[
          SizedBox(height: 16),
          TextFormField(
            controller: _customUniversityController,
            decoration: InputDecoration(
              labelText: 'Enter University Name',
              hintText: 'Type your university name',
              prefixIcon: Icon(Icons.edit),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (_isUniversityOthers && (value == null || value.isEmpty)) {
                return 'Please enter your university name';
              }
              return null;
            },
          ),
        ],
        
        SizedBox(height: 16),
        
        // Faculty Dropdown
        DropdownButtonFormField<String>(
          initialValue: _selectedFacultyId,
          isExpanded: true,
          items: [
            ..._faculties.map<DropdownMenuItem<String>>((fac) => DropdownMenuItem<String>(
              value: fac['id'] as String,
              child: Text(
                fac['name'] ?? 'Unknown',
                overflow: TextOverflow.ellipsis,
              ),
            )),
            DropdownMenuItem<String>(
              value: 'others',
              child: Text('Others'),
            ),
          ],
          decoration: InputDecoration(
            labelText: 'Faculty',
            prefixIcon: Icon(Icons.category_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _selectedFacultyId = value;
              _isFacultyOthers = value == 'others';
              if (value != null && value != 'others') {
                _loadDepartments(value);
              } else {
                _departments = [];
                _selectedDepartmentId = null;
              }
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a faculty';
            }
            return null;
          },
        ),
        
        // Custom Faculty TextField (shown when \"Others\" selected)
        if (_isFacultyOthers) ...[
          SizedBox(height: 16),
          TextFormField(
            controller: _customFacultyController,
            decoration: InputDecoration(
              labelText: 'Enter Faculty Name',
              hintText: 'Type your faculty name',
              prefixIcon: Icon(Icons.edit),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (_isFacultyOthers && (value == null || value.isEmpty)) {
                return 'Please enter your faculty name';
              }
              return null;
            },
          ),
        ],
        
        SizedBox(height: 16),
        
        // Department Dropdown
        DropdownButtonFormField<String>(
          initialValue: _selectedDepartmentId,
          isExpanded: true,
          items: [
            ..._departments.map<DropdownMenuItem<String>>((dept) => DropdownMenuItem<String>(
              value: dept['id'] as String,
              child: Text(
                dept['name'] ?? 'Unknown',
                overflow: TextOverflow.ellipsis,
              ),
            )),
            DropdownMenuItem<String>(
              value: 'others',
              child: Text('Others'),
            ),
          ],
          decoration: InputDecoration(
            labelText: 'Department',
            prefixIcon: Icon(Icons.apartment_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _selectedDepartmentId = value;
              _isDepartmentOthers = value == 'others';
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a department';
            }
            return null;
          },
        ),
        
        // Custom Department TextField (shown when \"Others\" selected)
        if (_isDepartmentOthers) ...[
          SizedBox(height: 16),
          TextFormField(
            controller: _customDepartmentController,
            decoration: InputDecoration(
              labelText: 'Enter Department Name',
              hintText: 'Type your department name',
              prefixIcon: Icon(Icons.edit),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (_isDepartmentOthers && (value == null || value.isEmpty)) {
                return 'Please enter your department name';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  void _handleNextOrRegister() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_currentStep == 0 && _requiresAcademicDetails) {
      setState(() {
        _currentStep = 1;
      });
      return;
    }

    _register();
  }

  void _register() {
    // Get university, faculty, and department values (either from selection or custom input)
    String universityValue = '';
    String facultyValue = '';
    String departmentValue = '';
    
    if (_requiresAcademicDetails) {
      // University
      if (_isUniversityOthers) {
        universityValue = _customUniversityController.text.trim();
      } else if (_selectedUniversityId != null) {
        final selectedUni = _universities.firstWhere(
          (uni) => uni['id'] == _selectedUniversityId,
          orElse: () => {'name': ''},
        );
        universityValue = selectedUni['name'] ?? '';
      }
      
      // Faculty
      if (_isFacultyOthers) {
        facultyValue = _customFacultyController.text.trim();
      } else if (_selectedFacultyId != null) {
        final selectedFac = _faculties.firstWhere(
          (fac) => fac['id'] == _selectedFacultyId,
          orElse: () => {'name': ''},
        );
        facultyValue = selectedFac['name'] ?? '';
      }
      
      // Department
      if (_isDepartmentOthers) {
        departmentValue = _customDepartmentController.text.trim();
      } else if (_selectedDepartmentId != null) {
        final selectedDept = _departments.firstWhere(
          (dept) => dept['id'] == _selectedDepartmentId,
          orElse: () => {'name': ''},
        );
        departmentValue = selectedDept['name'] ?? '';
      }
    }
    
    _authController.registerWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text,
      _displayNameController.text,
      accountType: _selectedRole != null ? _roleLabel(_selectedRole!) : '',
      universityName: universityValue,
      faculty: facultyValue,
      department: departmentValue,
      organizationName: '',
    );
  }
}