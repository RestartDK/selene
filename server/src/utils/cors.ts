/**
 * CORS headers for iOS client requests
 */
export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, PATCH, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Access-Control-Max-Age": "86400",
};

/**
 * Create a JSON response with CORS headers
 */
export function jsonResponse<T>(data: T, status = 200): Response {
  return Response.json(data, {
    status,
    headers: corsHeaders,
  });
}

/**
 * Create an error response with CORS headers
 */
export function errorResponse(message: string, status = 400): Response {
  return Response.json(
    { error: message },
    {
      status,
      headers: corsHeaders,
    }
  );
}

/**
 * Handle CORS preflight requests
 */
export function handlePreflight(): Response {
  return new Response(null, {
    status: 204,
    headers: corsHeaders,
  });
}

