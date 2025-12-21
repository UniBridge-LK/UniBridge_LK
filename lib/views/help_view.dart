import 'package:flutter/material.dart';
import 'package:unibridge_lk/theme/app_theme.dart';

class HelpView extends StatefulWidget {
  const HelpView({super.key});

  @override
  State<HelpView> createState() => _HelpViewState();
}

class _HelpViewState extends State<HelpView> {
  final List<HelpCategory> categories = [
    HelpCategory(
      title: 'Getting Started',
      icon: Icons.start,
      items: [
        HelpItem(
          question: 'How do I create an account?',
          answer:
              '1. Open the app and tap "Sign Up"\n2. Enter your email\n3. Receive and enter the OTP\n4. Fill in your profile details\n5. Select your university, faculty, and department\n6. Tap "Create Account"',
        ),
        HelpItem(
          question: 'How do I verify my email?',
          answer:
              'We send an OTP (One-Time Password) to your email. Enter it when prompted during signup to verify your account.',
        ),
        HelpItem(
          question: 'I forgot my password. What should I do?',
          answer:
              'Use the "Forgot Password" link on the login screen. We\'ll send you a password reset link via email.',
        ),
      ],
    ),
    HelpCategory(
      title: 'Messaging',
      icon: Icons.message,
      items: [
        HelpItem(
          question: 'How do I send a message?',
          answer:
              '1. Tap on a contact in your chats\n2. Type your message in the text field\n3. Press the send button (arrow icon)',
        ),
        HelpItem(
          question: 'Can I edit a message after sending?',
          answer:
              'Yes! Long-press on your message and select "Edit". You can modify the text. Edited messages show an "edited" tag.',
        ),
        HelpItem(
          question: 'How do I delete a message?',
          answer:
              'Long-press on your message and select "Delete". The message will be replaced with "Message deleted". This cannot be undone.',
        ),
        HelpItem(
          question: 'Can I see when someone last messaged?',
          answer:
              'Yes, timestamps appear next to each message showing the time it was sent (in 12-hour format).',
        ),
      ],
    ),
    HelpCategory(
      title: 'Connections',
      icon: Icons.people,
      items: [
        HelpItem(
          question: 'How do I find other users?',
          answer:
              '1. Go to the "People" tab\n2. Browse users from your university\n3. Tap on a profile to view their details\n4. Tap "Send Request" to connect',
        ),
        HelpItem(
          question: 'What does "Pending" mean?',
          answer:
              'Your friend request is waiting for them to accept. You can cancel the request and try again later.',
        ),
        HelpItem(
          question: 'How do I manage my connections?',
          answer:
              'Go to your profile settings. You can view your connections, pending requests, and blocked users. You can remove connections or unblock users from there.',
        ),
      ],
    ),
    HelpCategory(
      title: 'Events & Forums',
      icon: Icons.event,
      items: [
        HelpItem(
          question: 'How do I find events?',
          answer:
              '1. Go to the "Events" tab\n2. Browse events by university or date\n3. Tap on an event to see details\n4. Tap "Attend" to join',
        ),
        HelpItem(
          question: 'How do I join a forum?',
          answer:
              '1. Go to the "Forum" tab\n2. Select your university or faculty\n3. Choose a topic\n4. Read discussions or start a new one',
        ),
        HelpItem(
          question: 'Can I create my own event?',
          answer:
              'Yes! Go to the Events tab and tap the + button to create an event. Fill in the details and publish it for others to discover.',
        ),
      ],
    ),
    HelpCategory(
      title: 'Search & Discovery',
      icon: Icons.search,
      items: [
        HelpItem(
          question: 'How do I search for something?',
          answer:
              'Use the search field in each section (People, Forums, Events). Type what you\'re looking for and results filter automatically.',
        ),
        HelpItem(
          question: 'Can I filter by university or faculty?',
          answer:
              'Yes! When browsing users or events, you can select your university and faculty to narrow down results.',
        ),
      ],
    ),
    HelpCategory(
      title: 'Troubleshooting',
      icon: Icons.build,
      items: [
        HelpItem(
          question: 'App is crashing or freezing',
          answer:
              '• Try restarting the app\n• Clear the app cache (Settings > Apps > UniBridge LK > Clear Cache)\n• Ensure you have the latest app version\n• Try reinstalling if problems persist',
        ),
        HelpItem(
          question: 'Messages not sending',
          answer:
              '• Check your internet connection\n• Verify WiFi or mobile data is enabled\n• Try sending again\n• Restart the app if needed',
        ),
        HelpItem(
          question: 'I\'m not receiving friend requests',
          answer:
              '• Ensure notifications are enabled in app settings\n• Check your spam filter\n• Try refreshing the app\n• Contact support if the problem persists',
        ),
      ],
    ),
  ];

  int _expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              color: AppTheme.primaryColor.withOpacity(0.1),
              child: Column(
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 48,
                    color: AppTheme.primaryColor,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Need Help?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Find answers to common questions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Categories
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (context, catIndex) {
                return _buildCategory(catIndex);
              },
            ),
            // Contact Support
            Padding(
              padding: EdgeInsets.all(20),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.mail_outline,
                        size: 32,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Still Need Help?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Contact our support team',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Email: support@unibridgelk.com')),
                          );
                        },
                        icon: Icon(Icons.email),
                        label: Text('Email Support'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(int catIndex) {
    final category = categories[catIndex];
    final isExpanded = _expandedIndex == catIndex;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                category.icon,
                color: AppTheme.primaryColor,
              ),
              title: Text(
                category.title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
              ),
              onTap: () {
                setState(() {
                  _expandedIndex = isExpanded ? -1 : catIndex;
                });
              },
            ),
            if (isExpanded)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: category.items.length,
                itemBuilder: (context, itemIndex) {
                  return _buildHelpItem(category.items[itemIndex]);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(HelpItem item) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.question,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            item.answer,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12),
            child: Divider(),
          ),
        ],
      ),
    );
  }
}

class HelpCategory {
  final String title;
  final IconData icon;
  final List<HelpItem> items;

  HelpCategory({
    required this.title,
    required this.icon,
    required this.items,
  });
}

class HelpItem {
  final String question;
  final String answer;

  HelpItem({
    required this.question,
    required this.answer,
  });
}
