# Take home Luna Project

## Notes

- Make an app that helps people find places they want to go to based on their friends and people with similar interest
- Focus on how the user goes about going to a place they like (like getting invited, see a place they like and save it, sees someone else they know go there)
- Focus on agents, so how it could generate automated reservations, bookings, or purchases once users have agreed to go to a place

You are building a social nightlife/event app. You must stick to the goals outlined in the document:

- The Goal: Connect users to places (venues) and people (friends/mutuals).
- The Mechanism: Show users a place, show them who else is interested, and help them book it.
- The Outcome: Get people to actually go out offline.

When people go out they don't just care about the venue itself, but about WHO they know went there as well, otherwise they will feel fomo

How users currently find a place they like:

- Get invited by a friend
 	- Text them for details
  		- Travel to the venue
- Find a place on social media
 	- Go on google maps or ask chatgpt for reviews
  		- Read through reviews
   			- Click on website and make reservation on website
    				- Travel to venue
- Friend tells you about a place you like (word of mouth)
 	- Go on google maps or ask chatgpt for reviews
  		- Read through reviews
   			- Click on website and make reservation on website
    				- Travel to venue
- See a place in person that you really like
 	- Go on google maps or ask chatgpt for reviews
  		- Read through reviews
   			- Click on website and make reservation on website
    				- Travel to venue
- Searches for restaurants near me on google maps
 	- Go on google maps or ask chatgpt for reviews
  		- Read through reviews
   			- Click on website and make reservation on website
    				- Travel to venue

The main components of this app are:

- You want to see your friends that have gone to similar places, or meet new people that have similar places that you like to go to
- You want to find new venues to go that you would like

An important part of this app is that you don't want people to go to new venues but form new connections with people of similar interest.

Inviting people seems to be important as well for this app.

> All of these have the goal of generating social connection/attendance of the places and purchases

## User Flow

### Discover and Find New Friends

#### Step 1: Discovery (The Feed)

- **User Action:** User opens the app and sees a "Feed" or "Map" of nearby venues.
- **System Display:**
  - Shows reel showing of the company
  - Show at the top of your discover page the venue were invited to with a UI element that shows you have been invited by someone else
  - Instead of just showing the venue rating (4.5 stars), it immediately shows faces
  - UI Element: A "Face Pile" icon showing 3 friends + "5 mutuals" are interested in this spot.
  - Swipe up and down to interact with this
- **Decision:** The user stops scrolling because they see familiar faces, not just because the food looks good.

#### Step 2: Validation (The Detail View)

- **User Action:** User taps the venue card to learn more.
- **System Display:**
  - **Venue Info:** Name, location, description, whether it's for coffee, dinner, etc
  - **Social List:** A section explicitly listing: "People you know interested: Sarah, Mike."
- Interaction: The user taps a generic "Interested" button (saving it for later) OR a "Let's Go" button.

#### Step 3: Action (The AI Agent)

- **User Action:** User taps "Let's Go" or "Reserve."
- **System Action (The "Wow" Moment):**
  - Instead of a standard form, a small **"Luna Agent"** overlay appears.
  - *Agent Message:* "I see Sarah and Mike are also interested. Do you want me to book a table for 3 at 9 PM?".
- **Resolution:** User taps "Yes." The Agent simulates a booking process and returns a "Confirmed" ticket. b

![[luna-flow.jpeg]]

### See what You Liked before

#### Step 1: Entry (The Profile Tab)

- **Action:** User taps the "Profile" icon in the bottom Tab Bar.
- **UI:** A clean, modern header with the User's Avatar and Name.
- **The "Luna" Twist:** Add a "Social Battery" or "Vibe Status" (e.g., "Ready to mingle" vs "Chilling") to give the Agent context.

#### Step 2: The "Vibe List" (Saved Places)

This is the core view. Display the venues the user "Hearted" earlier.

- **Visual:** A grid or vertical list of venue cards.
- **Crucial UI State:** Don't just show the venue image. Overlay a status chip:
  - *State A (Quiet):* "Waiting for matches…" (Visual: Pulsing weak signal icon).
  - *State B (Hot):* "2 Friends Interested" (Visual: Face pile of friends who also liked it).
  - *State C (Invited):* "Sarah invited you here" (Visual: Envelope icon).

#### Step 3: Converting "Passive" to "Active"

The user sees that a saved place now has friend interest (State B). They decide to stop waiting and act.

- **Action:** User taps the **"Activate"** or **"Plan"** button on the saved card.
- **System Response (Agent):** The Agent pops up.
  - *Agent:* "Since you and Sarah both liked **Blue Jazz Bar**, I can book a table for tonight. Want me to send the invite?"

## Full Implementation Plan

### Discover and Find New Friends

#### Step 1: Discovery (The Feed)

**User Action:** User opens the app and sees a "Feed" or "Map" of nearby venues.

**System Display:**

- **Media:** Full-screen vertical video reels showing the atmosphere of the venue
- **The "Invite" Priority:** The very first card in the deck is a venue where the user has an active invitation
- **Visual Logic:** Instead of generic star ratings, the primary signal is Social Proof
- **UI Element:** A "Face Pile" icon showing 3 friends + "5 mutuals" are interested in this spot
- **Interaction:** Swipe vertical to browse; Tap to expand
- **Decision Trigger:** "I'm stopping here because Sarah and Mike are going," not just because the food looks good

---

#### Step 2: Validation (The Detail View)

**User Action:** User taps the venue card to learn more.

**System Display:**

- **Venue Info:** Name ("Blue Note Jazz"), Vibe ("Live Music • Late Night"), Location (0.4 mi)
- **Social List:** A dedicated section explicitly listing: "People you know interested: Sarah, Mike"

**Interaction:**

- **Passive:** Tap "Heart/Interested" (Saves to Profile)
- **Active:** Tap "Let's Go / Reserve"

---

#### Step 3: Action (The AI Agent)

**User Action:** User taps "Let's Go" or "Reserve."

**System Action (The "Wow" Moment):**

A clean Agent Action Sheet slides up (not a chat window).

- **Header:** Luna Agent Logo + "I can secure a spot via OpenTable"
- **Smart Selections:** A checklist of friends appears:
  - ☑ Sarah (Pre-selected - High Match)
  - ☑ Mike (Pre-selected - High Match)
  - ☐ Search for others...
- **Primary Action:** A large, glowing button: "Book & Invite"
- **Resolution:** User taps the button. The sheet shows a "Connecting to Venue..." spinner, then transitions to a "Confirmed! Invites Sent" success state

---

### See What You Liked Before

#### Step 1: Entry (The Profile Tab)

**Action:** User taps the "Profile" icon.

**UI:** User Avatar + Name + Social Battery Status (e.g., "Ready to Mingle" 🔋)

---

#### Step 2: The "Vibe List" (Saved Places)

**Visual:** A grid of previously "Hearted" venues.

**Dynamic UI States (The "Smart" Layer):**

- **State A (Quiet):** "Waiting for matches..." (Visual: Pulsing radar icon)
- **State B (Hot):** "2 Friends Interested" (Visual: Face pile of friends)
- **State C (Invited):** "Sarah invited you here" (Visual: Gold border + Envelope icon)

---

#### Step 3: Converting "Passive" to "Active"

**Action:** User taps "Activate" on a "Hot" card.

**System Response:**

- The Agent Action Sheet appears with context
- **Message:** "Sarah matches this vibe. Book for 2?"
- **Selection:** ☑ Sarah (Pre-selected)
- **Action:** User taps "Book & Invite"

---

## 2. Content Plan (Mock Data Strategy)

To make the app feel real in the demo, we will hard-code these specific personas and venues.

### A. The Personas (The "Friend Group")

We need specific names and faces to create consistency across the Feed and Profile.

- **Current User (You):** "Alex" (Profile Pic: Memoji or generic cool avatar)
- **Friend 1:** "Sarah" (The social butterfly who invites you to things)
- **Friend 2:** "Mike" (The mutual friend who is often "Interested")
- **Mutuals:** "5 others" (Generic avatars for the face pile)

---

### B. The Mock Venues (Data Structure)

#### Venue 1: The "Invite" Scenario (Priority #1)

- **Name:** "Blue Note Jazz Club"
- **Type:** Live Music / Speakeasy
- **Image Asset:** Dark, moody jazz club with neon lights
- **Social State:** Invited (Gold Border)
- **Agent Action:** Agent Sheet shows "Accept Invite" instead of "Book"

#### Venue 2: The "Hot" Scenario (Social Proof)

- **Name:** "Rooftop 99"
- **Type:** Cocktail Bar / View
- **Image Asset:** Sunset view of skyline, people holding drinks
- **Social State:** High Interest (Face pile of Sarah + Mike)
- **Agent Action:** Agent Sheet pre-selects Sarah and Mike for a group booking

#### Venue 3: The "Discovery" Scenario (New Place)

- **Name:** "Omen Coffee"
- **Type:** Cafe / Co-working
- **Image Asset:** Minimalist coffee shop, latte art
- **Social State:** None (Shows "Be the first to discover")
- **Interaction:** User taps "Heart" → Moves to Profile "Vibe List"

## Technical choices

## Inspiration

- <https://mobbin.com/apps/partiful-ios-8d86fde9-d2bf-43ad-9a45-62818f75d1aa/cf9efc2a-4499-484b-861e-bbe8d79873a8/screens>
- <https://www.lunacommunity.net/>
