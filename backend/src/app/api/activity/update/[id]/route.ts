import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '@/config/cors';
import { getCurrentUser } from '@/lib/auth';

const prisma = new PrismaClient();

export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
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

    const activityId = parseInt(params.id);

    if (isNaN(activityId)) {
      return addCors(NextResponse.json(
        { 
          success: false, 
          error: 'Invalid activity ID' 
        },
        { status: 400 }
      ));
    }

    // Check if activity exists and user owns it
    const existingActivity = await prisma.activity.findUnique({
      where: {
        activity_id: activityId,
      },
    });

    if (!existingActivity) {
      return addCors(NextResponse.json(
        { 
          success: false, 
          error: 'Activity not found' 
        },
        { status: 404 }
      ));
    }

    if (existingActivity.author_id !== userId) {
      return addCors(NextResponse.json(
        { 
          success: false, 
          error: 'Not authorized to update this activity' 
        },
        { status: 403 }
      ));
    }

    const body = await request.json();
    const updateData: any = {};

    if (body.title !== undefined) updateData.title = body.title;
    if (body.description !== undefined) updateData.description = body.description;
    if (body.date !== undefined) updateData.date = body.date;
    if (body.time !== undefined) updateData.time = body.time;
    if (body.place !== undefined) updateData.place = body.place;
    if (body.location !== undefined) updateData.location = body.location;
    if (body.latitude !== undefined) updateData.latitude = body.latitude;
    if (body.longitude !== undefined) updateData.longitude = body.longitude;
    if (body.capacity !== undefined) updateData.capacity = parseInt(body.capacity);
    if (body.image_url !== undefined) updateData.image_url = body.image_url;
    if (body.image_name !== undefined) updateData.image_name = body.image_name;
    if (body.end_time !== undefined) updateData.end_time = body.end_time;
    if (body.category !== undefined) updateData.category = body.category;
    if (body.is_active !== undefined) updateData.is_active = body.is_active;

    const activity = await prisma.activity.update({
      where: {
        activity_id: activityId,
      },
      data: updateData,
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
      { status: 200 }
    ));
  } catch (error) {
    console.error('Error updating activity:', error);
    return addCors(NextResponse.json(
      { 
        success: false, 
        error: 'Failed to update activity',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    ));
  }
}

export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 200 }));
}
