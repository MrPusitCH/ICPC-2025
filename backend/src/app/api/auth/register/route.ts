import { NextRequest, NextResponse } from 'next/server'
import { addCors } from '@/config/cors'

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { email, password, fullName, role, phone } = body
    
    // TODO: Implement actual registration logic with Prisma
    // For now, return placeholder response with validation
    if (!email || !password || !fullName) {
      const response = NextResponse.json({
        ok: false,
        message: 'Email, password, and full name are required'
      }, { status: 400 })
      return addCors(response)
    }
    
    // Mock registration - in real implementation, save to database
    const response = NextResponse.json({
      ok: true,
      message: 'Registration successful',
      data: {
        user: {
          id: Date.now(),
          email: email,
          role: role || 'USER',
          name: fullName,
          phone: phone || null
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
