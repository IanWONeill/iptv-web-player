/**
 * Cloudflare Worker for CORS Proxy
 * 
 * Deploy this to Cloudflare Workers to handle CORS for M3U8 playlists and HLS segments
 * 
 * Setup:
 * 1. Create a new Worker at workers.cloudflare.com
 * 2. Copy this code into the Worker editor
 * 3. Deploy and note your Worker URL (e.g., https://your-worker.workers.dev)
 * 4. Add the Worker URL to your .env file as CORS_PROXY_URL
 */

addEventListener('fetch', event => {
    event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
    // Only allow GET and OPTIONS methods
    if (request.method === 'OPTIONS') {
        return handleOptions(request)
    } else if (request.method !== 'GET') {
        return new Response('Method not allowed', { status: 405 })
    }

    // Get the target URL from query parameters
    const url = new URL(request.url)
    const targetUrl = url.searchParams.get('url')

    if (!targetUrl) {
        return new Response('Missing url parameter', {
            status: 400,
            headers: {
                'Content-Type': 'text/plain',
            }
        })
    }

    try {
        // Validate URL
        const target = new URL(targetUrl)

        // Fetch the target URL
        const response = await fetch(targetUrl, {
            method: 'GET',
            headers: {
                'User-Agent': request.headers.get('User-Agent') || 'Mozilla/5.0',
                'Referer': target.origin,
            }
        })

        // Get content type to determine if we need to rewrite URLs
        const contentType = response.headers.get('Content-Type') || ''
        const isM3u8 = contentType.includes('mpegurl') ||
            contentType.includes('m3u8') ||
            targetUrl.endsWith('.m3u8')

        let body = await response.arrayBuffer()

        // If this is an M3U8 playlist, rewrite segment URLs
        if (isM3u8) {
            const text = new TextDecoder().decode(body)
            const rewritten = await rewriteM3u8(text, targetUrl, request.url.split('?')[0])
            body = new TextEncoder().encode(rewritten)
        }

        // Create response with CORS headers
        const headers = new Headers(response.headers)
        headers.set('Access-Control-Allow-Origin', '*')
        headers.set('Access-Control-Allow-Methods', 'GET, OPTIONS')
        headers.set('Access-Control-Allow-Headers', 'Content-Type, Range')
        headers.set('Access-Control-Expose-Headers', 'Content-Length, Content-Range, Accept-Ranges')

        return new Response(body, {
            status: response.status,
            statusText: response.statusText,
            headers: headers
        })

    } catch (error) {
        return new Response(`Proxy error: ${error.message}`, {
            status: 500,
            headers: {
                'Content-Type': 'text/plain',
                'Access-Control-Allow-Origin': '*',
            }
        })
    }
}

// Handle CORS preflight requests
function handleOptions(request) {
    const headers = new Headers({
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Range',
        'Access-Control-Max-Age': '86400',
    })

    return new Response(null, {
        status: 204,
        headers: headers
    })
}

// Rewrite M3U8 playlist to proxy all segment URLs
async function rewriteM3u8(content, originalUrl, proxyBase) {
    const lines = content.split('\n')
    const baseUrl = new URL(originalUrl)
    const rewritten = []

    for (const line of lines) {
        const trimmed = line.trim()

        // Skip comments and empty lines
        if (trimmed.startsWith('#') || trimmed === '') {
            rewritten.push(line)
            continue
        }

        // This is a segment or sub-playlist URL
        let segmentUrl = trimmed

        // Resolve relative URLs
        if (!segmentUrl.startsWith('http://') && !segmentUrl.startsWith('https://')) {
            segmentUrl = new URL(segmentUrl, baseUrl.href).href
        }

        // Proxy the segment URL
        const proxiedUrl = `${proxyBase}?url=${encodeURIComponent(segmentUrl)}`
        rewritten.push(proxiedUrl)
    }

    return rewritten.join('\n')
}
