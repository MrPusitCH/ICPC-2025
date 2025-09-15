import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

// CORS headers for development
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

// Handle OPTIONS request for CORS preflight
export async function OPTIONS() {
  return new NextResponse(null, {
    status: 204,
    headers: corsHeaders,
  });
}

// Handle GET request to list images (metadata only)
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const page = parseInt(searchParams.get('page') || '1');
    const limit = Math.min(parseInt(searchParams.get('limit') || '50'), 100); // Max 100 per request
    const skip = (page - 1) * limit;
    
    // Query images from database (metadata only, no bytes)
    const images = await (prisma as any).image.findMany({
      skip,
      take: limit,
      select: {
        id: true,
        name: true,
        mime: true,
        created_at: true,
      },
      orderBy: {
        created_at: 'desc',
      },
    });
    
    // Get total count for pagination
    const total = await (prisma as any).image.count();
    
    // Return success response with image metadata
    return NextResponse.json(
      {
        success: true,
        data: images,
        pagination: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit),
        },
      },
      { 
        status: 200, 
        headers: corsHeaders 
      }
    );
    
  } catch (error) {
    console.error('Error fetching images:', error);
    return NextResponse.json(
      { 
        success: false, 
        error: 'Failed to fetch images' 
      },
      { 
        status: 500, 
        headers: corsHeaders 
      }
    );
  }
}
