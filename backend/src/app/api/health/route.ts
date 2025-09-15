import { NextRequest, NextResponse } from 'next/server';

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

// Handle GET request for health check
export async function GET(request: NextRequest) {
  try {
    console.log('🏥 Health check endpoint called');
    
    return NextResponse.json(
      { 
        status: 'ok',
        timestamp: new Date().toISOString(),
        message: 'Backend server is running'
      },
      { 
        status: 200, 
        headers: corsHeaders 
      }
    );
    
  } catch (error) {
    console.error('❌ Health check error:', error);
    return NextResponse.json(
      { 
        status: 'error',
        timestamp: new Date().toISOString(),
        message: 'Backend server error'
      },
      { 
        status: 500, 
        headers: corsHeaders 
      }
    );
  }
}
