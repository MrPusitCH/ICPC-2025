import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '@/config/cors';

const prisma = new PrismaClient();

// GET /api/posts/get/id - Fetch single post by id with user info
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const postId = parseInt(id);

    if (isNaN(postId)) {
      return NextResponse.json(
        {
          success: false,
          error: 'Invalid post ID'
        },
        { status: 400 }
      );
    }

    const post = await prisma.post.findUnique({
      where: {
        post_id: postId
      },
      include: {
        user: {
          include: {
            profile: true
          }
        }
      }
    });

    if (!post) {
      return NextResponse.json(
        {
          success: false,
          error: 'Post not found'
        },
        { status: 404 }
      );
    }

    return addCors(NextResponse.json({
      success: true,
      data: post
    }));
  } catch (error) {
    console.error('Error fetching post:', error);
    return addCors(NextResponse.json(
      {
        success: false,
        error: 'Failed to fetch post'
      },
      { status: 500 }
    ));
  }
}

// Handle CORS preflight requests
export async function OPTIONS() {
  return addCors(new NextResponse(null, { status: 200 }));
}
