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

// Handle GET request to fetch image by ID
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    
    // Validate ID parameter
    const imageId = parseInt(id);
    if (isNaN(imageId) || imageId <= 0) {
      return new NextResponse('Invalid image ID', { 
        status: 400, 
        headers: corsHeaders 
      });
    }
    
    // Query image from database
    const image = await (prisma as any).image.findUnique({
      where: { id: imageId },
      select: {
        id: true,
        name: true,
        mime: true,
        bytes: true,
        created_at: true,
      },
    });
    
    // Check if image exists
    if (!image) {
      return new NextResponse('Image not found', { 
        status: 404, 
        headers: corsHeaders 
      });
    }
    
    // Convert Buffer to Uint8Array for response
    const imageBuffer = Buffer.from(image.bytes);
    
    // Return image with proper headers
    return new NextResponse(imageBuffer, {
      status: 200,
      headers: {
        ...corsHeaders,
        'Content-Type': image.mime,
        'Content-Length': imageBuffer.length.toString(),
        'Cache-Control': 'public, max-age=60',
        'Content-Disposition': `inline; filename="${image.name || `image-${image.id}`}"`,
      },
    });
    
  } catch (error) {
    console.error('Error fetching image:', error);
    return new NextResponse('Internal server error', { 
      status: 500, 
      headers: corsHeaders 
    });
  }
}
