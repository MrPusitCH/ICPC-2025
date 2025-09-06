import { NextRequest, NextResponse } from 'next/server'
import { addCors } from '@/config/cors'

export async function POST(request: NextRequest) {
  // TODO: Implement actual logout logic (invalidate token, etc.)
  const response = NextResponse.json({
    ok: true,
    message: 'Logout successful'
  })
  
  return addCors(response)
}

export async function OPTIONS(request: NextRequest) {
  return addCors(new NextResponse(null, { status: 200 }))
}
