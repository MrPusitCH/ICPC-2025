import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '@/config/cors';
import { getCurrentUser } from '@/lib/auth';

const prisma = new PrismaClient();

export async function POST(
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

    // Check if user has joined this activity
    const existingJoin = await prisma.activityJoin.findUnique({
      where: {
        activity_id_user_id: {
          activity_id: activityId,
          user_id: userId,
        },
      },
    });

    if (!existingJoin) {
      return addCors(NextResponse.json(
        { 
          success: false, 
          error: 'User has not joined this activity' 
        },
        { status: 400 }
      ));
    }

    // Delete join record and update joined count
    await prisma.$transaction(async (tx: any) => {
      await tx.activityJoin.delete({
        where: {
          activity_id_user_id: {
            activity_id: activityId,
            user_id: userId,
          },
        },
      });

      await tx.activity.update({
        where: {
          activity_id: activityId,
        },
        data: {
          joined: {
            decrement: 1,
          },
        },
      });
    });

    return addCors(NextResponse.json(
      {
        success: true,
        message: 'Successfully left activity',
      },
      { status: 200 }
    ));
  } catch (error) {
    console.error('Error leaving activity:', error);
    return addCors(NextResponse.json(
      { 
        success: false, 
        error: 'Failed to leave activity',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    ));
  }
}

export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 200 }));
}
