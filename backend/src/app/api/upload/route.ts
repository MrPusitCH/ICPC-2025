import { NextRequest, NextResponse } from 'next/server';
import { writeFile, mkdir } from 'fs/promises';
import { join } from 'path';
import { existsSync } from 'fs';

// CORS headers for development
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

// Handle OPTIONS request for CORS preflight
export async function OPTIONS() {
  return new NextResponse(null, {
    status: 204,
    headers: corsHeaders,
  });
}

// Handle POST request for file upload
export async function POST(request: NextRequest) {
  try {
    console.log('Upload endpoint called');
    console.log('Request headers:', Object.fromEntries(request.headers.entries()));
    console.log('Content-Type:', request.headers.get('content-type'));
    
    // Parse form data
    const formData = await request.formData();
    console.log('Form data received');
    console.log('Form data keys:', Array.from(formData.keys()));
    
    // Get the image file
    const imageFile = formData.get('image') as File;
    console.log('Image file extracted:', imageFile ? { 
      name: imageFile.name, 
      size: imageFile.size, 
      type: imageFile.type 
    } : 'null');
    
    // Validate file exists
    if (!imageFile) {
      console.log('No image file provided');
      return NextResponse.json(
        { error: 'No image file provided' },
        { status: 400, headers: corsHeaders }
      );
    }
    
    // Validate file type
    const allowedTypes = ['image/png', 'image/jpeg', 'image/jpg', 'image/webp'];
    if (!allowedTypes.includes(imageFile.type)) {
      console.log('Invalid file type:', imageFile.type);
      return NextResponse.json(
        { error: 'Invalid file type. Only PNG, JPG, JPEG, and WEBP are allowed.' },
        { status: 400, headers: corsHeaders }
      );
    }
    
    // Validate file size (10MB limit)
    const maxSize = 10 * 1024 * 1024; // 10MB
    if (imageFile.size > maxSize) {
      console.log('File too large:', imageFile.size);
      return NextResponse.json(
        { error: 'File too large. Maximum size is 10MB.' },
        { status: 400, headers: corsHeaders }
      );
    }
    
    // Ensure uploads directory exists
    const uploadsDir = join(process.cwd(), 'public', 'uploads');
    if (!existsSync(uploadsDir)) {
      console.log('Creating uploads directory');
      await mkdir(uploadsDir, { recursive: true });
    }
    
    // Generate unique filename
    const timestamp = Date.now();
    const randomSuffix = Math.random().toString(36).substring(2, 8);
    const originalName = imageFile.name;
    const extension = originalName.split('.').pop() || 'jpg';
    const sanitizedName = originalName
      .replace(/[^a-zA-Z0-9.-]/g, '_') // Replace special chars with underscore
      .replace(/\s+/g, '_') // Replace spaces with underscore
      .toLowerCase();
    
    const uniqueFileName = `${timestamp}-${randomSuffix}-${sanitizedName}`;
    const filePath = join(uploadsDir, uniqueFileName);
    
    // Save file
    const buffer = Buffer.from(await imageFile.arrayBuffer());
    await writeFile(filePath, buffer);
    
    // Get base URL from environment
    const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || 'http://localhost:3000';
    const imageUrl = `${baseUrl}/uploads/${uniqueFileName}`;
    
    console.log('File uploaded successfully:', { 
      fileName: uniqueFileName, 
      fileSize: imageFile.size, 
      mimeType: imageFile.type,
      imageUrl 
    });
    
    // Return success response
    return NextResponse.json(
      { 
        url: imageUrl,
        fileName: uniqueFileName,
        fileSize: imageFile.size,
        mimeType: imageFile.type
      },
      { status: 200, headers: corsHeaders }
    );
    
  } catch (error) {
    console.error('Error uploading file:', error);
    return NextResponse.json(
      { error: 'Failed to upload file' },
      { status: 500, headers: corsHeaders }
    );
  }
}