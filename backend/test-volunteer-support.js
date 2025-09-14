const { PrismaClient } = require('@prisma/client');

async function testVolunteerSupport() {
  const prisma = new PrismaClient();
  
  try {
    console.log('Testing VolunteerSupport model...');
    
    // Test if volunteerSupport exists
    if (prisma.volunteerSupport) {
      console.log('✅ volunteerSupport model is available');
      
      // Test a simple query
      const supports = await prisma.volunteerSupport.findMany({ take: 1 });
      console.log('✅ Query works, found', supports.length, 'supports');
      
    } else {
      console.log('❌ volunteerSupport model is NOT available');
      console.log('Available models:', Object.keys(prisma));
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await prisma.$disconnect();
  }
}

testVolunteerSupport();
