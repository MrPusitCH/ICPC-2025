class Volunteer {
  final String id;
  final String requesterName;
  final String title;
  final String description;
  final String timeAgo;
  final String dateTime;
  final String reward;
  final String avatarUrl;
  final int comments;
  final int views;
  final String? location;

  const Volunteer({
    required this.id,
    required this.requesterName,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.dateTime,
    required this.reward,
    required this.avatarUrl,
    required this.comments,
    required this.views,
    this.location,
  });

  // Mock data factory
  factory Volunteer.mock(String id) {
    final mockData = [
      {
        'requesterName': 'Dang Hayai',
        'title': 'Could you help me take me to the hospital?',
        'description': 'I need someone to accompany me to my cardiology appointment at City General Hospital. I have difficulty walking long distances and would appreciate assistance with transportation and support during the visit.',
        'timeAgo': '1 hour ago',
        'dateTime': 'Sep. 19, 2025 12:00 – undecided',
        'reward': '฿500',
        'avatarUrl': 'https://i.pravatar.cc/150?img=1',
        'comments': 3,
        'views': 12,
        'location': 'City General Hospital',
      },
      {
        'requesterName': 'Mrs. Tanaka',
        'title': 'Help with grocery shopping',
        'description': 'I need assistance with grocery shopping this week. I can provide a list and would appreciate someone to help carry the bags and navigate the store.',
        'timeAgo': '3 hours ago',
        'dateTime': 'Sep. 20, 2025 10:00 – 12:00',
        'reward': '฿300',
        'avatarUrl': 'https://i.pravatar.cc/150?img=2',
        'comments': 1,
        'views': 8,
        'location': 'Central Market',
      },
      {
        'requesterName': 'Mr. Johnson',
        'title': 'Garden maintenance help needed',
        'description': 'My garden needs some maintenance work. Looking for someone to help with weeding, pruning, and general cleanup. Tools will be provided.',
        'timeAgo': '5 hours ago',
        'dateTime': 'Sep. 21, 2025 09:00 – 11:00',
        'reward': '฿400',
        'avatarUrl': 'https://i.pravatar.cc/150?img=3',
        'comments': 2,
        'views': 15,
        'location': '123 Garden Street',
      },
      {
        'requesterName': 'Ms. Chen',
        'title': 'Computer help needed',
        'description': 'I need help setting up my new computer and learning how to use video calling to connect with my family. Patient teacher preferred.',
        'timeAgo': '1 day ago',
        'dateTime': 'Sep. 22, 2025 14:00 – 16:00',
        'reward': '฿600',
        'avatarUrl': 'https://i.pravatar.cc/150?img=4',
        'comments': 4,
        'views': 20,
        'location': 'Home visit',
      },
      {
        'requesterName': 'Dr. Smith',
        'title': 'Pet care assistance',
        'description': 'Need someone to walk my dog and feed my cat while I am away for a medical conference. Pets are friendly and well-behaved.',
        'timeAgo': '2 days ago',
        'dateTime': 'Sep. 23, 2025 08:00 – 18:00',
        'reward': '฿800',
        'avatarUrl': 'https://i.pravatar.cc/150?img=5',
        'comments': 1,
        'views': 6,
        'location': 'Pet Care Center',
      },
    ];

    final data = mockData[int.parse(id) % mockData.length];
    
    return Volunteer(
      id: id,
      requesterName: data['requesterName'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      timeAgo: data['timeAgo'] as String,
      dateTime: data['dateTime'] as String,
      reward: data['reward'] as String,
      avatarUrl: data['avatarUrl'] as String,
      comments: data['comments'] as int,
      views: data['views'] as int,
      location: data['location'] as String?,
    );
  }
}
