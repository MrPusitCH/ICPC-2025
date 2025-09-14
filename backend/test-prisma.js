const { PrismaClient } = require('@prisma/client');

async function testPrisma() {
  const prisma = new PrismaClient();
  
  try {
    console.log('Testing Prisma client...');
    console.log('Available models:', Object.keys(prisma));
    
    // Test if volunteerSupport exists
    if (prisma.volunteerSupport) {
      console.log('✅ volunteerSupport model is available');
    } else {
      console.log('❌ volunteerSupport model is NOT available');
    }
    
    // Test basic query
    const users = await prisma.user.findMany({ take: 1 });
    console.log('✅ Basic query works, found', users.length, 'users');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await prisma.$disconnect();
  }
}

testPrisma();
