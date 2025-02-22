import { NextResponse, NextRequest } from 'next/server'

// This function can be marked `async` if using `await` inside
export function middleware(request: NextRequest) {
    //   return NextResponse.redirect(new URL('/home', request.url))
    const role = request.cookies.get('role')?.value
    // console.log('token', token)

    if (request.nextUrl.pathname === '/') {
        if (role === 'Creator') {
            return NextResponse.redirect(new URL('/creator/dashboard', request.url))
        } else if (role === 'Brand') {
            return NextResponse.redirect(new URL('/brand', request.url))
        } else if (role === 'Reader') {
            return NextResponse.redirect(new URL('/reader/dashboard', request.url))
        }
        return NextResponse.next()
    }

    if (!role) {
        return NextResponse.redirect(new URL('/', request.url))
    }
    // return NextResponse.redirect(new URL('/dashboard', request.url))

}

// See "Matching Paths" below to learn more
export const config = {
    matcher: ['/', '/creator/*', '/brand', '/reader/*', 'token/']
}