import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '@/config/cors';

const prisma = new PrismaClient();

// Type assertion to help TypeScript recognize the post property
const prismaWithPost = prisma as any;

// Handle CORS preflight requests
export async function OPTIONS() {
  return addCors(new NextResponse(null, { status: 200 }));
}

// POST /api/post_volunteer/post - Create a new post
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { title, description, dateTime, reward, userId } = body;

    // Validate required fields
    if (!title || !description || !dateTime || !userId) {
      return NextResponse.json(
        {
          success: false,
          error: 'Missing required fields: title, description, dateTime, userId'
        },
        { status: 400 }
      );
    }

    // Validate userId exists
    const user = await prisma.user.findUnique({
      where: { user_id: userId }
    });

    if (!user) {
      return NextResponse.json(
        {
          success: false,
          error: 'User not found'
        },
        { status: 404 }
      );
    }

    // Create the post
    const post = await prismaWithPost.post.create({
      data: {
        title,
        description,
        dateTime: new Date(dateTime),
        reward: reward || null,
        user_id: userId
      },
      include: {
        user: {
          include: {
            profile: true
          }
        }
      }
    });

    return addCors(NextResponse.json({
      success: true,
      data: post
    }, { status: 201 }));
  } catch (error) {
    console.error('Error creating post:', error);
    return addCors(NextResponse.json(
      {
        success: false,
        error: 'Failed to create post'
      },
      { status: 500 }
    ));
  }
}
