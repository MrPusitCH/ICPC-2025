import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '@/config/cors';
import { getCurrentUser } from '@/lib/auth';

const prisma = new PrismaClient();

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
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

    // Check if activity exists and is active
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

    if (!activity.is_active) {
      return addCors(NextResponse.json(
        { 
          success: false, 
          error: 'Activity is not active' 
        },
        { status: 400 }
      ));
    }

    if (activity.joined >= activity.capacity) {
      return addCors(NextResponse.json(
        { 
          success: false, 
          error: 'Activity is full' 
        },
        { status: 400 }
      ));
    }

    // Check if user already joined
    const existingJoin = await prisma.activityJoin.findUnique({
      where: {
        activity_id_user_id: {
          activity_id: activityId,
          user_id: userId,
        },
      },
    });

    if (existingJoin) {
      return addCors(NextResponse.json(
        { 
          success: false, 
          error: 'User already joined this activity' 
        },
        { status: 400 }
      ));
    }

    // Create join record and update joined count
    await prisma.$transaction(async (tx: any) => {
      await tx.activityJoin.create({
        data: {
          activity_id: activityId,
          user_id: userId,
        },
      });

      await tx.activity.update({
        where: {
          activity_id: activityId,
        },
        data: {
          joined: {
            increment: 1,
          },
        },
      });
    });

    return addCors(NextResponse.json(
      {
        success: true,
        message: 'Successfully joined activity',
      },
      { status: 200 }
    ));
  } catch (error) {
    console.error('Error joining activity:', error);
    return addCors(NextResponse.json(
      { 
        success: false, 
        error: 'Failed to join activity',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    ));
  }
}

export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 200 }));
}


