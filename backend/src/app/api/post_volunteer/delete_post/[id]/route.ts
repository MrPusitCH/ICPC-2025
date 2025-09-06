import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '@/config/cors';

const prisma = new PrismaClient();

// Handle CORS preflight requests
export async function OPTIONS() {
  return addCors(new NextResponse(null, { status: 200 }));
}

// DELETE /api/post/delete_post/[id] - Delete post by id
export async function DELETE(
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

    // Check if post exists
    const existingPost = await prisma.post.findUnique({
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

    // Get user ID from request headers for authorization
    const authHeader = request.headers.get('authorization');
    const userId = authHeader ? parseInt(authHeader.replace('Bearer ', '')) : null;

    // For now, allow deletion without strict user validation
    // In production, you should validate the user owns the post
    if (userId && existingPost.user_id !== userId) {
      return addCors(NextResponse.json(
        {
          success: false,
          error: 'Unauthorized: You can only delete your own posts'
        },
        { status: 403 }
      ));
    }

    // Delete the post
    await prisma.post.delete({
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
