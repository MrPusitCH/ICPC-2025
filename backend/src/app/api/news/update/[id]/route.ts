import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '@/config/cors';

const prisma = new PrismaClient();

// Handle CORS preflight requests
export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 200 }));
}

// PUT /api/news/update/[id] - Update a news item by ID
export async function PUT(
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

    const body = await request.json();
    const { 
      title, 
      content, 
      priority,
      image_url,
      image_name,
      date_time,
      disclaimer
    } = body;

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

    // Validate priority if provided
    if (priority) {
      const validPriorities = ['important', 'caution', 'notice'];
      if (!validPriorities.includes(priority)) {
        return addCors(NextResponse.json(
          {
            success: false,
            error: 'Priority must be one of: important, caution, notice'
          },
          { status: 400 }
        ));
      }
    }

    const news = await prisma.news.update({
      where: { news_id: newsId },
      data: {
        ...(title && { title }),
        ...(content && { content }),
        ...(priority && { priority }),
        ...(image_url !== undefined && { image_url }),
        ...(image_name !== undefined && { image_name }),
        ...(date_time !== undefined && { date_time }),
        ...(disclaimer !== undefined && { disclaimer }),
      },
      include: {
        author: {
          include: {
            profile: true
          }
        }
      }
    });

    return addCors(NextResponse.json({
      success: true,
      data: news
    }));
  } catch (error) {
    console.error('Error updating news:', error);
    return addCors(NextResponse.json(
      {
        success: false,
        error: 'Failed to update news'
      },
      { status: 500 }
    ));
  }
}
