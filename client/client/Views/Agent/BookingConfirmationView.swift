//
//  BookingConfirmationView.swift
//  client
//
//  Selene App - Booking Confirmation Screen
//

import SwiftUI

struct BookingConfirmationView: View {
    let booking: Booking
    var onAddToCalendar: () -> Void
    var onDone: () -> Void
    
    @State private var showCheckmark = false
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Success animation
            successCheckmark
            
            // Booking details card
            if showContent {
                bookingDetailsCard
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            Spacer()
            
            // Action buttons
            if showContent {
                actionButtons
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(24)
        .onAppear {
            // Staggered animation
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showCheckmark = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showContent = true
                }
            }
            
            // Success haptic
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.success)
        }
    }
    
    // MARK: - Success Checkmark
    private var successCheckmark: some View {
        VStack(spacing: 16) {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(SeleneTheme.success.opacity(0.3), lineWidth: 4)
                    .frame(width: 100, height: 100)
                
                // Animated fill
                Circle()
                    .fill(SeleneTheme.success)
                    .frame(width: 80, height: 80)
                    .scaleEffect(showCheckmark ? 1 : 0)
                
                // Checkmark
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
                    .scaleEffect(showCheckmark ? 1 : 0)
            }
            
            Text("CONFIRMED!")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .opacity(showCheckmark ? 1 : 0)
        }
    }
    
    // MARK: - Booking Details Card
    private var bookingDetailsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Venue info
            HStack(spacing: 8) {
                Text(booking.venue.categoryIcon)
                    .font(.title2)
                Text(booking.venue.name)
                    .font(.seleneHeadline)
            }
            
            // Date/time
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
                Text(formattedDateTime)
                    .font(.seleneBody)
            }
            
            // Party size
            HStack(spacing: 8) {
                Image(systemName: "person.2")
                    .foregroundStyle(.secondary)
                Text("Table for \(booking.partySize)")
                    .font(.seleneBody)
            }
            
            // Attendees
            HStack(spacing: -8) {
                ForEach(booking.attendees.prefix(5)) { attendee in
                    AvatarCircle(user: attendee, size: 36)
                }
                
                if booking.attendees.count > 5 {
                    ZStack {
                        Circle()
                            .fill(Color.seleneTertiaryBackground)
                            .frame(width: 36, height: 36)
                        Text("+\(booking.attendees.count - 5)")
                            .font(.seleneSmallMedium)
                    }
                }
            }
            .padding(.top, 4)
            
            // Invites sent indicator
            HStack(spacing: 8) {
                Image(systemName: "envelope.fill")
                    .foregroundStyle(SeleneTheme.success)
                Text("Invites sent!")
                    .font(.seleneCaptionMedium)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.seleneSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            AppButton("Add to Calendar", icon: "calendar.badge.plus", style: .secondary) {
                onAddToCalendar()
            }
            
            AppButton("Done", style: .primary) {
                onDone()
            }
        }
    }
    
    // MARK: - Helpers
    private var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE 'at' h:mm a"
        
        let calendar = Calendar.current
        if calendar.isDateInToday(booking.dateTime) {
            formatter.dateFormat = "'Tonight at' h:mm a"
        } else if calendar.isDateInTomorrow(booking.dateTime) {
            formatter.dateFormat = "'Tomorrow at' h:mm a"
        }
        
        return formatter.string(from: booking.dateTime)
    }
}


