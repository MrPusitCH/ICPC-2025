import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { addCors } from '@/config/cors';

// Handle CORS preflight requests
export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 204 }));
}

// GET /api/community/posts - Get all community posts
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const page = parseInt(searchParams.get('page') || '1');
    const limit = parseInt(searchParams.get('limit') || '10');
    const skip = (page - 1) * limit;

    const posts = await prisma.communityPost.findMany({
      skip,
      take: limit,
      orderBy: { created_at: 'desc' },
      include: {
        author: {
          include: {
            profile: true
          }
        },
        media: true,
        _count: {
          select: {
            comments: true,
            likes: true
          }
        }
      }
    });

    const total = await prisma.communityPost.count();

    return addCors(NextResponse.json({
      success: true,
      data: posts,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit)
      }
    }));
  } catch (error) {
    console.error('Error fetching community posts:', error);
    return addCors(NextResponse.json(
      { success: false, error: 'Failed to fetch posts' },
      { status: 500 }
    ));
  }
}

// POST /api/community/posts - Create a new community post
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { title, content, author_id, media } = body;

    console.log('Creating post with data:', { title, content, author_id, media });

    if (!title || !content || !author_id) {
      return addCors(NextResponse.json(
        { success: false, error: 'Title, content, and author_id are required' },
        { status: 400 }
      ));
    }

    // Create the post first
    console.log('Creating post with media:', media);
    const post = await prisma.communityPost.create({
      data: {
        title,
        content,
        author_id: parseInt(author_id),
      },
    });

    // Create media records if provided
    if (media && media.length > 0) {
      console.log('Creating media records for post:', post.post_id);
      console.log('Media data received:', JSON.stringify(media, null, 2));
      
      for (const mediaItem of media) {
        try {
          console.log('Creating media record with data:', {
            post_id: post.post_id,
            image_id: mediaItem.image_id,
            file_name: mediaItem.file_name,
            file_size: mediaItem.file_size,
            mime_type: mediaItem.mime_type
          });
          
          // Validate required fields
          if (!mediaItem.image_id) {
            console.error('Missing image_id in media item:', mediaItem);
            throw new Error('Missing image_id in media item');
          }
          
          const mediaRecord = await prisma.postMedia.create({
            data: {
              post_id: post.post_id,
              image_id: parseInt(mediaItem.image_id), // Ensure it's an integer
              file_url: mediaItem.file_url, // Keep for backward compatibility
              file_type: mediaItem.file_type || 'image',
              file_name: mediaItem.file_name,
              file_size: mediaItem.file_size ? parseInt(mediaItem.file_size) : null,
              mime_type: mediaItem.mime_type
            } as any // Temporary type assertion to bypass TypeScript error
          });
          
          console.log('Media record created successfully:', mediaRecord.media_id);
        } catch (error) {
          console.error('Error creating media record:', error);
          console.error('Media item that failed:', mediaItem);
          throw error;
        }
      }
      console.log('All media records created successfully');
    } else {
      console.log('No media provided for post');
    }

    // Fetch the complete post with all relations
    const completePost = await prisma.communityPost.findUnique({
      where: { post_id: post.post_id },
      include: {
        author: {
          include: {
            profile: true
          }
        },
        media: true,
        _count: {
          select: {
            comments: true,
            likes: true
          }
        }
      }
    });

    console.log('Post created successfully:', { 
      post_id: completePost?.post_id, 
      title: completePost?.title, 
      media_count: completePost?.media?.length || 0 
    });

    return addCors(NextResponse.json({
      success: true,
      data: completePost
    }, { status: 201 }));
  } catch (error) {
    console.error('Error creating community post:', error);
    return addCors(NextResponse.json(
      { success: false, error: 'Failed to create post' },
      { status: 500 }
    ));
  }
}
