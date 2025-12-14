import 'package:chat_with_aks/controllers/profile_controller.dart';
import 'package:chat_with_aks/views/admin_view.dart';
import 'package:chat_with_aks/views/change_password_view.dart';
import 'package:chat_with_aks/views/forgot_password_view.dart';
import 'package:chat_with_aks/views/login_view.dart';
import 'package:chat_with_aks/views/profile_view.dart';
import 'package:chat_with_aks/views/register_view.dart';
import 'package:chat_with_aks/views/verify_otp_view.dart';
import 'package:chat_with_aks/views/splash_view.dart';
import 'package:chat_with_aks/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:chat_with_aks/controllers/home_controller.dart';
import 'package:chat_with_aks/controllers/forum_controller.dart';
import 'package:chat_with_aks/views/home_view.dart';
import 'package:chat_with_aks/views/forum_view.dart';
import 'package:chat_with_aks/views/people_view.dart';
import 'package:chat_with_aks/views/events_view.dart';
import 'package:chat_with_aks/views/chats_view.dart';
import 'package:chat_with_aks/views/main_view.dart';
import 'package:chat_with_aks/controllers/main_controller.dart';
import 'package:chat_with_aks/views/home_hierarchy/university_view.dart';
import 'package:chat_with_aks/views/home_hierarchy/faculty_view.dart';
import 'package:chat_with_aks/views/home_hierarchy/department_view.dart';



class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView()),
    GetPage(name: AppRoutes.login, page: () => const LoginView()),
    GetPage(name: AppRoutes.register, page: () => const RegisterView()),
    GetPage(name: AppRoutes.forgotPassword, page: () => const ForgotPasswordView()),
    GetPage(name: AppRoutes.changePassword, page: () => const ChangePasswordView()),
    GetPage(name: AppRoutes.verifyOtp, page: () => const VerifyOtpView()),
    GetPage(name: AppRoutes.admin, page: () => const AdminView()),
    // GetPage(
    //   name: AppRoutes.home, 
    //   page: () => const HomeView(),
    //   binding: BindingsBuilder(() {
    //     // Dependency injections for HomeView
    //     Get.put(HomeController());
    //   })
    //   ),
    // GetPage(
    //   name:AppRoutes.main, 
    //   page: () => const MainView(),
    //   binding: BindingsBuilder(() {
    //     // Dependency injections for MainView
    //     Get.put(MainController());
    //   })
    //   ),
    GetPage(
      name: AppRoutes.home, 
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        // Dependency injections for HomeView
        Get.put(HomeController());
      })
      ),
    GetPage(
      name: '/home/university',
      page: () => UniversityView(uniName: Get.arguments['uni'], faculties: Map<String, List<String>>.from(Get.arguments['faculties'] ?? {})),
    ),
    GetPage(
      name: '/home/university/faculty',
      page: () => FacultyView(),
    ),
    GetPage(
      name: '/home/university/faculty/department',
      page: () => DepartmentView(),
    ),
    GetPage(
      name: AppRoutes.forum,
      page: () => const ForumView(),
      binding: BindingsBuilder(() {
        Get.put(ForumController());
      }),
    ),
    GetPage(name: AppRoutes.usersList, page: () => const PeopleView()),
    GetPage(name: AppRoutes.chat, page: () => const ChatsView()),
    GetPage(name: AppRoutes.notifications, page: () => const EventsView()),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainView(),
      binding: BindingsBuilder(() {
        Get.put(MainController());
        // Ensure HomeController is available for the HomeView inside MainView
        Get.put(HomeController());
      }),
    ),
    GetPage(
      name: AppRoutes.profile, 
      page: () => ProfileView(),
      binding: BindingsBuilder(() {
        // Dependency injections for ProfileView
        Get.put(ProfileController());
      })
      ),
    // GetPage(
    //   name: AppRoutes.chat, 
    //   page: () => const ChatView(),
    //   binding: BindingsBuilder(() {
    //     // Dependency injections for ChatView
    //     Get.put(ChatController());
    //   })
    //   ),
    // GetPage(
    //   name: AppRoutes.usersList, 
    //   page: () => const UsersListView(),
    //   binding: BindingsBuilder(() {
    //     // Dependency injections for UsersListView
    //     Get.put(UsersListController());
    //   })
    //   ),
    // GetPage(
    //   name: AppRoutes.friends, 
    //   page: () => const FriendsView(),
    //   binding: BindingsBuilder(() {
    //     // Dependency injections for FriendsView
    //     Get.put(FriendsController());
    //   })
    //   ),
    // GetPage(
    //   name: AppRoutes.friendRequests, 
    //   page: () => const FriendRequestsView(),
    //   binding: BindingsBuilder(() {
    //     // Dependency injections for FriendRequestsView
    //     Get.put(FriendRequestsController());
    //   })
    //   ),
    // GetPage(
    //   name: AppRoutes.notifications, 
    //   page: () => const NotificationsView(),
    //   binding: BindingsBuilder(() {
    //     // Dependency injections for NotificationsView
    //     Get.put(NotificationsController());
    //   })
    //   ),
    // Add other routes here
  ];
}