import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export interface AuthUser {
  user_id: number;
  role: string;
  email: string;
}

export async function getCurrentUser(authHeader: string | null): Promise<AuthUser | null> {
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return null;
  }

  const token = authHeader.substring(7);
  
  try {
    let userId: number;
    
    // Check if token is in format: jwt_token_${user_id}_${timestamp}
    if (token.startsWith('jwt_token_')) {
      const parts = token.split('_');
      if (parts.length >= 3) {
        userId = parseInt(parts[2]);
      } else {
        console.log('Invalid token format:', token);
        return null;
      }
    } else {
      // Try to parse as user ID directly
      userId = parseInt(token);
    }
    
    if (isNaN(userId)) {
      console.log('Token is not a valid user ID:', token);
      return null;
    }

    const user = await prisma.user.findUnique({
      where: { user_id: userId },
      select: {
        user_id: true,
        role: true,
        email: true
      }
    });

    if (!user) {
      console.log('User not found for ID:', userId);
      return null;
    }

    console.log('Found user:', user);
    return user;
  } catch (error) {
    console.error('Auth error:', error);
    return null;
  }
}

export function isAdmin(user: AuthUser | null): boolean {
  return user?.role === 'ADMIN';
}

export function isAuthor(user: AuthUser | null, authorId: number): boolean {
  return user?.user_id === authorId;
}

export function canDeletePost(user: AuthUser | null, authorId: number): boolean {
  return isAuthor(user, authorId) || isAdmin(user);
}
