import type { AgentChatRequest } from "../types";
import { streamLunaChat } from "../services/agent";
import { errorResponse, corsHeaders } from "../utils/cors";

/**
 * POST /agent/chat - Streaming chat with Luna agent
 * Returns Server-Sent Events (SSE) stream
 */
export async function agentChat(req: Request): Promise<Response> {
  try {
    const body = (await req.json()) as AgentChatRequest;

    if (!body.message) {
      return errorResponse("Missing required field: message", 400);
    }

    const result = await streamLunaChat(body);

    // Create SSE stream
    const stream = new ReadableStream({
      async start(controller) {
        const encoder = new TextEncoder();

        try {
          for await (const chunk of result.textStream) {
            const data = `data: ${JSON.stringify({ type: "text", content: chunk })}\n\n`;
            controller.enqueue(encoder.encode(data));
          }

          // Send final message
          controller.enqueue(
            encoder.encode(`data: ${JSON.stringify({ type: "done" })}\n\n`)
          );
          controller.close();
        } catch (error) {
          const errorMessage =
            error instanceof Error ? error.message : "Stream error";
          controller.enqueue(
            encoder.encode(
              `data: ${JSON.stringify({ type: "error", error: errorMessage })}\n\n`
            )
          );
          controller.close();
        }
      },
    });

    return new Response(stream, {
      status: 200,
      headers: {
        ...corsHeaders,
        "Content-Type": "text/event-stream",
        "Cache-Control": "no-cache",
        Connection: "keep-alive",
      },
    });
  } catch (error) {
    console.error("Agent chat error:", error);
    return errorResponse("Failed to process chat request", 500);
  }
}

