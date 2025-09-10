import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding community posts...');

  // Get all users to create posts from different authors
  const users = await prisma.user.findMany({
    include: { profile: true },
    orderBy: { user_id: 'asc' }
  });

  if (users.length === 0) {
    console.log('❌ No users found. Please run the main seed first.');
    return;
  }

  console.log(`Found ${users.length} users: ${users.map(u => `${u.user_id} (${u.profile?.full_name || u.email})`).join(', ')}`);

  // Create sample community posts from different users
  const samplePosts = [
    {
      title: "Welcome to our neighborhood!",
      content: "Hello everyone! I'm new to the area and wanted to introduce myself. Looking forward to meeting all of you and being part of this wonderful community.",
      author_id: users[0].user_id, // First user
      media: [
        {
          file_url: "https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400&h=200&fit=crop",
          file_type: "image",
          file_name: "welcome.jpg",
          file_size: 1024000,
          mime_type: "image/jpeg"
        }
      ]
    },
    {
      title: "Community Garden Update",
      content: "The community garden is looking great this season! We've harvested fresh tomatoes and herbs. If anyone wants to help with the next planting, we'll be there this Saturday at 9 AM.",
      author_id: users[1]?.user_id || users[0].user_id, // Second user or first if only one exists
      media: [
        {
          file_url: "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400&h=200&fit=crop",
          file_type: "image",
          file_name: "garden1.jpg",
          file_size: 2048000,
          mime_type: "image/jpeg"
        },
        {
          file_url: "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400&h=200&fit=crop",
          file_type: "image",
          file_name: "garden2.jpg",
          file_size: 1856000,
          mime_type: "image/jpeg"
        }
      ]
    },
    {
      title: "Lost Cat - Please Help!",
      content: "Our beloved cat Whiskers went missing yesterday evening. He's a gray tabby with white paws and a distinctive white spot on his chest. If you see him, please contact me immediately. We're very worried!",
      author_id: users[2]?.user_id || users[0].user_id, // Third user or first if only one exists
      media: [
        {
          file_url: "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=200&fit=crop",
          file_type: "image",
          file_name: "whiskers.jpg",
          file_size: 1536000,
          mime_type: "image/jpeg"
        }
      ]
    },
    {
      title: "Neighborhood Cleanup Day",
      content: "Join us this Sunday for our monthly neighborhood cleanup! We'll meet at the community center at 8 AM and provide all necessary supplies. Let's keep our area beautiful together!",
      author_id: users[0].user_id // First user
    },
    {
      title: "Local Business Recommendation",
      content: "I wanted to share about the new bakery that opened on Main Street. Their croissants are absolutely amazing! The owner is very friendly and they use locally sourced ingredients. Highly recommend checking them out!",
      author_id: users[1]?.user_id || users[0].user_id // Second user or first if only one exists
    }
  ];

  for (const postData of samplePosts) {
    const { media, ...postInfo } = postData;
    
    const post = await prisma.communityPost.create({
      data: {
        ...postInfo,
        media: media ? {
          create: media
        } : undefined
      }
    });

    console.log(`✅ Created post: ${post.title}`);
  }

  // Create some sample comments
  const posts = await prisma.communityPost.findMany();
  
  if (posts.length > 0) {
    const sampleComments = [
      {
        post_id: posts[0].post_id,
        author_id: users[1]?.user_id || users[0].user_id, // Second user or first
        content: "Welcome to the neighborhood! Feel free to reach out if you need any help settling in."
      },
      {
        post_id: posts[1].post_id,
        author_id: users[0].user_id, // First user
        content: "I'll definitely be there! The garden looks amazing this year."
      },
      {
        post_id: posts[2].post_id,
        author_id: users[1]?.user_id || users[0].user_id, // Second user or first
        content: "I'll keep an eye out for Whiskers. I hope you find him soon!"
      }
    ];

    for (const commentData of sampleComments) {
      await prisma.communityComment.create({
        data: commentData
      });
    }

    console.log('✅ Created sample comments');
  }

  // Create some sample likes from different users
  for (let i = 0; i < Math.min(3, posts.length); i++) {
    const likeUserId = users[i % users.length].user_id; // Cycle through users
    await prisma.communityLike.create({
      data: {
        post_id: posts[i].post_id,
        user_id: likeUserId
      }
    });
  }

  console.log('✅ Created sample likes');
  console.log('🎉 Community posts seeding completed!');
}

main()
  .catch((e) => {
    console.error('❌ Error seeding community posts:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

