import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '@/config/cors';

const prisma = new PrismaClient();

// Handle CORS preflight requests
export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 204 }));
}

// POST /api/community/comments - Create a new comment
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { post_id, author_id, content, parent_id } = body;

    if (!post_id || !author_id || !content) {
      return addCors(NextResponse.json(
        { success: false, error: 'post_id, author_id, and content are required' },
        { status: 400 }
      ));
    }

    // Create the comment
    const comment = await prisma.communityComment.create({
      data: {
        post_id: parseInt(post_id),
        author_id: parseInt(author_id),
        content,
        parent_id: parent_id ? parseInt(parent_id) : null
      },
      include: {
        author: {
          include: {
            profile: true
          }
        },
        replies: {
          include: {
            author: {
              include: {
                profile: true
              }
            }
          }
        }
      }
    });

    // Update comment count on the post
    await prisma.communityPost.update({
      where: { post_id: parseInt(post_id) },
      data: { comment_count: { increment: 1 } }
    });

    return addCors(NextResponse.json({
      success: true,
      data: comment
    }, { status: 201 }));
  } catch (error) {
    console.error('Error creating comment:', error);
    return addCors(NextResponse.json(
      { success: false, error: 'Failed to create comment' },
      { status: 500 }
    ));
  }
}

