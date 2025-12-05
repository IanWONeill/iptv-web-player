// Service Worker for CORS bypass
// This worker intercepts network requests and can modify headers

const CACHE_NAME = 'iptv-player-v1';
const CORS_PROXY_ENABLED = true;

// Install event - cache static assets
self.addEventListener('install', (event) => {
  console.log('Service Worker installing...');
  self.skipWaiting();
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  console.log('Service Worker activating...');
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter((name) => name !== CACHE_NAME)
          .map((name) => caches.delete(name))
      );
    })
  );
  return self.clients.claim();
});

// Fetch event - intercept network requests
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);
  
  // Only proxy media requests (M3U8, TS segments)
  const isMediaRequest = 
    url.pathname.endsWith('.m3u8') ||
    url.pathname.endsWith('.ts') ||
    url.pathname.endsWith('.m3u') ||
    url.searchParams.has('stream');
  
  if (CORS_PROXY_ENABLED && isMediaRequest) {
    event.respondWith(handleCorsRequest(event.request));
  } else {
    // For non-media requests, use default fetch
    event.respondWith(fetch(event.request));
  }
});

// Handle CORS requests with header modification
async function handleCorsRequest(request) {
  try {
    // Make the request with no-cors mode
    const response = await fetch(request, {
      mode: 'cors',
      credentials: 'omit',
      headers: {
        'Origin': self.location.origin,
      }
    });
    
    // Clone the response to modify headers
    const modifiedHeaders = new Headers(response.headers);
    modifiedHeaders.set('Access-Control-Allow-Origin', '*');
    modifiedHeaders.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    modifiedHeaders.set('Access-Control-Allow-Headers', 'Content-Type');
    
    // Create new response with modified headers
    const modifiedResponse = new Response(response.body, {
      status: response.status,
      statusText: response.statusText,
      headers: modifiedHeaders
    });
    
    return modifiedResponse;
  } catch (error) {
    console.error('Service Worker fetch error:', error);
    
    // Return a fallback response
    return new Response('Service Worker: Failed to fetch resource', {
      status: 503,
      statusText: 'Service Unavailable',
      headers: new Headers({
        'Content-Type': 'text/plain',
      })
    });
  }
}

// Message event - communicate with main app
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});
