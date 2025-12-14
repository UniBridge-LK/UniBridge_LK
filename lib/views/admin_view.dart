import 'package:chat_with_aks/controllers/auth_controller.dart';
import 'package:chat_with_aks/services/firestore_service.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();
  
  final _universityController = TextEditingController();
  final _facultyController = TextEditingController();
  final _departmentController = TextEditingController();
  
  // For selecting existing universities and faculties
  String? _selectedUniversityId;
  String? _selectedFacultyId;
  List<Map<String, dynamic>> _universities = [];
  List<Map<String, dynamic>> _faculties = [];
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUniversities();
  }

  @override
  void dispose() {
    _universityController.dispose();
    _facultyController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _loadUniversities() async {
    try {
      final unis = await _firestoreService.getUniversities();
      setState(() {
        _universities = unis;
      });
    } catch (e) {
      print('Error loading universities: $e');
    }
  }

  Future<void> _loadFaculties(String universityId) async {
    try {
      final facs = await _firestoreService.getFacultiesByUniversity(universityId);
      setState(() {
        _faculties = facs;
        _selectedFacultyId = null; // Reset faculty selection
      });
    } catch (e) {
      print('Error loading faculties: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _authController.signOut();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage Academic Data',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add universities, faculties, and departments',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 32),
            
            // Add University Section
            _buildSectionCard(
              context,
              title: 'Add University',
              icon: Icons.school,
              children: [
                TextField(
                  controller: _universityController,
                  decoration: InputDecoration(
                    labelText: 'University Name',
                    hintText: 'Enter university name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.school_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _addUniversity,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add),
                    label: const Text('Add University'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Add Faculty Section
            _buildSectionCard(
              context,
              title: 'Add Faculty',
              icon: Icons.category,
              children: [
                Text(
                  'Select a university to add faculties to it',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedUniversityId,
                  items: _universities
                      .map<DropdownMenuItem<String>>((uni) => DropdownMenuItem<String>(
                        value: uni['id'] as String,
                        child: Text(uni['name'] ?? 'Unknown'),
                      ))
                      .toList(),
                  decoration: InputDecoration(
                    labelText: 'Select University',
                    prefixIcon: const Icon(Icons.school_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (universityId) {
                    setState(() {
                      _selectedUniversityId = universityId;
                    });
                    if (universityId != null) {
                      _loadFaculties(universityId);
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a university';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _facultyController,
                  decoration: InputDecoration(
                    labelText: 'Faculty Name',
                    hintText: 'Enter faculty name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.category_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _addFaculty,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add),
                    label: const Text('Add Faculty'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Add Department Section
            _buildSectionCard(
              context,
              title: 'Add Department',
              icon: Icons.apartment,
              children: [
                Text(
                  'Select university and faculty to add departments',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedUniversityId,
                  items: _universities
                      .map<DropdownMenuItem<String>>((uni) => DropdownMenuItem<String>(
                        value: uni['id'] as String,
                        child: Text(uni['name'] ?? 'Unknown'),
                      ))
                      .toList(),
                  decoration: InputDecoration(
                    labelText: 'Select University',
                    prefixIcon: const Icon(Icons.school_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (universityId) {
                    setState(() {
                      _selectedUniversityId = universityId;
                    });
                    if (universityId != null) {
                      _loadFaculties(universityId);
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a university';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedFacultyId,
                  items: _faculties
                      .map<DropdownMenuItem<String>>((fac) => DropdownMenuItem<String>(
                        value: fac['id'] as String,
                        child: Text(fac['name'] ?? 'Unknown'),
                      ))
                      .toList(),
                  decoration: InputDecoration(
                    labelText: 'Select Faculty',
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (facultyId) {
                    setState(() {
                      _selectedFacultyId = facultyId;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a faculty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _departmentController,
                  decoration: InputDecoration(
                    labelText: 'Department Name',
                    hintText: 'Enter department name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.apartment_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _addDepartment,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add),
                    label: const Text('Add Department'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Future<void> _addUniversity() async {
    final name = _universityController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Error', 'Please enter university name');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final universityId = await _firestoreService.addUniversity(name);
      // Refresh list and preselect the newly added university
      await _loadUniversities();
      setState(() {
        _selectedUniversityId = universityId;
      });
      Get.snackbar(
        'Success',
        'University "$name" added successfully!\nID: $universityId',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
      _universityController.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add university: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addFaculty() async {
    final name = _facultyController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Error', 'Please enter faculty name');
      return;
    }
    if (_selectedUniversityId == null || _selectedUniversityId!.isEmpty) {
      Get.snackbar('Error', 'Please select a university');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final facultyId = await _firestoreService.addFaculty(name, _selectedUniversityId!);
      _loadUniversities(); // Reload universities to refresh faculty counts
      Get.snackbar(
        'Success',
        'Faculty "$name" added successfully!\nID: $facultyId',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
      _facultyController.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add faculty: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addDepartment() async {
    final name = _departmentController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Error', 'Please enter department name');
      return;
    }
    if (_selectedFacultyId == null || _selectedFacultyId!.isEmpty) {
      Get.snackbar('Error', 'Please select a faculty');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _firestoreService.addDepartment(name, _selectedFacultyId!);
      if (_selectedUniversityId != null) {
        _loadFaculties(_selectedUniversityId!); // Reload faculties to refresh department counts
      }
      Get.snackbar(
        'Success',
        'Department "$name" added successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      _departmentController.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add department: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
