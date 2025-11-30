<!-- d50311d3-3f63-494f-942c-40ad2c7d676f 75b9b958-6f5e-4c35-8068-05135f110002 -->
# Invite Acceptance Flow Implementation

## Overview

When users accept an invitation from the feed, they should see a dedicated acceptance view (not the agent booking sheet). This view shows venue info, who was invited/accepted, and allows confirming the reservation.

## Changes Required

### 1. Backend: Update Invite IDs to UUIDs

**File:** `server/src/routes/invites.ts`

- Replace `nanoid()` with UUID generation for invite IDs
- Import a UUID library or use Node's `crypto.randomUUID()`
- Update existing invites in `server/src/db/data/invites.json` to use UUID format

### 2. Frontend: Update Invitation Model

**File:** `client/client/Models/Invitation.swift`

- Add `apiInviteId: String` field to store the backend invite ID
- Update initializer to accept `apiInviteId` parameter

**File:** `client/client/Services/APIClient.swift`

- Update `APIInvite.toInvitation()` converter to pass through the API invite ID string

**File:** `client/client/Services/AppState.swift`

- Update `loadInvites()` to pass API invite ID when converting
- Update `acceptInvite()` to use the stored `apiInviteId` from the invitation

### 3. Create InviteAcceptanceView

**New File:** `client/client/Views/Agent/InviteAcceptanceView.swift`

- Similar structure to `AgentSheetView` but simplified for acceptance flow
- Show venue header (name, location, category, vibe)
- Display invitees section showing:
- Host (inviter) with "Host" label
- Other invitees with their acceptance status
- Current user as "Accepting..."
- Display proposed date/time (read-only, from invitation)
- "Confirm Reservation" button that:
- Accepts the invite via `appState.acceptInvite()`
- Shows `BookingConfirmationView` on success
- Use `AvatarCircle` component (already exists in `FacePileView.swift`)
- Reuse styling from `AgentSheetView` for consistency

### 4. Update FeedView

**File:** `client/client/Views/Feed/FeedView.swift`

- Modify sheet presentation logic to differentiate between:
- Accepting invitation → show `InviteAcceptanceView`
- Creating new booking → show `AgentSheetView`
- Update `onAcceptInvitation` handler to set appropriate state
- Pass `apiInviteId` from the invitation to the view

### 5. Helper Method in AppState

**File:** `client/client/Services/AppState.swift`

- Add `getInvitesForVenue(apiVenueId: String) -> [Invitation]` method to filter invites by venue
- This helps `InviteAcceptanceView` show all invitees for the venue

## Implementation Details

### InviteAcceptanceView Structure

- NavigationStack with cancel button
- ScrollView containing:

1. Venue header (matches AgentSheetView style)
2. "Who's Going" section with invitees list
3. "When" section showing proposed time
4. Confirm button

- On confirmation success, show `BookingConfirmationView`
- Loading state during API calls

### Key Differences from AgentSheetView

- No friend selection (read-only invitees list)
- No date picker (shows proposed time from invitation)
- Simpler flow: just accept and confirm
- No agent header text, just venue info

## Testing Considerations

- Verify UUID format in backend invite creation
- Test accepting invite updates status correctly
- Ensure all invitees for venue are displayed
- Confirm booking creation flow works (if needed)

### To-dos

- [ ] Update backend invite creation to use UUIDs instead of nanoid in server/src/routes/invites.ts
- [ ] Update existing invite IDs in server/src/db/data/invites.json to UUID format
- [ ] Add apiInviteId field to Invitation model in client/client/Models/Invitation.swift
- [ ] Update APIInvite.toInvitation() converter to pass through API invite ID in client/client/Services/APIClient.swift
- [ ] Update AppState.loadInvites() and acceptInvite() to use apiInviteId, add getInvitesForVenue() helper
- [ ] Create InviteAcceptanceView.swift with venue info, invitees list, and confirm button
- [ ] Update FeedView.swift to show InviteAcceptanceView when accepting invites instead of AgentSheetView