import { NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '@/config/cors';

const prisma = new PrismaClient();

// Type assertion to help TypeScript recognize the post property
const prismaWithPost = prisma as any;

// Handle CORS preflight requests
export async function OPTIONS() {
  return addCors(new NextResponse(null, { status: 200 }));
}

// GET /api/posts/get - Fetch all posts with user info, ordered by createdAt desc
export async function GET() {
  try {
    const posts = await prismaWithPost.post.findMany({
      include: {
        user: {
          include: {
            profile: true
          }
        }
      },
      orderBy: {
        created_at: 'desc'
      }
    });

    return addCors(NextResponse.json({
      success: true,
      data: posts
    }));
  } catch (error) {
    console.error('Error fetching posts:', error);
    return addCors(NextResponse.json(
      {
        success: false,
        error: 'Failed to fetch posts'
      },
      { status: 500 }
    ));
  }
}
