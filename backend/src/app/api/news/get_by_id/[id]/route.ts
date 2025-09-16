import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '@/config/cors';

const prisma = new PrismaClient();

// Handle CORS preflight requests
export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 200 }));
}

// GET /api/news/get_by_id/[id] - Get single news item by ID
export async function GET(
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

    const news = await prisma.news.findUnique({
      where: {
        news_id: newsId
      },
      include: {
        author: {
          include: {
            profile: true
          }
        }
      }
    });

    if (!news) {
      return addCors(NextResponse.json(
        {
          success: false,
          error: 'News not found'
        },
        { status: 404 }
      ));
    }

    return addCors(NextResponse.json({
      success: true,
      data: news
    }));
  } catch (error) {
    console.error('Error fetching news:', error);
    return addCors(NextResponse.json(
      {
        success: false,
        error: 'Failed to fetch news'
      },
      { status: 500 }
    ));
  }
}




