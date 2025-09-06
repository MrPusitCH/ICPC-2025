import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  // Create a test user
  const user = await prisma.user.upsert({
    where: { email: 'test@example.com' },
    update: {},
    create: {
      email: 'test@example.com',
      phone_number: '+1234567890',
      password_hash: 'hashed_password_here', // In real app, hash this properly
      role: 'USER',
      status: 'ACTIVE',
    },
  });

  // Create user profile
  await prisma.userProfile.upsert({
    where: { user_id: user.user_id },
    update: {},
    create: {
      user_id: user.user_id,
      full_name: 'Dang Hayai',
      nickname: 'Dang',
      profile_image_url: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      date_of_birth: new Date('1975-01-01'),
      gender: 'Male',
      address: '203',
    },
  });

  // Create health info (diseases)
  await prisma.healthInfo.createMany({
    data: [
      {
        user_id: user.user_id,
        condition: 'Type 2 diabetes',
      },
      {
        user_id: user.user_id,
        condition: 'Osteoporosis',
      },
      {
        user_id: user.user_id,
        condition: 'High blood pressure',
      },
    ],
  });

  // Create emergency contacts
  await prisma.emergencyContact.createMany({
    data: [
      {
        user_id: user.user_id,
        name: 'Emergency Contact 1',
        phone: '+1234567891',
        relationship: 'Family',
      },
      {
        user_id: user.user_id,
        name: 'Emergency Contact 2',
        phone: '+1234567892',
        relationship: 'Friend',
      },
    ],
  });

  // Create interests
  const interests = await prisma.interest.createMany({
    data: [
      { name: 'Reading' },
      { name: 'Gardening' },
      { name: 'Cooking' },
      { name: 'Walking' },
    ],
  });

  // Create user interests
  const createdInterests = await prisma.interest.findMany();
  await prisma.userInterest.createMany({
    data: createdInterests.map(interest => ({
      user_id: user.user_id,
      interest_id: interest.interest_id,
    })),
  });

  console.log('✅ Database seeded successfully!');
  console.log(`👤 Created user: ${user.email}`);
}

main()
  .catch((e) => {
    console.error('❌ Error seeding database:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });