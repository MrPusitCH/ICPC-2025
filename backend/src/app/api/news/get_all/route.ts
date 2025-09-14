import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '@/config/cors';

const prisma = new PrismaClient();

// Handle CORS preflight requests
export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 200 }));
}

// GET /api/news/get_all - Get all news/announcements
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const page = parseInt(searchParams.get('page') || '1');
    const limit = parseInt(searchParams.get('limit') || '10');
    const skip = (page - 1) * limit;

    const news = await prisma.news.findMany({
      skip,
      take: limit,
      orderBy: { created_at: 'desc' },
      where: {
        is_published: true,
      },
      include: {
        author: {
          include: {
            profile: true
          }
        }
      }
    });

    const total = await prisma.news.count({
      where: {
        is_published: true,
      }
    });

    return addCors(NextResponse.json({
      success: true,
      data: news,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit)
      }
    }));
  } catch (error) {
    console.error('Error fetching news:', error);
    return addCors(NextResponse.json(
      { success: false, error: 'Failed to fetch news' },
      { status: 500 }
    ));
  }
}
