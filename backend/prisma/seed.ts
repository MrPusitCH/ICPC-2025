import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database with comprehensive user data...');

  // Create interests first (skip if they already exist)
  const interests = await prisma.interest.createMany({
    data: [
      { name: 'Reading' },
      { name: 'Gardening' },
      { name: 'Cooking' },
      { name: 'Walking' },
      { name: 'Volunteering' },
      { name: 'Community Service' },
      { name: 'Technology' },
      { name: 'Music' },
      { name: 'Art' },
      { name: 'Sports' },
    ],
    skipDuplicates: true,
  });

  const createdInterests = await prisma.interest.findMany();

  // Use plain text passwords for easier testing
  const plainPassword = 'password123';

  // Create sample users with different roles
  const users: any[] = [];

  const createdUsers = [];

  for (const userData of users) {
    const { profile, healthInfo, emergencyContacts, interests: userInterests, availability, ...userInfo } = userData;
    
    // Create user
    const user = await prisma.user.upsert({
      where: { email: userInfo.email },
      update: {},
      create: {
        ...userInfo,
        password_hash: plainPassword,
        status: 'ACTIVE',
      },
    });

    // Create user profile
    await prisma.userProfile.upsert({
      where: { user_id: user.user_id },
      update: {},
      create: {
        user_id: user.user_id,
        ...profile,
      },
    });

    // Create health info
    if (healthInfo.length > 0) {
      await prisma.healthInfo.createMany({
        data: healthInfo.map(condition => ({
          user_id: user.user_id,
          condition,
        })),
        skipDuplicates: true,
      });
    }

    // Create emergency contacts
    if (emergencyContacts.length > 0) {
      await prisma.emergencyContact.createMany({
        data: emergencyContacts.map(contact => ({
          user_id: user.user_id,
          ...contact,
        })),
        skipDuplicates: true,
      });
    }

    // Create user interests
    if (userInterests.length > 0) {
      const interestIds = createdInterests
        .filter(interest => userInterests.includes(interest.name))
        .map(interest => interest.interest_id);

      await prisma.userInterest.createMany({
        data: interestIds.map(interest_id => ({
          user_id: user.user_id,
          interest_id,
        })),
        skipDuplicates: true,
      });
    }

    // Create volunteer availability
    if (availability && availability.length > 0) {
      await prisma.volunteerAvailability.createMany({
        data: availability.map(avail => ({
          user_id: user.user_id,
          ...avail,
        })),
        skipDuplicates: true,
      });
    }

    // Create login history
    await prisma.loginHistory.create({
      data: {
        user_id: user.user_id,
        ip_address: '127.0.0.1',
        device_info: 'Chrome/Windows',
      },
    });

    createdUsers.push(user);
    console.log(`✅ Created ${userData.role.toLowerCase()}: ${user.email} (ID: ${user.user_id})`);
  }

  // Create sample news/announcements
  console.log('📰 Creating sample news and announcements...');
  
  const newsData = [
    {
      title: 'Electrical Equipment Inspection',
      content: 'An electrical equipment inspection will be carried out on Sep. 19, 2025. As a result, electricity will be unavailable on the following dates and times. Please be aware of this inconvenience and prepare accordingly. We recommend charging all devices and having backup lighting ready.',
      priority: 'important',
      author_id: createdUsers.find(u => u.role === 'ADMIN')?.user_id || createdUsers[0].user_id,
      date_time: 'Sep. 19, 2025, 13:00 - 20:00',
      disclaimer: 'Could be earlier or later depending on the situation.',
      view_count: 45,
    },
    {
      title: 'Rent Payment Reminder',
      content: 'The rent payment date is approaching. Rent varies depending on the room, so please check the details in your contract for details. If you have any problems with payment, please contact the management office immediately. Late payments may incur additional fees.',
      priority: 'caution',
      author_id: createdUsers.find(u => u.role === 'ADMIN')?.user_id || createdUsers[0].user_id,
      view_count: 32,
    },
    {
      title: 'Community Garden Update',
      content: 'The community garden is looking beautiful this season! We have fresh tomatoes, herbs, and flowers ready for harvest. Everyone is welcome to come and pick some fresh produce. Please remember to bring your own containers and be mindful of the plants. The garden is open daily from 6 AM to 8 PM.',
      priority: 'notice',
      author_id: createdUsers.find(u => u.role === 'ORGANIZER')?.user_id || createdUsers[0].user_id,
      view_count: 28,
    },
    {
      title: 'Water Supply Maintenance',
      content: 'Scheduled water supply maintenance will be conducted on Sep. 25, 2025 from 9:00 AM to 3:00 PM. Please store water in advance and avoid using water-intensive appliances during this period. We apologize for any inconvenience this may cause.',
      priority: 'important',
      author_id: createdUsers.find(u => u.role === 'ADMIN')?.user_id || createdUsers[0].user_id,
      date_time: 'Sep. 25, 2025, 09:00 - 15:00',
      view_count: 67,
    },
    {
      title: 'Monthly Community Meeting',
      content: 'The monthly community meeting will be held on Sep. 30, 2025 at 7:00 PM in the community hall. All residents are encouraged to attend and participate in discussions about community matters. We will discuss upcoming events, maintenance schedules, and address any concerns.',
      priority: 'notice',
      author_id: createdUsers.find(u => u.role === 'ORGANIZER')?.user_id || createdUsers[0].user_id,
      date_time: 'Sep. 30, 2025, 19:00',
      view_count: 23,
    },
    {
      title: 'Lost Pet Alert - Orange Tabby Cat',
      content: 'Our beloved cat Whiskers has been missing since yesterday evening. He\'s a friendly orange tabby with white paws and a distinctive white spot on his chest. If you see him or have any information, please contact me immediately. We\'re very worried and miss him dearly. Reward offered for safe return.',
      priority: 'caution',
      author_id: createdUsers.find(u => u.role === 'USER')?.user_id || createdUsers[0].user_id,
      view_count: 89,
    },
    {
      title: 'New Security Camera Installation',
      content: 'We are installing new security cameras around the building perimeter to enhance safety and security for all residents. The installation will be completed by the end of this month. The cameras will be monitored 24/7 and footage will be stored for 30 days.',
      priority: 'notice',
      author_id: createdUsers.find(u => u.role === 'ADMIN')?.user_id || createdUsers[0].user_id,
      view_count: 156,
    },
    {
      title: 'Fire Safety Drill Scheduled',
      content: 'A fire safety drill will be conducted on Oct. 5, 2025 at 10:00 AM. All residents must participate. Please familiarize yourself with the emergency exits and evacuation procedures. The alarm will sound for approximately 15 minutes. This is a mandatory drill for everyone\'s safety.',
      priority: 'important',
      author_id: createdUsers.find(u => u.role === 'ADMIN')?.user_id || createdUsers[0].user_id,
      date_time: 'Oct. 5, 2025, 10:00 AM',
      view_count: 78,
    },
  ];

  const createdNews = [];
  for (const newsItem of newsData) {
    const news = await prisma.news.create({
      data: {
        ...newsItem,
        created_at: new Date(Date.now() - Math.random() * 7 * 24 * 60 * 60 * 1000), // Random date within last week
        updated_at: new Date(),
      },
    });
    createdNews.push(news);
  }

  // Seed Activities
  console.log('🌱 Seeding activities...');
  
  const activityData = [
    {
      title: 'Chess Tournament',
      description: 'Join us for a friendly chess tournament! All skill levels welcome. We\'ll have prizes for the top 3 players.',
      date: '2025-01-15',
      time: '14:00',
      place: 'Community Center, Room 101',
      location: '123 Main St, Downtown',
      latitude: 13.7563,
      longitude: 100.5018,
      capacity: 16,
      image_url: 'https://images.unsplash.com/photo-1529699219852-7d0c1af0f961?w=400&h=200&fit=crop',
      image_name: 'chess-tournament.jpg',
      end_time: '18:00',
      category: 'Games',
    },
    {
      title: 'Morning Yoga Session',
      description: 'Start your day with a peaceful yoga session. Perfect for beginners and experienced practitioners.',
      date: '2025-01-16',
      time: '07:00',
      place: 'Central Park, Yoga Area',
      location: '456 Park Ave, Green District',
      latitude: 13.7651,
      longitude: 100.5380,
      capacity: 20,
      image_url: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400&h=200&fit=crop',
      image_name: 'yoga-session.jpg',
      end_time: '08:30',
      category: 'Fitness',
    },
    {
      title: 'Book Club Meeting',
      description: 'This month we\'re discussing "The Great Gatsby". Come share your thoughts and enjoy some coffee!',
      date: '2025-01-18',
      time: '19:00',
      place: 'Local Library, Meeting Room A',
      location: '789 Library St, Knowledge District',
      latitude: 13.7307,
      longitude: 100.5231,
      capacity: 12,
      image_url: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400&h=200&fit=crop',
      image_name: 'book-club.jpg',
      end_time: '21:00',
      category: 'Education',
    },
    {
      title: 'Community Garden Cleanup',
      description: 'Help us maintain our beautiful community garden. Tools and refreshments provided!',
      date: '2025-01-20',
      time: '09:00',
      place: 'Community Garden, Plot 5',
      location: '321 Garden Lane, Nature District',
      latitude: 13.7400,
      longitude: 100.5500,
      capacity: 25,
      image_url: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400&h=200&fit=crop',
      image_name: 'garden-cleanup.jpg',
      end_time: '12:00',
      category: 'Volunteer',
    },
    {
      title: 'Cooking Workshop: Thai Cuisine',
      description: 'Learn to cook authentic Thai dishes with our local chef. All ingredients provided!',
      date: '2025-01-22',
      time: '16:00',
      place: 'Community Kitchen, Station 3',
      location: '555 Food Court, Culinary District',
      latitude: 13.7500,
      longitude: 100.5600,
      capacity: 8,
      image_url: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=200&fit=crop',
      image_name: 'cooking-workshop.jpg',
      end_time: '19:00',
      category: 'Cooking',
    },
    {
      title: 'Tech Meetup: AI & Machine Learning',
      description: 'Join fellow tech enthusiasts to discuss the latest trends in AI and machine learning.',
      date: '2025-01-25',
      time: '18:30',
      place: 'Tech Hub, Conference Room B',
      location: '999 Innovation Blvd, Tech District',
      latitude: 13.7600,
      longitude: 100.5700,
      capacity: 30,
      image_url: 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=400&h=200&fit=crop',
      image_name: 'tech-meetup.jpg',
      end_time: '21:00',
      category: 'Technology',
    },
    {
      title: 'Art Exhibition Opening',
      description: 'Come celebrate the opening of our local artists\' exhibition. Wine and cheese will be served.',
      date: '2025-01-28',
      time: '18:00',
      place: 'Art Gallery, Main Hall',
      location: '777 Culture St, Arts District',
      latitude: 13.7700,
      longitude: 100.5800,
      capacity: 50,
      image_url: 'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=400&h=200&fit=crop',
      image_name: 'art-exhibition.jpg',
      end_time: '22:00',
      category: 'Arts',
    },
    {
      title: 'Basketball Tournament',
      description: '3v3 basketball tournament for all ages. Teams will be formed on the spot. Prizes for winners!',
      date: '2025-01-30',
      time: '10:00',
      place: 'Sports Complex, Court 2',
      location: '888 Sports Ave, Athletic District',
      latitude: 13.7800,
      longitude: 100.5900,
      capacity: 24,
      image_url: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=400&h=200&fit=crop',
      image_name: 'basketball-tournament.jpg',
      end_time: '16:00',
      category: 'Sports',
    },
  ];

  const createdActivities = [];
  for (const activity of activityData) {
    const createdActivity = await prisma.activity.create({
      data: {
        ...activity,
        author_id: createdUsers.find(u => u.role === 'ADMIN')?.user_id || 1,
        joined: Math.floor(Math.random() * 5), // Random joined count
        views: Math.floor(Math.random() * 50), // Random view count
        comments: Math.floor(Math.random() * 10), // Random comment count
      },
    });
    createdActivities.push(createdActivity);
  }

  console.log('🎉 Database seeded successfully!');
  console.log(`📊 Created ${createdUsers.length} users with different roles`);
  console.log(`📋 Created ${createdInterests.length} interests`);
  console.log(`📰 Created ${createdNews.length} news items and announcements`);
  console.log(`🎯 Created ${createdActivities.length} activities`);
}

main()
  .catch((e) => {
    console.error('❌ Error seeding database:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });