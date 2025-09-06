import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  // Create a test user with ID 2
  const user = await prisma.user.upsert({
    where: { email: 'test2@example.com' },
    update: {},
    create: {
      email: 'test2@example.com',
      phone_number: '+1234567891',
      password_hash: 'password123', // Simple password for demo
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

  // Create interests (skip if they already exist)
  const interests = await prisma.interest.createMany({
    data: [
      { name: 'Reading' },
      { name: 'Gardening' },
      { name: 'Cooking' },
      { name: 'Walking' },
    ],
    skipDuplicates: true,
  });

  // Create user interests (skip if they already exist)
  const createdInterests = await prisma.interest.findMany();
  await prisma.userInterest.createMany({
    data: createdInterests.map(interest => ({
      user_id: user.user_id,
      interest_id: interest.interest_id,
    })),
    skipDuplicates: true,
  });

  // Create another test user with different ID
  const user2 = await prisma.user.upsert({
    where: { email: 'admin@example.com' },
    update: {},
    create: {
      email: 'admin@example.com',
      phone_number: '+1234567892',
      password_hash: 'password123',
      role: 'ADMIN',
      status: 'ACTIVE',
    },
  });

  // Create user profile for second user
  await prisma.userProfile.upsert({
    where: { user_id: user2.user_id },
    update: {},
    create: {
      user_id: user2.user_id,
      full_name: 'Admin User',
      nickname: 'Admin',
      profile_image_url: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
      date_of_birth: new Date('1980-01-01'),
      gender: 'Male',
      address: 'Admin Street 123',
    },
  });

  console.log('✅ Database seeded successfully!');
  console.log(`👤 Created user: ${user.email} (ID: ${user.user_id})`);
  console.log(`👤 Created user: ${user2.email} (ID: ${user2.user_id})`);
}

main()
  .catch((e) => {
    console.error('❌ Error seeding database:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });