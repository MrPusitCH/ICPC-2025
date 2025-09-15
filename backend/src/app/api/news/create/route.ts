import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { addCors } from '@/config/cors';

const prisma = new PrismaClient();

// Handle CORS preflight requests
export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 200 }));
}

// POST /api/news/create - Create a new news/announcement
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { 
      title, 
      content, 
      priority = 'notice',
      image_url,
      image_name,
      date_time,
      disclaimer,
      author_id 
    } = body;

    // Validate required fields
    if (!title || !content || !author_id) {
      return addCors(NextResponse.json(
        {
          success: false,
          error: 'Title, content, and author_id are required'
        },
        { status: 400 }
      ));
    }

    // Validate priority
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

    // Check if author exists
    const author = await prisma.user.findUnique({
      where: { user_id: author_id }
    });

    if (!author) {
      return addCors(NextResponse.json(
        {
          success: false,
          error: 'Author not found'
        },
        { status: 404 }
      ));
    }

    const news = await prisma.news.create({
      data: {
        title,
        content,
        priority,
        image_url,
        image_name,
        date_time,
        disclaimer,
        author_id,
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
    }, { status: 201 }));
  } catch (error) {
    console.error('Error creating news:', error);
    return addCors(NextResponse.json(
      {
        success: false,
        error: 'Failed to create news'
      },
      { status: 500 }
    ));
  }
}


