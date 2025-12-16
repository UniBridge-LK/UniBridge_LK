import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:chat_with_aks/views/home_view.dart';
import 'package:chat_with_aks/views/people_view.dart';
import 'package:chat_with_aks/views/events_view.dart';
import 'package:chat_with_aks/views/chats_view.dart';
import 'package:chat_with_aks/views/profile_view.dart';
import 'package:get/get.dart';
import 'package:chat_with_aks/controllers/main_controller.dart';

class MainView extends GetView<MainController> {
	const MainView({super.key});

	@override
	Widget build(BuildContext context) {
		final pages = [
			const HomeView(),
			const PeopleView(),
			const ChatsView(),
			const EventsView(),
			const ProfileView(),
		];

		return Obx(() {
			final idx = controller.index.value;
			return Scaffold(
				body: IndexedStack(
					index: idx,
					children: pages,
				),
				bottomNavigationBar: BottomNavigationBar(
					currentIndex: idx,
					onTap: (i) => controller.setIndex(i),
					type: BottomNavigationBarType.fixed,
					selectedItemColor: AppTheme.primaryColor,
					unselectedItemColor: Colors.grey[600],
						items: const [
							BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
							BottomNavigationBarItem(icon: Icon(Icons.people), label: 'People'),
							  BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
							BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
							BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
						],
				),
			);
		});
	}
}
