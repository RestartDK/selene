<!-- e91cb562-94e7-4f7b-9f0e-e4dfd9305919 fd15772f-1ba4-4f40-bc16-4b09e7e691fa -->
# Selene Backend Implementation Plan

## Project Setup

Create `server/` directory with the following structure:

```
server/
├── src/
│   ├── index.ts              # Hono app entry point
│   ├── routes/
│   │   ├── venues.ts         # Venue endpoints
│   │   ├── social.ts         # Friend/interest queries
│   │   ├── invites.ts        # Invite management
│   │   ├── bookings.ts       # Mock booking service
│   │   └── agent.ts          # Luna AI agent streaming
│   ├── services/
│   │   ├── agent.ts          # Vercel AI SDK integration (Luna)
│   │   └── feed-builder.ts   # Feed with social state enrichment
│   ├── db/
│   │   ├── index.ts          # JSON loader/saver utilities
│   │   └── data/             # JSON data files
│   │       ├── users.json
│   │       ├── venues.json
│   │       ├── interests.json
│   │       ├── invites.json
│   │       └── bookings.json
│   └── types/
│       └── index.ts          # Shared TypeScript types
├── package.json
├── tsconfig.json
└── .env.example
```

---

## Key Implementation Details

### 1. Entry Point (`src/index.ts`)

- Initialize Hono app with CORS middleware for iOS client
- Mount route handlers for `/venues`, `/social`, `/invites`, `/bookings`, `/agent`
- Configure error handling and logging
- Export for Bun runtime

### 2. Data Layer (`src/db/index.ts`)

Generic JSON utilities:

- `loadData<T>(filename)` - Read and parse JSON file
- `saveData<T>(filename, data)` - Write JSON with atomic save
- Cache layer for frequently accessed data (users, venues)

### 3. Type Definitions (`src/types/index.ts`)

```typescript
// Core models matching iOS app
interface User {
  id: string;
  name: string;
  avatarUrl: string;
  vibeStatus: "ready_to_mingle" | "chilling" | "exploring";
  friends: string[];
}

interface Venue {
  id: string;
  name: string;
  type: string;
  vibe: string;
  description: string;
  location: { address: string; distance: string; lat: number; lng: number };
  mediaUrl: string;
  thumbnailUrl: string;
}

interface Interest { id: string; userId: string; venueId: string; createdAt: string; }
interface Invite { id: string; venueId: string; fromUserId: string; toUserId: string; status: "pending" | "accepted" | "declined"; proposedTime: string; createdAt: string; }
interface Booking { id: string; venueId: string; userId: string; guests: string[]; partySize: number; dateTime: string; status: "confirmed" | "pending" | "cancelled"; confirmationCode: string; createdAt: string; }
```

---

## API Routes

### 4. Venues Routes (`src/routes/venues.ts`)

| Endpoint | Description |

|----------|-------------|

| `GET /venues` | List all venues with social state enrichment |

| `GET /venues/:id` | Get single venue with interested friends |

| `POST /venues/:id/heart` | Mark as interested (create Interest) |

| `DELETE /venues/:id/heart` | Remove interest |

The feed endpoint enriches each venue with:

- `interestedFriends: User[]` - Friends who hearted this venue
- `mutualCount: number` - Count of non-friend users interested
- `inviteState: Invite | null` - Active invite for current user

### 5. Social Routes (`src/routes/social.ts`)

| Endpoint | Description |

|----------|-------------|

| `GET /social/interested/:venueId` | Get friends interested in specific venue |

| `GET /social/friends` | Get current user's friend list |

| `GET /users/me` | Get current user profile |

### 6. Invites Routes (`src/routes/invites.ts`)

| Endpoint | Description |

|----------|-------------|

| `GET /invites` | Get user's pending invites |

| `POST /invites` | Create invite (venueId, toUserIds, proposedTime) |

| `PATCH /invites/:id` | Accept or decline invite |

### 7. Bookings Routes (`src/routes/bookings.ts`)

| Endpoint | Description |

|----------|-------------|

| `POST /bookings` | Create mock booking (returns confirmation code) |

| `GET /bookings` | Get user's bookings |

Mock booking service simulates 1-2 second delay then returns confirmation.

### 8. Agent Routes (`src/routes/agent.ts`)

| Endpoint | Description |

|----------|-------------|

| `POST /agent/chat` | Streaming chat with Luna agent |

Uses Vercel AI SDK `streamText` with SSE response.

---

## Luna Agent (`src/services/luna-agent.ts`)

Agent configuration:

- Model: `gpt-4o-mini` via `@ai-sdk/openai`
- System prompt: Friendly nightlife concierge persona
- Context injection: Venue data, interested friends, user preferences

Agent tools (using Zod schemas):

```typescript
const bookingTool = tool({
  description: 'Book a table at a venue',
  parameters: z.object({
    venueId: z.string(),
    partySize: z.number(),
    dateTime: z.string(),
    guestIds: z.array(z.string()),
  }),
  execute: async (params) => {
    // Create booking in JSON store
    // Return confirmation code
  },
});

const sendInviteTool = tool({
  description: 'Send invites to friends for a venue',
  parameters: z.object({
    venueId: z.string(),
    toUserIds: z.array(z.string()),
    proposedTime: z.string(),
  }),
  execute: async (params) => {
    // Create invites in JSON store
    // Return success confirmation
  },
});
```

---

## Mock Data (`src/db/data/`)

### users.json

```json
[
  { "id": "alex", "name": "Alex", "avatarUrl": "/avatars/alex.png", "vibeStatus": "ready_to_mingle", "friends": ["sarah", "mike"] },
  { "id": "sarah", "name": "Sarah", "avatarUrl": "/avatars/sarah.png", "vibeStatus": "exploring", "friends": ["alex", "mike"] },
  { "id": "mike", "name": "Mike", "avatarUrl": "/avatars/mike.png", "vibeStatus": "chilling", "friends": ["alex", "sarah"] }
]
```

### venues.json

3 venues matching UI draft scenarios:

1. **Blue Note Jazz Club** - Invite scenario (dark, moody, live music)
2. **Rooftop 99** - Hot scenario (cocktail bar, sunset views)
3. **Omen Coffee** - Discovery scenario (cafe, minimalist)

### interests.json

Pre-seed Sarah and Mike interested in Blue Note and Rooftop 99.

### invites.json

Pre-seed one pending invite from Sarah to Alex for Blue Note.

---

## Dependencies

```json
{
  "dependencies": {
    "hono": "^4.6.0",
    "ai": "^4.0.0",
    "@ai-sdk/openai": "^1.0.0",
    "zod": "^3.23.0",
    "nanoid": "^5.0.0"
  },
  "devDependencies": {
    "@types/bun": "latest",
    "typescript": "^5.6.0"
  }
}
```

---

## Environment Variables

`.env.example`:

```
OPENAI_API_KEY=sk-...
CURRENT_USER_ID=alex
PORT=3000
```

The `CURRENT_USER_ID` simulates authentication for the demo.

### To-dos

- [ ] Initialize Bun project with package.json, tsconfig, and folder structure
- [ ] Define TypeScript types for User, Venue, Interest, Invite, Booking
- [ ] Implement JSON data loader/saver utilities in src/db/index.ts
- [ ] Create JSON data files with users, venues, interests, invites
- [ ] Build venues API with feed enrichment and heart/unheart
- [ ] Build social API for friends and interested users
- [ ] Build invites API for create/accept/decline flow
- [ ] Build mock booking service with confirmation codes
- [ ] Integrate Vercel AI SDK with booking and invite tools
- [ ] Configure Hono app entry with CORS and all routes mounted