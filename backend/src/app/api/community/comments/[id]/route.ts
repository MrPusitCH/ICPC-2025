import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '@/config/cors';

const prisma = new PrismaClient();

// Handle CORS preflight requests
export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 204 }));
}

// DELETE /api/community/comments/[id] - Delete a comment
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const commentId = parseInt(params.id);

    if (isNaN(commentId)) {
      return addCors(NextResponse.json(
        { success: false, error: 'Invalid comment ID' },
        { status: 400 }
      ));
    }

    // Get the comment to find the post_id
    const comment = await prisma.communityComment.findUnique({
      where: { comment_id: commentId },
      select: { post_id: true }
    });

    if (!comment) {
      return addCors(NextResponse.json(
        { success: false, error: 'Comment not found' },
        { status: 404 }
      ));
    }

    // Delete the comment
    await prisma.communityComment.delete({
      where: { comment_id: commentId }
    });

    // Decrement comment count
    await prisma.communityPost.update({
      where: { post_id: comment.post_id },
      data: { comment_count: { decrement: 1 } }
    });

    return addCors(NextResponse.json({
      success: true,
      message: 'Comment deleted successfully'
    }));
  } catch (error) {
    console.error('Error deleting comment:', error);
    return addCors(NextResponse.json(
      { success: false, error: 'Failed to delete comment' },
      { status: 500 }
    ));
  }
}
