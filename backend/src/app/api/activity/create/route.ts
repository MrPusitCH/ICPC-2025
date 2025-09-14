import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '@/config/cors';
import { getCurrentUser } from '@/lib/auth';

const prisma = new PrismaClient();

export async function POST(request: NextRequest) {
  try {
    const authHeader = request.headers.get('authorization');
    const user = await getCurrentUser(authHeader);
    
    if (!user) {
      return addCors(NextResponse.json(
        { 
          success: false, 
          error: 'Authorization token required' 
        },
        { status: 401 }
      ));
    }

    const userId = user.user_id;

    const body = await request.json();
    const {
      title,
      description,
      date,
      time,
      place,
      capacity,
      location,
      latitude,
      longitude,
      image_url,
      image_name,
      end_time,
      category,
    } = body;

    // Validate required fields
    const missingFields = [];
    if (!title) missingFields.push('title');
    if (!description) missingFields.push('description');
    if (!date) missingFields.push('date');
    if (!time) missingFields.push('time');
    if (!place) missingFields.push('place');
    if (!capacity) missingFields.push('capacity');
    
    if (missingFields.length > 0) {
      return addCors(NextResponse.json(
        { 
          success: false, 
          error: `Missing required fields: ${missingFields.join(', ')}` 
        },
        { status: 400 }
      ));
    }

    const activity = await prisma.activity.create({
      data: {
        title,
        description,
        date,
        time,
        place,
        location: location || null,
        latitude: latitude || null,
        longitude: longitude || null,
        capacity: parseInt(capacity),
        image_url: image_url || null,
        image_name: image_name || null,
        author_id: userId,
        end_time: end_time || null,
        category: category || null,
      },
      include: {
        author: {
          select: {
            user_id: true,
            email: true,
            profile: {
              select: {
                full_name: true,
                profile_image_url: true,
              },
            },
          },
        },
      },
    });

    const formattedActivity = {
      activity_id: activity.activity_id,
      title: activity.title,
      description: activity.description,
      date: activity.date,
      time: activity.time,
      place: activity.place,
      location: activity.location,
      latitude: activity.latitude,
      longitude: activity.longitude,
      capacity: activity.capacity,
      joined: activity.joined,
      comments: activity.comments,
      views: activity.views,
      image_url: activity.image_url,
      image_name: activity.image_name,
      author_id: activity.author_id,
      author_name: activity.author.profile?.full_name || activity.author.email,
      author_avatar: activity.author.profile?.profile_image_url,
      created_at: activity.created_at,
      updated_at: activity.updated_at,
      is_active: activity.is_active,
      end_time: activity.end_time,
      category: activity.category,
    };

    return addCors(NextResponse.json(
      {
        success: true,
        data: formattedActivity,
      },
      { status: 201 }
    ));
  } catch (error) {
    console.error('Error creating activity:', error);
    return addCors(NextResponse.json(
      { 
        success: false, 
        error: 'Failed to create activity',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    ));
  }
}

export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 200 }));
}
