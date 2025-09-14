import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '@/config/cors';

const prisma = new PrismaClient();

export async function POST(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
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

    // Increment view count
    await prisma.activity.update({
      where: {
        activity_id: activityId,
      },
      data: {
        views: {
          increment: 1,
        },
      },
    });

    return addCors(NextResponse.json(
      {
        success: true,
        message: 'View count incremented',
      },
      { status: 200 }
    ));
  } catch (error) {
    console.error('Error incrementing view count:', error);
    return addCors(NextResponse.json(
      { 
        success: false, 
        error: 'Failed to increment view count',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    ));
  }
}

export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 200 }));
}
