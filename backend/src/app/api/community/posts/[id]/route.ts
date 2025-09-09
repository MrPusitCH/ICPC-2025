import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '@/config/cors';

const prisma = new PrismaClient();

// Handle CORS preflight requests
export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 204 }));
}

// GET /api/community/posts/[id] - Get a specific community post
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const postId = parseInt(params.id);

    if (isNaN(postId)) {
      return addCors(NextResponse.json(
        { success: false, error: 'Invalid post ID' },
        { status: 400 }
      ));
    }

    const post = await prisma.communityPost.findUnique({
      where: { post_id: postId },
      include: {
        author: {
          include: {
            profile: true
          }
        },
        media: true,
        comments: {
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
          },
          orderBy: { created_at: 'asc' }
        },
        _count: {
          select: {
            comments: true,
            likes: true
          }
        }
      }
    });

    if (!post) {
      return addCors(NextResponse.json(
        { success: false, error: 'Post not found' },
        { status: 404 }
      ));
    }

    // Increment view count
    await prisma.communityPost.update({
      where: { post_id: postId },
      data: { view_count: { increment: 1 } }
    });

    return addCors(NextResponse.json({
      success: true,
      data: post
    }));
  } catch (error) {
    console.error('Error fetching community post:', error);
    return addCors(NextResponse.json(
      { success: false, error: 'Failed to fetch post' },
      { status: 500 }
    ));
  }
}

// PUT /api/community/posts/[id] - Update a community post
export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const postId = parseInt(params.id);
    const body = await request.json();
    const { title, content, is_published } = body;

    if (isNaN(postId)) {
      return addCors(NextResponse.json(
        { success: false, error: 'Invalid post ID' },
        { status: 400 }
      ));
    }

    const post = await prisma.communityPost.update({
      where: { post_id: postId },
      data: {
        ...(title && { title }),
        ...(content && { content }),
        ...(is_published !== undefined && { is_published }),
        updated_at: new Date()
      },
      include: {
        author: {
          include: {
            profile: true
          }
        },
        media: true,
        _count: {
          select: {
            comments: true,
            likes: true
          }
        }
      }
    });

    return addCors(NextResponse.json({
      success: true,
      data: post
    }));
  } catch (error) {
    console.error('Error updating community post:', error);
    return addCors(NextResponse.json(
      { success: false, error: 'Failed to update post' },
      { status: 500 }
    ));
  }
}

// DELETE /api/community/posts/[id] - Delete a community post
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const postId = parseInt(params.id);

    if (isNaN(postId)) {
      return addCors(NextResponse.json(
        { success: false, error: 'Invalid post ID' },
        { status: 400 }
      ));
    }

    await prisma.communityPost.delete({
      where: { post_id: postId }
    });

    return addCors(NextResponse.json({
      success: true,
      message: 'Post deleted successfully'
    }));
  } catch (error) {
    console.error('Error deleting community post:', error);
    return addCors(NextResponse.json(
      { success: false, error: 'Failed to delete post' },
      { status: 500 }
    ));
  }
}
