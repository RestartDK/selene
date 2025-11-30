# Selene iOS Client

A SwiftUI-based iOS application for the Selene nightlife discovery app.

## Quick Start

```bash
# Navigate to client directory
cd client

# Open in Xcode
open client.xcodeproj
```

In Xcode:
1. Select your target device/simulator (iOS 17.0+)
2. Update the API base URL in `Services/APIClient.swift` if needed (default: `http://localhost:3000`)
3. Build and run (⌘+R)

## Prerequisites

- **macOS** 13.0+ (Ventura or later)
- **Xcode** 15.0+
- **iOS** 17.0+ deployment target
- **Swift** 5.9+
- Backend server running (see [server/README.md](../server/README.md))

## Architecture

### App Structure

```
TabView
├── NavigationStack (Home)
│   ├── FeedView
│   │   └── VenueReelView (vertical scrolling)
│   └── VenueDetailView (push)
│       └── AgentSheetView (sheet)
│           └── BookingConfirmationView
└── NavigationStack (Profile)
    ├── ProfileView
    └── VenueDetailView (push)
```

### Key Components

#### Views

| Component | Purpose |
|-----------|---------|
| `FeedView` | Main discovery feed with vertical video reels |
| `VenueReelView` | Individual venue reel with video playback |
| `VenueInfoOverlay` | Bottom overlay showing venue info and social proof |
| `InvitedOverlay` | Special overlay for invited venues |
| `VenueDetailView` | Full venue details with interested friends list |
| `AgentSheetView` | Booking sheet with friend selection and smart suggestions |
| `InviteAcceptanceView` | Dedicated view for accepting invitations |
| `BookingConfirmationView` | Success confirmation after booking |
| `ProfileView` | User profile with saved places grid |

#### Services

| Component | Purpose |
|-----------|---------|
| `APIClient` | HTTP client for backend API communication |
| `AppState` | Centralized state management (ObservableObject) |
| `APIModels` | Codable models for API responses |

#### Models

| Component | Purpose |
|-----------|---------|
| `User` | User profile with friends and vibe status |
| `Venue` | Venue information with social state |
| `Invitation` | Invitation model with inviter and venue |

## Project Structure

```
client/
└── client/
    ├── Models/
    │   ├── User.swift
    │   ├── Venue.swift
    │   └── Invitation.swift
    ├── Views/
    │   ├── Feed/
    │   │   ├── FeedView.swift
    │   │   ├── VenueReelView.swift
    │   │   ├── VenueInfoOverlay.swift
    │   │   ├── InvitedOverlay.swift
    │   │   └── FacePileView.swift
    │   ├── Detail/
    │   │   ├── VenueDetailView.swift
    │   │   └── InterestedFriendRow.swift
    │   ├── Agent/
    │   │   ├── AgentSheetView.swift
    │   │   ├── InviteAcceptanceView.swift
    │   │   ├── BookingConfirmationView.swift
    │   │   └── FriendSelectionList.swift
    │   ├── Profile/
    │   │   ├── ProfileView.swift
    │   │   ├── SavedPlacesGrid.swift
    │   │   └── SavedVenueCard.swift
    │   └── MainTabView.swift
    ├── Services/
    │   ├── APIClient.swift
    │   ├── APIModels.swift
    │   └── AppState.swift
    ├── Components/
    │   ├── CustomVideoPlayer.swift
    │   ├── LikeButton.swift
    │   ├── AcceptButton.swift
    │   └── AppButton.swift
    └── Theme/
        ├── Colors.swift
        └── Typography.swift
```

## Design System

### Colors

The app uses a moon-inspired color palette:

- **Moon Glow** - Soft blue-white for highlights
- **Night Sky** - Deep dark background
- **Twilight** - Medium dark for cards
- **Starlight** - Bright accent
- **Gold** - Action buttons (accept, booking)

See `Theme/Colors.swift` for full color definitions.

### Typography

Custom font styles defined in `Theme/Typography.swift`:
- `.seleneAgentTitle` - Large titles
- `.seleneBody` - Body text
- `.seleneCaption` - Small captions
- `.seleneBodyMedium` - Medium weight body

## Key Features

### Video Reel Playback

The feed uses `CustomVideoPlayer` built on `AVPlayer` with:
- Byte-range request support for streaming
- Automatic playback on view appearance
- Pause on scroll away
- Full-screen vertical video format

### Social Proof Integration

- **Face Pile** - Shows up to 3 friend avatars + mutual count
- **Interested Friends List** - Full list in detail view
- **Invitation Badges** - Gold badges for invited venues

### Agent Integration

The `AgentSheetView` fetches smart suggestions from the backend:
- Analyzes shared interests between user and friends
- Pre-selects friends based on venue preferences
- Displays contextual reasoning banner
- One-tap booking with automatic invite sending

## API Integration

### Base Configuration

The API base URL is configured in `Services/APIClient.swift`:

```swift
static let baseURL = "http://localhost:3000"
```

### Key Endpoints Used

| Endpoint | Usage |
|----------|-------|
| `GET /venues` | Fetch feed with social enrichment |
| `GET /venues/:id` | Get venue details |
| `POST /venues/:id/heart` | Mark venue as interested |
| `GET /agent/suggestion` | Get smart booking suggestion |
| `POST /bookings` | Create booking |
| `POST /invites` | Send invitations |
| `PATCH /invites/:id` | Accept/decline invitation |

See [server/README.md](../server/README.md) for complete API documentation.

## State Management

The app uses `AppState` (ObservableObject) for centralized state:

- **Venues** - Cached venue list with social state
- **Friends** - Current user's friend list
- **Invitations** - Pending invitations
- **Bookings** - User's bookings

Views observe `AppState` and update automatically when data changes.

## Development Notes

### Video Streaming

Videos are served from the backend at `/media/:filename`. The `CustomVideoPlayer` handles:
- Range requests for efficient streaming
- Automatic retry on network errors
- Memory-efficient playback

### CORS Configuration

The backend is configured with CORS headers to allow requests from the iOS simulator. Ensure the backend is running before testing the client.

### Testing

The app includes test targets:
- `clientTests` - Unit tests
- `clientUITests` - UI tests

Run tests with ⌘+U in Xcode.

## Troubleshooting

### API Connection Issues

1. Verify backend is running: `curl http://localhost:3000/health`
2. Check API base URL in `APIClient.swift`
3. Ensure CORS is enabled on backend

### Video Playback Issues

1. Verify video files exist in `server/src/db/data/media/`
2. Check network tab for 206 (Partial Content) responses
3. Ensure backend supports byte-range requests

### Build Errors

1. Clean build folder: ⌘+Shift+K
2. Reset package caches if using Swift Package Manager
3. Ensure iOS 17.0+ deployment target is set

