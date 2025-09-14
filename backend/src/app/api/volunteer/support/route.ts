import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '@/config/cors';
import { getCurrentUser } from '@/lib/auth';

const prisma = new PrismaClient();

// POST /api/volunteer/support - Support a volunteer request
export async function POST(request: NextRequest) {
  try {
    const authHeader = request.headers.get('authorization');
    const user = await getCurrentUser(authHeader);
    
    if (!user) {
      return addCors(NextResponse.json({ error: 'Authentication required' }, { status: 401 }));
    }

    const body = await request.json();
    const { postId } = body;

    if (!postId) {
      return addCors(NextResponse.json({ error: 'Post ID is required' }, { status: 400 }));
    }

    // Check if user already supported this post
    const existingSupport = await prisma.volunteerSupport.findUnique({
      where: {
        post_id_user_id: {
          post_id: parseInt(postId),
          user_id: user.user_id,
        },
      },
    });

    if (existingSupport) {
      return addCors(NextResponse.json({ 
        error: 'You have already supported this request',
        supported: true 
      }, { status: 400 }));
    }

    // Create support record
    const support = await prisma.volunteerSupport.create({
      data: {
        post_id: parseInt(postId),
        user_id: user.user_id,
        supported_at: new Date(),
      },
    });

    // Update support count
    await prisma.post.update({
      where: { post_id: parseInt(postId) },
      data: {
        support_count: {
          increment: 1,
        },
      },
    });

    return addCors(NextResponse.json({
      success: true,
      message: 'Successfully supported the volunteer request',
      support: support,
    }));
  } catch (error) {
    console.error('Error supporting volunteer request:', error);
    return addCors(NextResponse.json({ 
      error: 'Failed to support volunteer request',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 }));
  }
}

// DELETE /api/volunteer/support - Unsupport a volunteer request
export async function DELETE(request: NextRequest) {
  try {
    const authHeader = request.headers.get('authorization');
    const user = await getCurrentUser(authHeader);
    
    if (!user) {
      return addCors(NextResponse.json({ error: 'Authentication required' }, { status: 401 }));
    }

    const body = await request.json();
    const { postId } = body;

    if (!postId) {
      return addCors(NextResponse.json({ error: 'Post ID is required' }, { status: 400 }));
    }

    // Check if user has supported this post
    const existingSupport = await prisma.volunteerSupport.findUnique({
      where: {
        post_id_user_id: {
          post_id: parseInt(postId),
          user_id: user.user_id,
        },
      },
    });

    if (!existingSupport) {
      return addCors(NextResponse.json({ 
        error: 'You have not supported this request',
        supported: false 
      }, { status: 400 }));
    }

    // Delete support record
    await prisma.volunteerSupport.delete({
      where: {
        post_id_user_id: {
          post_id: parseInt(postId),
          user_id: user.user_id,
        },
      },
    });

    // Update support count
    await prisma.post.update({
      where: { post_id: parseInt(postId) },
      data: {
        support_count: {
          decrement: 1,
        },
      },
    });

    return addCors(NextResponse.json({
      success: true,
      message: 'Successfully unsupported the volunteer request',
    }));
  } catch (error) {
    console.error('Error unsupporting volunteer request:', error);
    return addCors(NextResponse.json({ 
      error: 'Failed to unsupport volunteer request',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 }));
  }
}

// GET /api/volunteer/support/[postId] - Check if user has supported a post
export async function GET(request: NextRequest) {
  try {
    const authHeader = request.headers.get('authorization');
    const user = await getCurrentUser(authHeader);
    
    if (!user) {
      return addCors(NextResponse.json({ error: 'Authentication required' }, { status: 401 }));
    }

    const url = new URL(request.url);
    const postId = url.searchParams.get('postId');

    if (!postId) {
      return addCors(NextResponse.json({ error: 'Post ID is required' }, { status: 400 }));
    }

    // Check if user has supported this post
    const support = await prisma.volunteerSupport.findUnique({
      where: {
        post_id_user_id: {
          post_id: parseInt(postId),
          user_id: user.user_id,
        },
      },
    });

    return addCors(NextResponse.json({
      supported: !!support,
      support: support,
    }));
  } catch (error) {
    console.error('Error checking support status:', error);
    return addCors(NextResponse.json({ 
      error: 'Failed to check support status',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 }));
  }
}

export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 200 }));
}
