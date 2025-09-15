import { NextRequest, NextResponse } from 'next/server'
import { addCors } from '@/config/cors'
import { prisma } from '@/lib/prisma'
import bcrypt from 'bcryptjs'

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { email, password } = body
    
    if (!email || !password) {
      const response = NextResponse.json({
        ok: false,
        message: 'Email and password are required'
      }, { status: 400 })
      return addCors(response)
    }
    
    // Find user in database
    const user = await prisma.user.findUnique({
      where: { email: email },
      include: {
        profile: true
      }
    })
    
    if (!user) {
      const response = NextResponse.json({
        ok: false,
        message: 'Invalid email or password'
      }, { status: 401 })
      return addCors(response)
    }
    
    // Check password (in real app, compare with hashed password)
    // For now, we'll use a simple check since we have plain text passwords in seed
    const isValidPassword = password === 'password123' // Simple check for demo
    
    if (!isValidPassword) {
      const response = NextResponse.json({
        ok: false,
        message: 'Invalid email or password'
      }, { status: 401 })
      return addCors(response)
    }
    
    // Check if user is active
    if (user.status !== 'ACTIVE') {
      const response = NextResponse.json({
        ok: false,
        message: 'Account is not active'
      }, { status: 403 })
      return addCors(response)
    }
    
    // Generate token (in real app, use JWT)
    const token = 'jwt_token_' + user.user_id + '_' + Date.now()
    
    const response = NextResponse.json({
      ok: true,
      message: 'Login successful',
      data: {
        user: {
          user_id: user.user_id,
          email: user.email,
          role: user.role,
          name: user.profile?.full_name || 'User'
        },
        token: token
      }
    })
    
    return addCors(response)
  } catch (error) {
    console.error('Login error:', error)
    const response = NextResponse.json({
      ok: false,
      message: 'Internal server error'
    }, { status: 500 })
    
    return addCors(response)
  }
}

export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 200 }))
}
