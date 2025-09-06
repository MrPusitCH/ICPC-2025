import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '../../../config/cors';

const prisma = new PrismaClient();

// GET /api/profile - Get user profile
export async function GET(request: NextRequest) {
  try {
    // Get user ID from query params or headers (you might want to get this from JWT token)
    const { searchParams } = new URL(request.url);
    const userId = searchParams.get('userId');
    
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
      userId: user.user_id,
      name: user.profile?.full_name || '',
      nickname: user.profile?.nickname || '',
      gender: user.profile?.gender || '',
      age: user.profile?.date_of_birth ? 
        Math.floor((Date.now() - new Date(user.profile.date_of_birth).getTime()) / (365.25 * 24 * 60 * 60 * 1000)).toString() : '',
      address: user.profile?.address || '',
      avatarUrl: user.profile?.profile_image_url || '',
      diseases: user.healthInfo.map((health: any) => ({
        text: health.condition,
        icon: 'health_and_safety' // Default icon, you can customize based on condition
      })),
      livingSituation: user.profile?.address ? [{
        text: 'Living alone', // You can determine this based on your business logic
        icon: 'person'
      }] : [],
      interests: user.userInterests.map((ui: any) => ({
        text: ui.interest.name,
        icon: 'favorite'
      })),
      emergencyContacts: user.emergencyContacts.map((contact: any) => ({
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

// PUT /api/profile - Update user profile
export async function PUT(request: NextRequest) {
  try {
    const body = await request.json();
    const { userId, name, nickname, gender, address, avatarUrl, diseases, livingSituation, interests, emergencyContacts } = body;

    if (!userId) {
      return NextResponse.json({ error: 'User ID is required' }, { status: 400 });
    }

    // Update user profile
    const updatedProfile = await prisma.userProfile.upsert({
      where: { user_id: parseInt(userId) },
      update: {
        full_name: name,
        nickname: nickname,
        gender: gender,
        address: address,
        profile_image_url: avatarUrl,
      },
      create: {
        user_id: parseInt(userId),
        full_name: name,
        nickname: nickname,
        gender: gender,
        address: address,
        profile_image_url: avatarUrl,
      }
    });

    // Update health info (diseases)
    if (diseases) {
      // Delete existing health info
      await prisma.healthInfo.deleteMany({
        where: { user_id: parseInt(userId) }
      });

      // Create new health info
      if (diseases.length > 0) {
        await prisma.healthInfo.createMany({
          data: diseases.map((disease: any) => ({
            user_id: parseInt(userId),
            condition: disease.text
          }))
        });
      }
    }

    // Update emergency contacts
    if (emergencyContacts) {
      // Delete existing emergency contacts
      await prisma.emergencyContact.deleteMany({
        where: { user_id: parseInt(userId) }
      });

      // Create new emergency contacts
      if (emergencyContacts.length > 0) {
        await prisma.emergencyContact.createMany({
          data: emergencyContacts.map((contact: any) => ({
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

// OPTIONS /api/profile - Handle CORS preflight requests
export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 200 }));
}
