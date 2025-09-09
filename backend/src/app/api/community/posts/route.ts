import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '@/config/cors';

const prisma = new PrismaClient();

// Handle CORS preflight requests
export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 204 }));
}

// GET /api/community/posts - Get all community posts
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const page = parseInt(searchParams.get('page') || '1');
    const limit = parseInt(searchParams.get('limit') || '10');
    const skip = (page - 1) * limit;

    const posts = await prisma.communityPost.findMany({
      skip,
      take: limit,
      orderBy: { created_at: 'desc' },
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

    const total = await prisma.communityPost.count();

    return addCors(NextResponse.json({
      success: true,
      data: posts,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit)
      }
    }));
  } catch (error) {
    console.error('Error fetching community posts:', error);
    return addCors(NextResponse.json(
      { success: false, error: 'Failed to fetch posts' },
      { status: 500 }
    ));
  }
}

// POST /api/community/posts - Create a new community post
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { title, content, author_id, media } = body;

    if (!title || !content || !author_id) {
      return addCors(NextResponse.json(
        { success: false, error: 'Title, content, and author_id are required' },
        { status: 400 }
      ));
    }

    // Create the post
    const post = await prisma.communityPost.create({
      data: {
        title,
        content,
        author_id: parseInt(author_id),
        media: media ? {
          create: media.map((m: any) => ({
            file_url: m.file_url,
            file_type: m.file_type || 'image',
            file_name: m.file_name,
            file_size: m.file_size,
            mime_type: m.mime_type
          }))
        } : undefined
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
    }, { status: 201 }));
  } catch (error) {
    console.error('Error creating community post:', error);
    return addCors(NextResponse.json(
      { success: false, error: 'Failed to create post' },
      { status: 500 }
    ));
  }
}
