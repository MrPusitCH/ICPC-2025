import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '@/config/cors';
import { getCurrentUser } from '@/lib/auth';

const prisma = new PrismaClient();

export async function DELETE(
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
          error: 'Not authorized to delete this activity' 
        },
        { status: 403 }
      ));
    }

    // Delete the activity (this will cascade delete joins due to foreign key constraints)
    await prisma.activity.delete({
      where: {
        activity_id: activityId,
      },
    });

    return addCors(NextResponse.json(
      {
        success: true,
        message: 'Activity deleted successfully',
      },
      { status: 200 }
    ));
  } catch (error) {
    console.error('Error deleting activity:', error);
    return addCors(NextResponse.json(
      { 
        success: false, 
        error: 'Failed to delete activity',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    ));
  }
}

export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 200 }));
}
