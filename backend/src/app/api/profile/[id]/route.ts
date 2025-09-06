import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '../../../../config/cors';

const prisma = new PrismaClient();

// GET /api/profile/[id] - Get user profile by ID
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id: userId } = await params;
    
    if (!userId) {
      return NextResponse.json({ error: 'User ID is required' }, { status: 400 });
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
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    // Transform data to match Flutter app structure
    const profileData = {
      user_id: user.user_id,
      full_name: user.profile?.full_name || '',
      nickname: user.profile?.nickname || '',
      gender: user.profile?.gender || '',
      date_of_birth: user.profile?.date_of_birth || null,
      address: user.profile?.address || '',
      profile_image_url: user.profile?.profile_image_url || '',
      health_conditions: user.healthInfo.map((health) => health.condition),
      interests: user.userInterests.map((ui) => ui.interest.name),
      emergency_contacts: user.emergencyContacts.map((contact) => ({
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
    const { 
      full_name, 
      nickname, 
      gender, 
      address, 
      profile_image_url, 
      health_conditions, 
      interests, 
      emergency_contacts 
    } = body;

    if (!userId) {
      return NextResponse.json({ error: 'User ID is required' }, { status: 400 });
    }

    // Update user profile
    const updatedProfile = await prisma.userProfile.upsert({
      where: { user_id: parseInt(userId) },
      update: {
        full_name: full_name,
        nickname: nickname,
        gender: gender,
        address: address,
        profile_image_url: profile_image_url,
      },
      create: {
        user_id: parseInt(userId),
        full_name: full_name,
        nickname: nickname,
        gender: gender,
        address: address,
        profile_image_url: profile_image_url,
      }
    });

    // Update health info (health_conditions)
    if (health_conditions) {
      // Delete existing health info
      await prisma.healthInfo.deleteMany({
        where: { user_id: parseInt(userId) }
      });

      // Create new health info
      if (health_conditions.length > 0) {
        await prisma.healthInfo.createMany({
          data: health_conditions.map((condition: string) => ({
            user_id: parseInt(userId),
            condition: condition
          }))
        });
      }
    }

    // Update interests
    if (interests) {
      // Delete existing user interests
      await prisma.userInterest.deleteMany({
        where: { user_id: parseInt(userId) }
      });

      // Create new interests and user interests
      for (const interestName of interests) {
        // Create interest if it doesn't exist
        const interest = await prisma.interest.upsert({
          where: { name: interestName },
          update: {},
          create: { name: interestName }
        });

        // Create user interest relationship
        await prisma.userInterest.create({
          data: {
            user_id: parseInt(userId),
            interest_id: interest.interest_id
          }
        });
      }
    }

    // Update emergency contacts
    if (emergency_contacts) {
      // Delete existing emergency contacts
      await prisma.emergencyContact.deleteMany({
        where: { user_id: parseInt(userId) }
      });

      // Create new emergency contacts
      if (emergency_contacts.length > 0) {
        await prisma.emergencyContact.createMany({
          data: emergency_contacts.map((contact: { name: string; phone: string; relationship: string }) => ({
            user_id: parseInt(userId),
            name: contact.name,
            phone: contact.phone,
            relationship: contact.relationship
          }))
        });
      }
    }

    return addCors(NextResponse.json({ 
      message: 'Profile updated successfully',
      profile: updatedProfile 
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
      return NextResponse.json({ error: 'User ID is required' }, { status: 400 });
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
