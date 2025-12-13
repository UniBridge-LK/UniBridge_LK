
import 'package:chat_with_aks/controllers/profile_controller.dart';
import 'package:chat_with_aks/routes/app_routes.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:get/route_manager.dart';

class ProfileView extends  GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => TextButton(
                onPressed: controller.toggleEditing,
                child: Text(
                  controller.isEditing ? 'Cancel' : 'Edit',
                  style: TextStyle(
                    color: controller.isEditing ? AppTheme.errorColor : AppTheme.primaryColor,
                  ),
                ),
              )),
        ],
      ),
      body: Obx((){
        final user = controller.currentUser;
        if(user == null){
          return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor,));
        }
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Column(children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppTheme.primaryColor,
                    child: user.photoURL.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              user.photoURL,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultAvatar(user);
                              },
                            ),
                          )
                        : _buildDefaultAvatar(user),
                  ),
                  if (controller.isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: IconButton(                          
                          onPressed: (){
                            Get.snackbar('Info', 'Photo update coming soon!');
                          }, icon: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                        ),
                      )
                    )
                    ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                user.displayName,
                style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                user.email,
                style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),              
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: user.isOnline ? AppTheme.successColor.withOpacity(0.1) : AppTheme.textSecondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: user.isOnline ? AppTheme.successColor : AppTheme.textSecondaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      user.isOnline ? 'Online' : 'Offline',
                      style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                        color: user.isOnline ? AppTheme.successColor : AppTheme.textSecondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(controller.getJoinedDate(),
                style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),

            ],
            ),
            SizedBox(height: 32),
            Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Personal Information",
                      style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),                      
                    ),
                    SizedBox(height: 20),
                    Obx(() {
                      if (controller.isEditing) {
                        return TextFormField(
                          key: const ValueKey('displayName_edit'),
                          controller: controller.displayNameController,
                          enabled: true,
                          decoration: InputDecoration(
                            labelText: 'Display Name',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                        );
                      } else {
                        return TextFormField(
                          key: ValueKey('displayName_view_${user.displayName}'),
                          initialValue: user.displayName,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: 'Display Name',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                        );
                      }
                    }),
                    SizedBox(height: 16),
                    TextFormField(
                      key: ValueKey('email_${user.email}'),
                      initialValue: user.email,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                        helperText: 'Email cannot be changed',
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      key: ValueKey('accountType_${user.accountType}'),
                      initialValue: user.accountType == 'individual'
                          ? 'Individual'
                          : user.accountType == 'organization'
                              ? 'Organization'
                              : 'Not specified',
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Account Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_circle_outlined),
                      ),
                    ),
                    if (user.accountType == 'individual') ...[
                      SizedBox(height: 12),
                      TextFormField(
                        key: ValueKey('university_${user.universityName}'),
                        initialValue: user.universityName.isNotEmpty ? user.universityName : 'Not provided',
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'University',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.school_outlined),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        key: ValueKey('faculty_${user.faculty}'),
                        initialValue: user.faculty.isNotEmpty ? user.faculty : 'Not provided',
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'Faculty',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        key: ValueKey('department_${user.department}'),
                        initialValue: user.department.isNotEmpty ? user.department : 'Not provided',
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'Department',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.apartment_outlined),
                        ),
                      ),
                    ] else if (user.accountType == 'organization') ...[
                      SizedBox(height: 12),
                      TextFormField(
                        key: ValueKey('organization_${user.organizationName}'),
                        initialValue: user.organizationName.isNotEmpty ? user.organizationName : 'Not provided',
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'Organization Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business_outlined),
                        ),
                      ),
                    ],
                    Obx(() => controller.isEditing ? Column(
                      children: [
                        SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isLoading ? null : controller.updateProfile,
                            child: controller.isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text('Save Changes'),
                          ),
                        ),
                      ],
                    ) : SizedBox.shrink()),
                  SizedBox(height: 16),
                  Column(children: [
                    Card(
                      child: Column(children: [
                        // for change password
                        ListTile(
                          leading: Icon(Icons.security, color: AppTheme.primaryColor,),
                          title: Text('Change Password'),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16,),
                          onTap: () => Get.toNamed(AppRoutes.changePassword),
                        ),
                        Divider(height: 1, color: Colors.grey,),
                        ListTile(
                          leading: Icon(Icons.delete_forever, color: AppTheme.errorColor,),
                          title: Text('Delete Account',),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16,),
                          onTap: controller.deleteAccount,
                        ),
                        Divider(height: 1, color: Colors.grey,),
                        ListTile(
                          leading: Icon(Icons.logout, color: AppTheme.primaryColor,),
                          title: Text('Sign Out', ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16,),
                          onTap: controller.signOut,
                        ),
                        
                      ],),
                    )
                  ],)
                  ],
                  
                  )
                ),

            ),
            SizedBox(height: 32),
            Text("ChatAks v1.0.0", 
            style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            ),

            ],
          ),

        );
      }),
    );
  }

  Widget _buildDefaultAvatar(dynamic user){
    return Text(user.displayName.isNotEmpty
        ? user.displayName[0].toUpperCase()
        : '?',
        style: TextStyle(
          fontSize: 48,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
    );
  }    
  
}