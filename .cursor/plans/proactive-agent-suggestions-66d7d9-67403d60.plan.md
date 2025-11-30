<!-- 67403d60-b4d5-4b63-8a0e-2b4f09cbf361 39ba1f0e-c32e-4a3b-82cb-982043fff8ef -->
# Proactive Agent Suggestions with Smart Reasoning

## Assignment Requirements Addressed

**Track 2: Backend - Agents requirement:**

> "Implement agents to generate automated reservations, bookings, or purchases once users have agreed to go to a place for a seamless user experience"

**README.md - Step 3: Action (The AI Agent):**

> Agent Message: "I see Sarah and Mike are also interested. Do you want me to book a table for 3 at 9 PM?"

## Enhanced Reasoning

Instead of generic "I see Sarah and Mike are interested," the agent will analyze shared venue preferences:

**Examples:**

- "You and Sarah both love jazz spots - Blue Note would be perfect for tonight!"
- "Since you all enjoy rooftop vibes and scenic views, Rooftop 99 is calling your names"
- "Mike's into minimalist cafes too - Omen Coffee could be a great low-key hangout"

## How Reasoning Works

The backend analyzes the `interests` table to find common venue types/vibes:

```
1. Get current user's hearted venues -> extract types/vibes
2. Get interested friends' hearted venues -> extract types/vibes
3. Find overlapping preferences (e.g., both liked "Jazz Club" venues)
4. Generate contextual reasoning based on venue + shared interests
```

## End-to-End Flow

```
User taps "Let's Go" -> AgentSheetView opens -> Backend analyzes social + interest data
                                                        |
                                                        v
Backend finds shared interests -> Generates smart reasoning message
                                                        |
                                                        v
iOS displays: "You and Sarah both love jazz - Blue Note would be perfect for tonight!"
                                                        |
                                                        v
User taps "Book & Invite" -> Agent creates booking + sends invites automatically
```

## Implementation Steps

### 1. Backend: Create Smart Suggestion Function

**File**: [server/src/routes/agent.ts](server/src/routes/agent.ts)

Add `getSuggestion(req: Request)` function that:

1. Extract `venueId` from query params
2. Load venue data via `getEnrichedVenue(venueId)`
3. Check if `interestedFriends.length >= 2`
4. **Generate smart reasoning:**

   - Load all interests from database
   - Get current user's interests (venue types/vibes they've liked)
   - Get interested friends' interests
   - Find common venue types (e.g., both liked "Jazz Club", "Rooftop Bar")
   - Build reasoning string based on venue type + shared preferences

**Reasoning generation logic:**

```typescript
function generateReasoning(venue: EnrichedVenue, sharedTypes: string[]): string {
  const friendNames = venue.interestedFriends.map(f => f.name).join(" and ");
  
  if (sharedTypes.includes(venue.type)) {
    // Direct match: they both like this type
    return `You and ${friendNames} both love ${venue.type.toLowerCase()} spots - ${venue.name} would be perfect for tonight!`;
  }
  
  if (sharedTypes.length > 0) {
    // Indirect match: shared taste in general
    return `Since you all enjoy ${sharedTypes[0].toLowerCase()} vibes, ${venue.name} seems like a great fit!`;
  }
  
  // Fallback: use venue vibe
  return `${friendNames} are into ${venue.vibe.toLowerCase()} places too - ${venue.name} could be your next spot!`;
}
```

**Response structure:**

```typescript
{
  venueId: "blue-note",
  venueName: "Blue Note Jazz Club",
  friendNames: ["Sarah", "Mike"],
  friendIds: ["sarah-uuid", "mike-uuid"],
  partySize: 3,
  suggestedTime: "2024-11-30T21:00:00Z",
  reasoning: "You and Sarah both love jazz spots - Blue Note would be perfect for tonight!",
  sharedInterests: ["Jazz Club", "Live Music"]  // For transparency
}
```

### 2. Backend: Add Route Handler

**File**: [server/src/index.ts](server/src/index.ts)

Add route in AGENT ROUTES section (after line 179):

```typescript
// GET /agent/suggestion - Get proactive booking suggestion
if (method === "GET" && path === "/agent/suggestion") {
  return await getSuggestion(req);
}
```

Import `getSuggestion` from `./routes/agent`.

### 3. iOS: Add API Model

**File**: [client/client/Services/APIModels.swift](client/client/Services/APIModels.swift)

Add after Agent Chat Types:

```swift
struct APIAgentSuggestion: Codable {
    let venueId: String
    let venueName: String
    let friendNames: [String]
    let friendIds: [String]
    let partySize: Int
    let suggestedTime: String
    let reasoning: String
    let sharedInterests: [String]?
}
```

### 4. iOS: Add API Client Method

**File**: [client/client/Services/APIClient.swift](client/client/Services/APIClient.swift)

Add method:

```swift
func getAgentSuggestion(venueId: String) async throws -> APIAgentSuggestion? {
    try await request(endpoint: "/agent/suggestion?venueId=\(venueId)")
}
```

### 5. iOS: Update AgentSheetView

**File**: [client/client/Views/Agent/AgentSheetView.swift](client/client/Views/Agent/AgentSheetView.swift)

Add state:

```swift
@State private var agentSuggestion: APIAgentSuggestion?
```

In `onAppear`, fetch and apply suggestion:

```swift
Task {
    if let suggestion = try? await APIClient.shared.getAgentSuggestion(venueId: apiVenueId) {
        agentSuggestion = suggestion
        // Pre-select suggested friends
        for friendId in suggestion.friendIds {
            selectedFriends.insert(friendId)
            if !selectedFriendApiIds.contains(friendId) {
                selectedFriendApiIds.append(friendId)
            }
        }
    }
}
```

Add reasoning banner in `bookingForm` (after `agentHeader`, before `FriendSelectionList`):

```swift
if let suggestion = agentSuggestion {
    VStack(alignment: .leading, spacing: 8) {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .foregroundStyle(SeleneTheme.moonGlow)
            Text("Luna")
                .font(.seleneCaption)
                .foregroundStyle(.secondary)
        }
        Text(suggestion.reasoning)
            .font(.seleneBody)
    }
    .padding(14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(SeleneTheme.moonGlow.opacity(0.1))
    .cornerRadius(12)
}
```

## Files to Modify

| File | Change |

|------|--------|

| `server/src/routes/agent.ts` | Add `getSuggestion()` with smart reasoning logic |

| `server/src/index.ts` | Add GET /agent/suggestion route |

| `client/client/Services/APIModels.swift` | Add `APIAgentSuggestion` struct |

| `client/client/Services/APIClient.swift` | Add `getAgentSuggestion()` method |

| `client/client/Views/Agent/AgentSheetView.swift` | Add suggestion fetch + reasoning banner |

## Demo Value

For the 7-minute video, this shows:

- **Agent Intelligence**: Analyzes past interests to find commonalities
- **Social Compatibility**: "You both love jazz" shows real matching (Track 2)
- **Personalized UX**: Reasoning feels human, not generic
- **Seamless Booking**: One tap after seeing the reasoning

### To-dos

- [ ] Add getSuggestion() function to server/src/routes/agent.ts
- [ ] Add GET /agent/suggestion route to server/src/index.ts
- [ ] Add APIAgentSuggestion struct to APIModels.swift
- [ ] Add getAgentSuggestion() method to APIClient.swift
- [ ] Add suggestion banner and fetch logic to AgentSheetView.swift