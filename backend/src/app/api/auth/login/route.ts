import { NextRequest, NextResponse } from 'next/server'
import { addCors } from '@/config/cors'

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { email, password } = body
    
    // TODO: Implement actual login logic with Prisma
    // For now, return placeholder response with validation
    if (!email || !password) {
      const response = NextResponse.json({
        ok: false,
        message: 'Email and password are required'
      }, { status: 400 })
      return addCors(response)
    }
    
    // Mock authentication - in real implementation, check against database
    const response = NextResponse.json({
      ok: true,
      message: 'Login successful',
      data: {
        user: {
          id: 1,
          email: email,
          role: 'USER',
          name: 'Test User'
        },
        token: 'mock_jwt_token_' + Date.now()
      }
    })
    
    return addCors(response)
  } catch (error) {
    const response = NextResponse.json({
      ok: false,
      message: 'Invalid request body'
    }, { status: 400 })
    
    return addCors(response)
  }
}

export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 200 }))
}
