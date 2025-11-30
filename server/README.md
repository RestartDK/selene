# Selene Backend API

A Bun-native HTTP server for the Selene nightlife discovery app.

## Quick Start

```bash
# Install dependencies
bun install

# Set up environment
cp .env.example .env
# Edit .env with your OPENAI_API_KEY

# Run development server
bun run dev

# Or production
bun run start
```

The server runs on `http://localhost:3000` by default (configurable via `PORT` env var).

## Architecture

Built using **Bun's native `Bun.serve()`** HTTP server with:
- Zero external frameworks (no Hono, Express, etc.)
- JSON file-based data storage with caching
- Vercel AI SDK for Selene agent streaming
- CORS enabled for iOS client

## Project Structure

```
server/
├── src/
│   ├── index.ts              # Bun.serve entry point & routing
│   ├── routes/
│   │   ├── venues.ts         # Venue endpoints
│   │   ├── social.ts         # Friend/interest queries
│   │   ├── invites.ts        # Invite management
│   │   ├── bookings.ts       # Mock booking service
│   │   └── agent.ts          # Selene AI agent streaming
│   ├── services/
│   │   ├── selene-agent.ts     # Vercel AI SDK integration
│   │   └── feed-builder.ts   # Feed with social state enrichment
│   ├── db/
│   │   ├── index.ts          # JSON loader/saver utilities
│   │   └── data/             # JSON data files
│   │       ├── users.json
│   │       ├── venues.json
│   │       ├── interests.json
│   │       ├── invites.json
│   │       └── bookings.json
│   ├── types/
│   │   └── index.ts          # Shared TypeScript types
│   └── utils/
│       ├── cors.ts           # CORS headers helper
│       └── nanoid.ts         # ID generator
├── package.json
└── tsconfig.json
```

## API Endpoints

### Health Check
- `GET /health` - Server status

### Venues
- `GET /venues` - List all venues (enriched with social state)
- `GET /venues/:id` - Get single venue details
- `POST /venues/:id/heart` - Mark venue as interested
- `DELETE /venues/:id/heart` - Remove interest

### Social
- `GET /social/friends` - Get current user's friend list
- `GET /social/interested/:venueId` - Get friends interested in venue
- `GET /users/me` - Get current user profile

### Invites
- `GET /invites` - Get user's invites (sent and received)
- `POST /invites` - Create invite(s)
  ```json
  {
    "venueId": "blue-note",
    "toUserIds": ["sarah", "mike"],
    "proposedTime": "2024-01-20T20:00:00Z"
  }
  ```
- `PATCH /invites/:id` - Accept/decline invite
  ```json
  { "status": "accepted" }
  ```

### Bookings
- `GET /bookings` - Get user's bookings
- `POST /bookings` - Create mock booking
  ```json
  {
    "venueId": "rooftop-99",
    "partySize": 4,
    "dateTime": "2024-01-20T21:00:00Z",
    "guestIds": ["sarah"]
  }
  ```

### Agent (Selene)
- `GET /agent/suggestion` - Get proactive booking suggestion with smart reasoning
  - Query params: `venueId` (required)
  - Returns:
    ```json
    {
      "venueId": "blue-note",
      "venueName": "Blue Note Jazz Club",
      "friendNames": ["Sarah", "Mike"],
      "friendIds": ["sarah-uuid", "mike-uuid"],
      "partySize": 3,
      "suggestedTime": "2024-11-30T21:00:00Z",
      "reasoning": "You and Sarah both love jazz spots - Blue Note would be perfect for tonight!",
      "sharedInterests": ["Jazz Club", "Live Music"]
    }
    ```

- `POST /agent/chat` - Streaming chat with Selene AI
  ```json
  {
    "message": "Find me a jazz spot for tonight",
    "conversationHistory": []
  }
  ```
  Returns Server-Sent Events (SSE) stream.

#### Agent Tools

The Selene agent has access to two tools for automated actions:

1. **bookTable** - Creates reservations at venues
   - Parameters: `venueId`, `partySize`, `dateTime`, `guestIds[]`
   - Returns confirmation code and booking details

2. **sendInvites** - Sends invitations to friends
   - Parameters: `venueId`, `toUserIds[]`, `proposedTime`
   - Returns success message and invite count

### Media
- `GET /media/:filename` - Serve media files (videos and images)
  - Supports byte-range requests for video streaming
  - Content types: `video/mp4`, `image/jpeg`, `image/png`
  - Files located in `src/db/data/media/`

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | `3000` |
| `CURRENT_USER_ID` | Simulated auth user | `550e8400-e29b-41d4-a716-446655440000` |
| `GOOGLE_GENERATIVE_AI_API_KEY` | Google AI API key | Required for Selene agent |

## Mock Data

Pre-seeded with:
- **3 Users**: Alex, Sarah, Mike (mutual friends)
- **3 Venues**: Blue Note Jazz Club, Rooftop 99, Omen Coffee
- **Interests**: Sarah & Mike interested in Blue Note and Rooftop
- **Invites**: Pending invite from Sarah to Alex for Blue Note
