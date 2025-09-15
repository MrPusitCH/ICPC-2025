import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '@/config/cors';

const prisma = new PrismaClient();

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const activityId = parseInt(id);

    if (isNaN(activityId)) {
      return addCors(NextResponse.json(
        { 
          success: false, 
          error: 'Invalid activity ID' 
        },
        { status: 400 }
      ));
    }

    const activity = await prisma.activity.findUnique({
      where: {
        activity_id: activityId,
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

    if (!activity) {
      return addCors(NextResponse.json(
        { 
          success: false, 
          error: 'Activity not found' 
        },
        { status: 404 }
      ));
    }

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
    console.error('Error fetching activity:', error);
    return addCors(NextResponse.json(
      { 
        success: false, 
        error: 'Failed to fetch activity',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    ));
  }
}

export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 200 }));
}
