import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '@/config/cors';

const prisma = new PrismaClient();

// Handle CORS preflight requests
export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 200 }));
}

// DELETE /api/news/delete/[id] - Delete a news item by ID
export async function DELETE(
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

    // Delete the news
    await prisma.news.delete({
      where: { news_id: newsId }
    });

    return addCors(NextResponse.json({
      success: true,
      message: 'News deleted successfully'
    }));
  } catch (error) {
    console.error('Error deleting news:', error);
    return addCors(NextResponse.json(
      {
        success: false,
        error: 'Failed to delete news'
      },
      { status: 500 }
    ));
  }
}




