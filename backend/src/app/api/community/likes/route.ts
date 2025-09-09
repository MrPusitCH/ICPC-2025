import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '@/config/cors';

const prisma = new PrismaClient();

// Handle CORS preflight requests
export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 204 }));
}

// POST /api/community/likes - Like or unlike a post
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { post_id, user_id } = body;

    if (!post_id || !user_id) {
      return addCors(NextResponse.json(
        { success: false, error: 'post_id and user_id are required' },
        { status: 400 }
      ));
    }

    const postId = parseInt(post_id);
    const userId = parseInt(user_id);

    // Check if user already liked this post
    const existingLike = await prisma.communityLike.findUnique({
      where: {
        post_id_user_id: {
          post_id: postId,
          user_id: userId
        }
      }
    });

    if (existingLike) {
      // Unlike the post
      await prisma.communityLike.delete({
        where: { like_id: existingLike.like_id }
      });

      // Decrement like count
      await prisma.communityPost.update({
        where: { post_id: postId },
        data: { like_count: { decrement: 1 } }
      });

      return addCors(NextResponse.json({
        success: true,
        data: { liked: false, message: 'Post unliked' }
      }));
    } else {
      // Like the post
      await prisma.communityLike.create({
        data: {
          post_id: postId,
          user_id: userId
        }
      });

      // Increment like count
      await prisma.communityPost.update({
        where: { post_id: postId },
        data: { like_count: { increment: 1 } }
      });

      return addCors(NextResponse.json({
        success: true,
        data: { liked: true, message: 'Post liked' }
      }));
    }
  } catch (error) {
    console.error('Error toggling like:', error);
    return addCors(NextResponse.json(
      { success: false, error: 'Failed to toggle like' },
      { status: 500 }
    ));
  }
}

// GET /api/community/likes?post_id=123&user_id=456 - Check if user liked a post
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const post_id = searchParams.get('post_id');
    const user_id = searchParams.get('user_id');

    if (!post_id || !user_id) {
      return addCors(NextResponse.json(
        { success: false, error: 'post_id and user_id are required' },
        { status: 400 }
      ));
    }

    const existingLike = await prisma.communityLike.findUnique({
      where: {
        post_id_user_id: {
          post_id: parseInt(post_id),
          user_id: parseInt(user_id)
        }
      }
    });

    return addCors(NextResponse.json({
      success: true,
      data: { liked: !!existingLike }
    }));
  } catch (error) {
    console.error('Error checking like status:', error);
    return addCors(NextResponse.json(
      { success: false, error: 'Failed to check like status' },
      { status: 500 }
    ));
  }
}
