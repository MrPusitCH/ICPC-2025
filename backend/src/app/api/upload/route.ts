import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { addCors } from '@/config/cors';

// Handle OPTIONS request for CORS preflight
export async function OPTIONS() {
  return addCors(new NextResponse(null, { status: 204 }));
}

// Handle POST request for file upload
export async function POST(request: NextRequest) {
  try {
    console.log('🚀 Upload endpoint called at:', new Date().toISOString());
    console.log('📋 Request headers:', Object.fromEntries(request.headers.entries()));
    console.log('📋 Content-Type:', request.headers.get('content-type'));
    console.log('📋 User-Agent:', request.headers.get('user-agent'));
    
    const contentType = request.headers.get('content-type');
    
    // Check if it's a JSON request (web platform with base64)
    if (contentType?.includes('application/json')) {
      return await handleBase64Upload(request);
    } else {
      // Handle multipart form data (mobile platform)
      return await handleMultipartUpload(request);
    }
    
  } catch (error) {
    console.error('❌ Error uploading file:', error);
    console.error('❌ Error stack:', (error as Error).stack);
    console.error('❌ Error name:', (error as Error).name);
    return addCors(NextResponse.json(
      { 
        error: 'Failed to upload file',
        details: (error as Error).message,
        timestamp: new Date().toISOString()
      },
      { status: 500 }
    ));
  }
}

// Handle base64 encoded uploads (web platform)
async function handleBase64Upload(request: NextRequest) {
  const body = await request.json();
  const { file: base64String, filename, mimeType } = body;
  
  console.log('Base64 upload received:', { 
    filename, 
    mimeType, 
    dataLength: base64String?.length 
  });
  
    if (!base64String) {
      return addCors(NextResponse.json(
        { error: 'No base64 file data provided' },
        { status: 400 }
      ));
    }
  
  // Validate file type
  const allowedTypes = [
    'image/png', 
    'image/jpeg', 
    'image/jpg', 
    'image/webp', 
    'image/gif', 
    'image/bmp', 
    'image/svg+xml'
  ];
  
  const detectedMimeType = mimeType || 'image/jpeg';
  if (!allowedTypes.includes(detectedMimeType)) {
    console.log('Invalid file type:', detectedMimeType);
    return addCors(NextResponse.json(
      { error: 'Invalid file type. Only PNG, JPG, JPEG, WEBP, GIF, BMP, and SVG are allowed.' },
      { status: 415 }
    ));
  }
  
  // Convert base64 to buffer
  const buffer = Buffer.from(base64String, 'base64');
  
  // Validate file size (8MB limit)
  const maxSize = 8 * 1024 * 1024; // 8MB
  if (buffer.length > maxSize) {
    console.log('File too large:', buffer.length);
    return addCors(NextResponse.json(
      { error: 'File too large. Maximum size is 8MB.' },
      { status: 413 }
    ));
  }
  
  // Store image in database as BLOB
  const imageRecord = await (prisma as any).image.create({
    data: {
      name: filename || 'uploaded-image',
      mime: detectedMimeType,
      bytes: buffer,
    },
  });
  
  console.log('Base64 file uploaded successfully to database:', { 
    id: imageRecord.id,
    name: imageRecord.name, 
    fileSize: buffer.length, 
    mimeType: imageRecord.mime,
    createdAt: imageRecord.created_at
  });
  
  // Return success response with database record info
  return addCors(NextResponse.json(
    { 
      id: imageRecord.id,
      name: imageRecord.name,
      mime: imageRecord.mime,
      fileSize: buffer.length,
      createdAt: imageRecord.created_at
    },
    { status: 200 }
  ));
}

// Handle multipart form data uploads (mobile platform)
async function handleMultipartUpload(request: NextRequest) {
  // Parse form data
  const formData = await request.formData();
  console.log('Form data received');
  console.log('Form data keys:', Array.from(formData.keys()));
  
  // Get the image file - support both 'file' and 'image' keys for compatibility
  const imageFile = (formData.get('file') || formData.get('image')) as File;
  console.log('Image file extracted:', imageFile ? { 
    name: imageFile.name, 
    size: imageFile.size, 
    type: imageFile.type 
  } : 'null');
  
  // Validate file exists
  if (!imageFile) {
    console.log('No image file provided');
    return addCors(NextResponse.json(
      { error: 'No image file provided' },
      { status: 400 }
    ));
  }
  
  // Validate file type - expanded to include more image types
  const allowedTypes = [
    'image/png', 
    'image/jpeg', 
    'image/jpg', 
    'image/webp', 
    'image/gif', 
    'image/bmp', 
    'image/svg+xml'
  ];
  if (!allowedTypes.includes(imageFile.type)) {
    console.log('Invalid file type:', imageFile.type);
    return addCors(NextResponse.json(
      { error: 'Invalid file type. Only PNG, JPG, JPEG, WEBP, GIF, BMP, and SVG are allowed.' },
      { status: 415 }
    ));
  }
  
  // Validate file size (8MB limit as requested)
  const maxSize = 8 * 1024 * 1024; // 8MB
  if (imageFile.size > maxSize) {
    console.log('File too large:', imageFile.size);
    return addCors(NextResponse.json(
      { error: 'File too large. Maximum size is 8MB.' },
      { status: 413 }
    ));
  }
  
  // Read file into buffer
  const buffer = Buffer.from(await imageFile.arrayBuffer());
  
  // Store image in database as BLOB
  const imageRecord = await (prisma as any).image.create({
    data: {
      name: imageFile.name,
      mime: imageFile.type,
      bytes: buffer,
    },
  });
  
  console.log('File uploaded successfully to database:', { 
    id: imageRecord.id,
    name: imageRecord.name, 
    fileSize: imageFile.size, 
    mimeType: imageRecord.mime,
    createdAt: imageRecord.created_at
  });
  
  // Return success response with database record info
  return addCors(NextResponse.json(
    { 
      id: imageRecord.id,
      name: imageRecord.name,
      mime: imageRecord.mime,
      fileSize: imageFile.size, // Include file size for frontend
      createdAt: imageRecord.created_at
    },
    { status: 200 }
  ));
}