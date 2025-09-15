import { NextResponse } from 'next/server'

export function addCors(res: NextResponse) {
  res.headers.set('Access-Control-Allow-Origin', '*')
  res.headers.set('Access-Control-Allow-Methods', 'GET,POST,PUT,DELETE,OPTIONS')
  res.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization, Accept')
  res.headers.set('Access-Control-Allow-Credentials', 'true')
  res.headers.set('Access-Control-Max-Age', '86400')
  
  return res
}


