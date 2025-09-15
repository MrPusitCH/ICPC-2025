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

    // Check if activity exists
    const activity = await prisma.activity.findUnique({
      where: {
        activity_id: activityId,
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

    // Get participants
    const participants = await prisma.activityJoin.findMany({
      where: {
        activity_id: activityId,
      },
      include: {
        user: {
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
      orderBy: {
        joined_at: 'asc',
      },
    });

    const formattedParticipants = participants.map((join: any) => ({
      user_id: join.user.user_id,
      name: join.user.profile?.full_name || join.user.email,
      username: join.user.email,
      email: join.user.email,
      avatar: join.user.profile?.profile_image_url,
      joined_at: join.joined_at,
    }));

    return addCors(NextResponse.json(
      {
        success: true,
        data: formattedParticipants,
      },
      { status: 200 }
    ));
  } catch (error) {
    console.error('Error fetching participants:', error);
    return addCors(NextResponse.json(
      { 
        success: false, 
        error: 'Failed to fetch participants',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    ));
  }
}

export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 200 }));
}
