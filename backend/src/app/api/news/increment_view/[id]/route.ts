import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '@/config/cors';

const prisma = new PrismaClient();

// Handle CORS preflight requests
export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 200 }));
}

// POST /api/news/increment_view/[id] - Increment view count for a news item
export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const newsId = parseInt(id);

    if (isNaN(newsId)) {
      return addCors(NextResponse.json(
        {
          success: false,
          error: 'Invalid news ID'
        },
        { status: 400 }
      ));
    }

    // Check if news exists
    const existingNews = await prisma.news.findUnique({
      where: { news_id: newsId }
    });

    if (!existingNews) {
      return addCors(NextResponse.json(
        {
          success: false,
          error: 'News not found'
        },
        { status: 404 }
      ));
    }

    // Increment view count
    await prisma.news.update({
      where: { news_id: newsId },
      data: {
        view_count: {
          increment: 1
        }
      }
    });

    return addCors(NextResponse.json({
      success: true,
      message: 'View count incremented'
    }));
  } catch (error) {
    console.error('Error incrementing view count:', error);
    return addCors(NextResponse.json(
      {
        success: false,
        error: 'Failed to increment view count'
      },
      { status: 500 }
    ));
  }
}
