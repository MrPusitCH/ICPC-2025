import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding community posts...');

  // Get the first user to use as author
  const user = await prisma.user.findFirst({
    include: { profile: true }
  });

  if (!user) {
    console.log('❌ No users found. Please run the main seed first.');
    return;
  }

  // Create sample community posts
  const samplePosts = [
    {
      title: "Welcome to our neighborhood!",
      content: "Hello everyone! I'm new to the area and wanted to introduce myself. Looking forward to meeting all of you and being part of this wonderful community.",
      author_id: user.user_id,
      media: [
        {
          file_url: "https://example.com/welcome.jpg",
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
      author_id: user.user_id,
      media: [
        {
          file_url: "https://example.com/garden1.jpg",
          file_type: "image",
          file_name: "garden1.jpg",
          file_size: 2048000,
          mime_type: "image/jpeg"
        },
        {
          file_url: "https://example.com/garden2.jpg",
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
      author_id: user.user_id,
      media: [
        {
          file_url: "https://example.com/whiskers.jpg",
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
      author_id: user.user_id
    },
    {
      title: "Local Business Recommendation",
      content: "I wanted to share about the new bakery that opened on Main Street. Their croissants are absolutely amazing! The owner is very friendly and they use locally sourced ingredients. Highly recommend checking them out!",
      author_id: user.user_id
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
        author_id: user.user_id,
        content: "Welcome to the neighborhood! Feel free to reach out if you need any help settling in."
      },
      {
        post_id: posts[1].post_id,
        author_id: user.user_id,
        content: "I'll definitely be there! The garden looks amazing this year."
      },
      {
        post_id: posts[2].post_id,
        author_id: user.user_id,
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

  // Create some sample likes
  for (let i = 0; i < Math.min(3, posts.length); i++) {
    await prisma.communityLike.create({
      data: {
        post_id: posts[i].post_id,
        user_id: user.user_id
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
