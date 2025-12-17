import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_with_aks/theme/app_theme.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Welcome to UniBridge LK',
      description: 'Connect with students, staff, and alumni across Sri Lankan universities',
      icon: Icons.people,
      color: Color(0xFF6C5CE7),
    ),
    OnboardingPage(
      title: 'Real-Time Messaging',
      description: 'Chat instantly with your connections. Edit, delete, and see read receipts',
      icon: Icons.message,
      color: Color(0xFF00BFA5),
    ),
    OnboardingPage(
      title: 'Discover Events',
      description: 'Find and attend events hosted by universities, faculties, and departments',
      icon: Icons.event,
      color: Color(0xFFFF6B6B),
    ),
    OnboardingPage(
      title: 'Join Forums',
      description: 'Discuss ideas and ask questions in university and faculty forums',
      icon: Icons.forum,
      color: Color(0xFFFFD93D),
    ),
    OnboardingPage(
      title: 'Ready to Connect?',
      description: 'Create your account and start your UniBridge journey today!',
      icon: Icons.login,
      color: Color(0xFF6BCB77),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    Get.back(); // Close onboarding
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page View
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: pages.length,
            itemBuilder: (context, index) {
              return _buildOnboardingPage(pages[index]);
            },
          ),
          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  // Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (index) => Container(
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.primaryColor
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  // Buttons
                  Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: AppTheme.primaryColor),
                            ),
                            child: Text('Back'),
                          ),
                        ),
                      if (_currentPage > 0) SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _goToNextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            _currentPage == pages.length - 1 ? 'Get Started' : 'Next',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Skip Button
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return Container(
      color: page.color.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            page.icon,
            size: 120,
            color: page.color,
          ),
          SizedBox(height: 32),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              page.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
