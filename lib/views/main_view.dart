import 'package:unibridge_lk/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:unibridge_lk/views/home_view.dart';
import 'package:unibridge_lk/views/people_view.dart';
import 'package:unibridge_lk/views/events_view.dart';
import 'package:unibridge_lk/views/chats_view.dart';
import 'package:unibridge_lk/views/profile_view.dart';
import 'package:get/get.dart';
import 'package:unibridge_lk/controllers/main_controller.dart';

class MainView extends GetView<MainController> {
	const MainView({super.key});

	@override
	Widget build(BuildContext context) {
		final pages = [
			const HomeView(),
			const PeopleView(),
			const ChatsView(),
			const EventsView(),
			ProfileView(),
		];

		return Obx(() {
			final idx = controller.index.value;
			return Scaffold(
				body: pages[idx],
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
