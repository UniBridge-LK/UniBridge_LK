class SampleForumData {
  // Global Forum Threads
  static const List<Map<String, dynamic>> globalThreads = [
    {
      'title': 'Welcome to UniBridge Forum!',
      'question': 'This is the global forum where you can discuss topics that interest the entire UniBridge community. Feel free to ask questions, share experiences, and connect with students and faculty from all universities.',
      'authorName': 'Admin',
      'authorId': 'admin_001',
      'timestamp': '2025-12-10T08:00:00Z',
      'replies': [
        {
          'content': 'Great initiative! Looking forward to connecting with peers across universities.',
          'authorName': 'Sarah Johnson',
          'authorId': 'user_001',
          'timestamp': '2025-12-10T09:15:00Z',
          'replies': [
            {
              'content': 'Same here! The cross-university perspective is invaluable.',
              'authorName': 'Mike Chen',
              'authorId': 'user_002',
              'timestamp': '2025-12-10T10:30:00Z',
              'replies': []
            }
          ]
        },
        {
          'content': 'Can\'t wait to explore all the opportunities this platform offers.',
          'authorName': 'Emma Wilson',
          'authorId': 'user_003',
          'timestamp': '2025-12-10T11:00:00Z',
          'replies': []
        }
      ]
    },
    {
      'title': 'Best Online Learning Resources for Computer Science',
      'question': 'I\'m looking for high-quality online courses and resources to complement my CS studies. What platforms or courses do you recommend? Specifically interested in algorithms, web development, and AI/ML.',
      'authorName': 'Alex Turner',
      'authorId': 'user_004',
      'timestamp': '2025-12-09T14:30:00Z',
      'replies': [
        {
          'content': 'I highly recommend Coursera and Udemy. Their CS specializations are comprehensive and well-structured.',
          'authorName': 'Lisa Park',
          'authorId': 'user_005',
          'timestamp': '2025-12-09T15:45:00Z',
          'replies': [
            {
              'content': 'Agreed! Coursera\'s algorithms course by Princeton is excellent.',
              'authorName': 'James Bond',
              'authorId': 'user_006',
              'timestamp': '2025-12-09T16:20:00Z',
              'replies': []
            }
          ]
        },
        {
          'content': 'Don\'t forget MIT OpenCourseWare. It\'s free and has incredible content.',
          'authorName': 'Robert Kim',
          'authorId': 'user_007',
          'timestamp': '2025-12-09T16:00:00Z',
          'replies': []
        }
      ]
    },
    {
      'title': 'Internship Tips: Getting Ready for Your First Tech Internship',
      'question': 'I\'m preparing for my first tech internship next summer. What skills should I focus on? Any tips for making a good impression and learning as much as possible?',
      'authorName': 'Jessica Davis',
      'authorId': 'user_008',
      'timestamp': '2025-12-08T10:15:00Z',
      'replies': [
        {
          'content': 'Build a strong portfolio with personal projects. It really helps during interviews.',
          'authorName': 'David Martinez',
          'authorId': 'user_009',
          'timestamp': '2025-12-08T11:30:00Z',
          'replies': []
        },
        {
          'content': 'Ask questions! Interns who show genuine curiosity stand out from the rest.',
          'authorName': 'Nicole Taylor',
          'authorId': 'user_010',
          'timestamp': '2025-12-08T12:00:00Z',
          'replies': [
            {
              'content': 'Absolutely. And document what you learn for future reference.',
              'authorName': 'Thomas Anderson',
              'authorId': 'user_011',
              'timestamp': '2025-12-08T13:15:00Z',
              'replies': []
            }
          ]
        }
      ]
    },
  ];

  // University Level Threads (example: Tech University)
  static const List<Map<String, dynamic>> universityThreads = [
    {
      'title': 'Spring Semester 2026 Course Registration Open',
      'question': 'Registration for Spring 2026 courses is now open! Make sure to register early for popular courses. This thread is for discussing course recommendations and registration tips.',
      'authorName': 'Dr. Patricia Lee',
      'authorId': 'prof_001',
      'timestamp': '2025-12-12T08:00:00Z',
      'replies': [
        {
          'content': 'Anyone have recommendations for electives in the CS department? I need 2 more courses.',
          'authorName': 'Kevin Smith',
          'authorId': 'user_012',
          'timestamp': '2025-12-12T09:00:00Z',
          'replies': [
            {
              'content': 'Machine Learning and Data Visualization are both great choices!',
              'authorName': 'Amanda Scott',
              'authorId': 'user_013',
              'timestamp': '2025-12-12T10:00:00Z',
              'replies': []
            }
          ]
        },
        {
          'content': 'Pro tip: Check the professor\'s rating on Rate My Professor before enrolling.',
          'authorName': 'Marcus Johnson',
          'authorId': 'user_014',
          'timestamp': '2025-12-12T09:30:00Z',
          'replies': []
        }
      ]
    },
    {
      'title': 'Campus WiFi Issues - Need Help',
      'question': 'I\'ve been having trouble connecting to the campus WiFi, especially in the library. The connection keeps dropping. Is anyone else experiencing this? Have you found any solutions?',
      'authorName': 'Sofia Rodriguez',
      'authorId': 'user_015',
      'timestamp': '2025-12-11T16:45:00Z',
      'replies': [
        {
          'content': 'Same issue here! Try forgetting the network and reconnecting. Also, try the guest network instead.',
          'authorName': 'Chris Brown',
          'authorId': 'user_016',
          'timestamp': '2025-12-11T17:30:00Z',
          'replies': [
            {
              'content': 'That worked for me! Thanks for the suggestion.',
              'authorName': 'Sofia Rodriguez',
              'authorId': 'user_015',
              'timestamp': '2025-12-11T18:15:00Z',
              'replies': []
            }
          ]
        },
        {
          'content': 'Contact IT helpdesk at Building A, Room 105. They\'re very helpful.',
          'authorName': 'Rachel Evans',
          'authorId': 'user_017',
          'timestamp': '2025-12-11T18:00:00Z',
          'replies': []
        }
      ]
    },
    {
      'title': 'Student Organizations Fair - Sign Up Now!',
      'question': 'The annual Student Organizations Fair is happening next Friday at the Student Center! There are over 50 clubs and organizations participating. What clubs are you planning to check out?',
      'authorName': 'Student Affairs Office',
      'authorId': 'admin_002',
      'timestamp': '2025-12-10T12:00:00Z',
      'replies': [
        {
          'content': 'Looking for the Coding Club and Debate Society. Hope they\'ll be there!',
          'authorName': 'Nathan White',
          'authorId': 'user_018',
          'timestamp': '2025-12-10T13:00:00Z',
          'replies': []
        },
        {
          'content': 'The Photography Club is amazing. Great community and fun events!',
          'authorName': 'Olivia Green',
          'authorId': 'user_019',
          'timestamp': '2025-12-10T13:30:00Z',
          'replies': [
            {
              'content': 'Definitely checking them out! Always wanted to improve my photography skills.',
              'authorName': 'Daniel Black',
              'authorId': 'user_020',
              'timestamp': '2025-12-10T14:15:00Z',
              'replies': []
            }
          ]
        }
      ]
    },
  ];

  // Faculty Level Threads (example: Faculty of Technology)
  static const List<Map<String, dynamic>> facultyThreads = [
    {
      'title': 'New Research Lab Opening Next Semester',
      'question': 'Exciting news! The Faculty is opening a new Artificial Intelligence Research Lab next semester. This thread is for discussing the research areas, equipment, and how to apply for access.',
      'authorName': 'Prof. Dr. Michael Wong',
      'authorId': 'prof_002',
      'timestamp': '2025-12-12T09:00:00Z',
      'replies': [
        {
          'content': 'What are the main research focus areas? I\'m interested in NLP and computer vision.',
          'authorName': 'Grace Lee',
          'authorId': 'user_021',
          'timestamp': '2025-12-12T10:15:00Z',
          'replies': [
            {
              'content': 'Both areas are included! We\'ll have dedicated teams for each. Check the faculty portal for details.',
              'authorName': 'Prof. Dr. Michael Wong',
              'authorId': 'prof_002',
              'timestamp': '2025-12-12T11:00:00Z',
              'replies': []
            }
          ]
        },
        {
          'content': 'Are undergraduate students eligible to participate?',
          'authorName': 'Henry Zhang',
          'authorId': 'user_022',
          'timestamp': '2025-12-12T10:45:00Z',
          'replies': [
            {
              'content': 'Yes! We welcome motivated undergraduate students. Priority given to those with strong GPA.',
              'authorName': 'Prof. Dr. Michael Wong',
              'authorId': 'prof_002',
              'timestamp': '2025-12-12T11:30:00Z',
              'replies': []
            }
          ]
        }
      ]
    },
    {
      'title': 'Programming Fundamentals - Common Issues & Tips',
      'question': 'This thread is for students taking Programming Fundamentals this semester. Share common issues you\'re facing, debugging tips, and study strategies. TAs will also be monitoring this thread.',
      'authorName': 'Dr. Jennifer Hayes',
      'authorId': 'prof_003',
      'timestamp': '2025-12-11T08:30:00Z',
      'replies': [
        {
          'content': 'Struggling with recursion. Can someone explain the call stack concept again?',
          'authorName': 'Brandon Moore',
          'authorId': 'user_023',
          'timestamp': '2025-12-11T10:00:00Z',
          'replies': [
            {
              'content': 'Think of recursion like a stack of books. You add a book (function call), and at the bottom is your base case.',
              'authorName': 'TA - Mark Chen',
              'authorId': 'ta_001',
              'timestamp': '2025-12-11T10:45:00Z',
              'replies': []
            }
          ]
        },
        {
          'content': 'Use visualtualizng.ai to see how your code executes step by step. Really helped me understand loops!',
          'authorName': 'Victoria Price',
          'authorId': 'user_024',
          'timestamp': '2025-12-11T11:15:00Z',
          'replies': []
        }
      ]
    },
    {
      'title': 'Capstone Project Ideas - Let\'s Brainstorm!',
      'question': 'Final year students! It\'s time to start thinking about capstone projects. Share your ideas, find potential teammates, and discuss technical challenges. Faculty mentors will provide guidance.',
      'authorName': 'Prof. Dr. Robert Stevens',
      'authorId': 'prof_004',
      'timestamp': '2025-12-10T14:00:00Z',
      'replies': [
        {
          'content': 'Planning a mobile app for campus event management. Anyone interested in joining?',
          'authorName': 'Sophia Anderson',
          'authorId': 'user_025',
          'timestamp': '2025-12-10T15:30:00Z',
          'replies': [
            {
              'content': 'Sounds interesting! I have experience with React Native. Count me in!',
              'authorName': 'Isaac Wilson',
              'authorId': 'user_026',
              'timestamp': '2025-12-10T16:45:00Z',
              'replies': []
            }
          ]
        },
        {
          'content': 'Considering a web platform for student mentoring. Looking for teammates with full-stack experience.',
          'authorName': 'Hannah Edwards',
          'authorId': 'user_027',
          'timestamp': '2025-12-10T16:00:00Z',
          'replies': []
        }
      ]
    },
  ];

  // Department Level Threads (example: Computer Science Department)
  static const List<Map<String, dynamic>> departmentThreads = [
    {
      'title': 'CS Club Meeting - Weekly Algorithm Problems',
      'question': 'Join the CS Club every Thursday at 4 PM in Room 201 to solve algorithm problems and prepare for coding interviews. This week we\'re covering dynamic programming!',
      'authorName': 'CS Club President',
      'authorId': 'club_001',
      'timestamp': '2025-12-12T10:00:00Z',
      'replies': [
        {
          'content': 'Great! I really need to improve my DP skills. See you Thursday!',
          'authorName': 'Tyler Nguyen',
          'authorId': 'user_028',
          'timestamp': '2025-12-12T11:00:00Z',
          'replies': []
        },
        {
          'content': 'Can beginners join? I\'m just starting with competitive programming.',
          'authorName': 'Lauren Mitchell',
          'authorId': 'user_029',
          'timestamp': '2025-12-12T11:30:00Z',
          'replies': [
            {
              'content': 'Absolutely! We have problems at all difficulty levels. Everyone is welcome!',
              'authorName': 'CS Club President',
              'authorId': 'club_001',
              'timestamp': '2025-12-12T12:00:00Z',
              'replies': []
            }
          ]
        }
      ]
    },
    {
      'title': 'Database Systems - Query Optimization Discussion',
      'question': 'For those taking Database Systems, let\'s discuss query optimization strategies. Share your experiences with indexing, joins, and execution plans. Professor Kumar is also contributing to this thread.',
      'authorName': 'Prof. Dr. Rajesh Kumar',
      'authorId': 'prof_005',
      'timestamp': '2025-12-11T13:00:00Z',
      'replies': [
        {
          'content': 'Why is my LEFT JOIN so slow? I have 2 million rows in both tables.',
          'authorName': 'Jordan Foster',
          'authorId': 'user_030',
          'timestamp': '2025-12-11T14:00:00Z',
          'replies': [
            {
              'content': 'Create indexes on the join columns. Also, check if you\'re filtering correctly. Send your query for review.',
              'authorName': 'Prof. Dr. Rajesh Kumar',
              'authorId': 'prof_005',
              'timestamp': '2025-12-11T14:45:00Z',
              'replies': []
            }
          ]
        },
        {
          'content': 'The EXPLAIN command is your best friend. It shows you exactly what the database is doing!',
          'authorName': 'Corey Bell',
          'authorId': 'user_031',
          'timestamp': '2025-12-11T14:30:00Z',
          'replies': []
        }
      ]
    },
    {
      'title': 'Senior Design Projects - Showcase & Feedback',
      'question': 'Share your senior design project ideas and progress! This is a great place to get feedback from peers and faculty. Projects should address real-world problems in CS.',
      'authorName': 'Dr. Angela Foster',
      'authorId': 'prof_006',
      'timestamp': '2025-12-09T15:00:00Z',
      'replies': [
        {
          'content': 'Building an autonomous drone control system using computer vision. Still in early stages.',
          'authorName': 'Ethan Ross',
          'authorId': 'user_032',
          'timestamp': '2025-12-09T16:00:00Z',
          'replies': [
            {
              'content': 'Very cool! Have you considered using ROS (Robot Operating System)? Great community and lots of libraries.',
              'authorName': 'Natasha Kumar',
              'authorId': 'user_033',
              'timestamp': '2025-12-09T17:00:00Z',
              'replies': []
            }
          ]
        },
        {
          'content': 'Creating a plagiarism detection system for academic integrity. Using ML for source code similarity.',
          'authorName': 'Molly Carter',
          'authorId': 'user_034',
          'timestamp': '2025-12-09T16:30:00Z',
          'replies': [
            {
              'content': 'Interesting approach! Have you looked at existing tools like MOSS and JPlag?',
              'authorName': 'Dr. Angela Foster',
              'authorId': 'prof_006',
              'timestamp': '2025-12-09T17:30:00Z',
              'replies': []
            }
          ]
        }
      ]
    },
  ];
}
