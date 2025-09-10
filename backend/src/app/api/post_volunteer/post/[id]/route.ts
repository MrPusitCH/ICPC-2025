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

// GET /api/post/[id] - Get a single post by ID
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const postId = parseInt(id);
    
    if (isNaN(postId)) {
      return addCors(NextResponse.json(
        {
          success: false,
          error: 'Invalid post ID'
        },
        { status: 400 }
      ));
    }

    const post = await prismaWithPost.post.findUnique({
      where: { post_id: postId },
      include: {
        user: {
          include: {
            profile: true
          }
        }
      }
    });

    if (!post) {
      return addCors(NextResponse.json(
        {
          success: false,
          error: 'Post not found'
        },
        { status: 404 }
      ));
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

// PUT /api/post/[id] - Update a post by ID
export async function PUT(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const postId = parseInt(id);
    
    if (isNaN(postId)) {
      return addCors(NextResponse.json(
        {
          success: false,
          error: 'Invalid post ID'
        },
        { status: 400 }
      ));
    }

    const body = await request.json();
    const { title, description, dateTime, reward, userId } = body;

    // Check if post exists
    const existingPost = await prismaWithPost.post.findUnique({
      where: { post_id: postId }
    });

    if (!existingPost) {
      return addCors(NextResponse.json(
        {
          success: false,
          error: 'Post not found'
        },
        { status: 404 }
      ));
    }

    // Check if user owns this post (authorization)
    const authHeader = request.headers.get('authorization');
    const currentUserId = authHeader ? parseInt(authHeader.replace('Bearer ', '')) : null;
    
    if (currentUserId && existingPost.user_id !== currentUserId) {
      return addCors(NextResponse.json(
        {
          success: false,
          error: 'You can only update your own posts'
        },
        { status: 403 }
      ));
    }

    // Validate required fields
    if (!title || !description || !dateTime) {
      return addCors(NextResponse.json(
        {
          success: false,
          error: 'Missing required fields: title, description, dateTime'
        },
        { status: 400 }
      ));
    }

    // Update the post
    const updatedPost = await prismaWithPost.post.update({
      where: { post_id: postId },
      data: {
        title,
        description,
        dateTime: new Date(dateTime),
        reward: reward || null,
        // Only update userId if provided and user is authorized
        ...(userId && currentUserId === existingPost.user_id ? { user_id: userId } : {})
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
      data: updatedPost
    }));
  } catch (error) {
    console.error('Error updating post:', error);
    return addCors(NextResponse.json(
      {
        success: false,
        error: 'Failed to update post'
      },
      { status: 500 }
    ));
  }
}

// DELETE /api/post/[id] - Delete a post by ID
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const postId = parseInt(params.id);
    
    if (isNaN(postId)) {
      return addCors(NextResponse.json(
        {
          success: false,
          error: 'Invalid post ID'
        },
        { status: 400 }
      ));
    }

    // Check if post exists
    const existingPost = await prismaWithPost.post.findUnique({
      where: { post_id: postId }
    });

    if (!existingPost) {
      return addCors(NextResponse.json(
        {
          success: false,
          error: 'Post not found'
        },
        { status: 404 }
      ));
    }

    // Check if user owns this post (authorization)
    const authHeader = request.headers.get('authorization');
    const currentUserId = authHeader ? parseInt(authHeader.replace('Bearer ', '')) : null;
    
    if (currentUserId && existingPost.user_id !== currentUserId) {
      return addCors(NextResponse.json(
        {
          success: false,
          error: 'You can only delete your own posts'
        },
        { status: 403 }
      ));
    }

    // Delete the post
    await prismaWithPost.post.delete({
      where: { post_id: postId }
    });

    return addCors(NextResponse.json({
      success: true,
      message: 'Post deleted successfully'
    }));
  } catch (error) {
    console.error('Error deleting post:', error);
    return addCors(NextResponse.json(
      {
        success: false,
        error: 'Failed to delete post'
      },
      { status: 500 }
    ));
  }
}
