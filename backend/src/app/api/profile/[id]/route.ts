import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '../../../../config/cors';
import { getCurrentUser } from '../../../../lib/auth';

const prisma = new PrismaClient();

// GET /api/profile/[id] - Get user profile by ID
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id: userId } = await params;
    
    if (!userId) {
      return addCors(NextResponse.json({ error: 'User ID is required' }, { status: 400 }));
    }

    // Check authentication
    const authHeader = request.headers.get('authorization');
    const currentUser = await getCurrentUser(authHeader);
    
    if (!currentUser) {
      return addCors(NextResponse.json({ error: 'Authentication required' }, { status: 401 }));
    }

    // Check if user is trying to access their own profile or is admin
    const targetUserId = parseInt(userId);
    if (currentUser.user_id !== targetUserId && currentUser.role !== 'ADMIN') {
      return addCors(NextResponse.json({ error: 'Access denied' }, { status: 403 }));
    }

    const user = await prisma.user.findUnique({
      where: { user_id: parseInt(userId) },
      include: {
        profile: true,
        healthInfo: true,
        emergencyContacts: true,
        userInterests: {
          include: {
            interest: true
          }
        }
      }
    });

    if (!user) {
      return addCors(NextResponse.json({ error: 'User not found' }, { status: 404 }));
    }

    // Calculate age from date_of_birth
    let age = '';
    if (user.profile?.date_of_birth) {
      const birthDate = new Date(user.profile.date_of_birth);
      const now = new Date();
      age = (now.getFullYear() - birthDate.getFullYear()).toString();
      console.log('Calculated age from date_of_birth:', age, 'Birth date:', birthDate);
    } else {
      console.log('No date_of_birth found for user:', user.user_id);
    }

    // Transform data to match Flutter app structure
    const profileData = {
      user_id: user.user_id,
      full_name: user.profile?.full_name || '',
      nickname: user.profile?.nickname || '',
      gender: user.profile?.gender || '',
      age: age,
      date_of_birth: user.profile?.date_of_birth || null,
      address: user.profile?.address || '',
      profile_image_url: user.profile?.profile_image_url || '',
      health_conditions: user.healthInfo.map((health: any) => health.condition),
      interests: user.userInterests.map((ui: any) => ui.interest.name),
      emergency_contacts: user.emergencyContacts.map((contact: any) => ({
        name: contact.name,
        phone: contact.phone,
        relationship: contact.relationship || ''
      }))
    };

    return addCors(NextResponse.json(profileData));
  } catch (error) {
    console.error('Error fetching profile:', error);
    return addCors(NextResponse.json({ error: 'Internal server error' }, { status: 500 }));
  }
}

// PUT /api/profile/[id] - Update user profile by ID
export async function PUT(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id: userId } = await params;
    const body = await request.json();
    
    console.log('Profile update request for user:', userId);
    console.log('Request body:', JSON.stringify(body, null, 2));
    
    const { 
      full_name, 
      nickname, 
      gender, 
      address, 
      profile_image_url, 
      health_conditions, 
      interests, 
      emergency_contacts,
      age  // Handle age from frontend
    } = body;

    console.log('Age received:', age, 'Type:', typeof age);

    if (!userId) {
      return addCors(NextResponse.json({ error: 'User ID is required' }, { status: 400 }));
    }

    // Check authentication
    const authHeader = request.headers.get('authorization');
    const currentUser = await getCurrentUser(authHeader);
    
    if (!currentUser) {
      return addCors(NextResponse.json({ error: 'Authentication required' }, { status: 401 }));
    }

    // Check if user is trying to update their own profile or is admin
    const targetUserId = parseInt(userId);
    if (currentUser.user_id !== targetUserId && currentUser.role !== 'ADMIN') {
      return addCors(NextResponse.json({ error: 'Access denied' }, { status: 403 }));
    }

    // Validate required fields
    if (!full_name || full_name.trim() === '') {
      return addCors(NextResponse.json({ error: 'Full name is required' }, { status: 400 }));
    }

    // Calculate date of birth from age if provided
    let dateOfBirth = null;
    if (age && !isNaN(parseInt(age))) {
      const currentDate = new Date();
      const currentYear = currentDate.getFullYear();
      const birthYear = currentYear - parseInt(age);
      // Use current month and day for more accurate age calculation
      dateOfBirth = new Date(birthYear, currentDate.getMonth(), currentDate.getDate());
      console.log('Converting age', age, 'to date_of_birth:', dateOfBirth);
    }

    // Use transaction to ensure all operations succeed or fail together
    const result = await prisma.$transaction(async (tx: any) => {
      console.log('Starting profile update transaction for user:', targetUserId);
      
      // Update user profile
      console.log('Updating profile with date_of_birth:', dateOfBirth);
      const updatedProfile = await tx.userProfile.upsert({
        where: { user_id: parseInt(userId) },
        update: {
          full_name: full_name,
          nickname: nickname,
          gender: gender,
          address: address,
          profile_image_url: profile_image_url,
          date_of_birth: dateOfBirth,
        },
        create: {
          user_id: parseInt(userId),
          full_name: full_name,
          nickname: nickname,
          gender: gender,
          address: address,
          profile_image_url: profile_image_url,
          date_of_birth: dateOfBirth,
        }
      });
      console.log('Profile updated successfully:', updatedProfile);

      // Update health info (health_conditions)
      if (health_conditions && Array.isArray(health_conditions)) {
        console.log('Updating health conditions:', health_conditions);
        // Delete existing health info
        await tx.healthInfo.deleteMany({
          where: { user_id: parseInt(userId) }
        });

        // Create new health info
        if (health_conditions.length > 0) {
          await tx.healthInfo.createMany({
            data: health_conditions.map((condition: string) => ({
              user_id: parseInt(userId),
              condition: condition
            }))
          });
        }
      }

      // Update interests
      if (interests && Array.isArray(interests)) {
        console.log('Updating interests:', interests);
        // Delete existing user interests
        await tx.userInterest.deleteMany({
          where: { user_id: parseInt(userId) }
        });

        // Create new interests and user interests
        for (const interestName of interests) {
          // Create interest if it doesn't exist
          const interest = await tx.interest.upsert({
            where: { name: interestName },
            update: {},
            create: { name: interestName }
          });

          // Create user interest relationship
          await tx.userInterest.create({
            data: {
              user_id: parseInt(userId),
              interest_id: interest.interest_id
            }
          });
        }
      }

      // Update emergency contacts
      if (emergency_contacts && Array.isArray(emergency_contacts)) {
        console.log('Updating emergency contacts:', emergency_contacts);
        // Delete existing emergency contacts
        await tx.emergencyContact.deleteMany({
          where: { user_id: parseInt(userId) }
        });

        // Create new emergency contacts
        if (emergency_contacts.length > 0) {
          await tx.emergencyContact.createMany({
            data: emergency_contacts.map((contact: { name: string; phone: string; relationship: string }) => ({
              user_id: parseInt(userId),
              name: contact.name,
              phone: contact.phone,
              relationship: contact.relationship
            }))
          });
        }
      }

      console.log('Profile update transaction completed successfully');
      return updatedProfile;
    });

    console.log('Profile update completed for user:', targetUserId);
    return addCors(NextResponse.json({ 
      message: 'Profile updated successfully',
      profile: result 
    }));
  } catch (error) {
    console.error('Error updating profile:', error);
    return addCors(NextResponse.json({ error: 'Internal server error' }, { status: 500 }));
  }
}

// DELETE /api/profile/[id] - Delete user profile by ID
export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id: userId } = await params;
    
    if (!userId) {
      return addCors(NextResponse.json({ error: 'User ID is required' }, { status: 400 }));
    }

    // Check authentication
    const authHeader = request.headers.get('authorization');
    const currentUser = await getCurrentUser(authHeader);
    
    if (!currentUser) {
      return addCors(NextResponse.json({ error: 'Authentication required' }, { status: 401 }));
    }

    // Check if user is trying to delete their own profile or is admin
    const targetUserId = parseInt(userId);
    if (currentUser.user_id !== targetUserId && currentUser.role !== 'ADMIN') {
      return addCors(NextResponse.json({ error: 'Access denied' }, { status: 403 }));
    }

    // Delete user profile (cascade will handle related records)
    await prisma.userProfile.delete({
      where: { user_id: parseInt(userId) }
    });

    return addCors(NextResponse.json({ 
      message: 'Profile deleted successfully'
    }));
  } catch (error) {
    console.error('Error deleting profile:', error);
    return addCors(NextResponse.json({ error: 'Internal server error' }, { status: 500 }));
  }
}

// OPTIONS /api/profile/[id] - Handle CORS preflight requests
export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 200 }));
}
