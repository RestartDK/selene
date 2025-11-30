//
//  Invitation.swift
//  client
//
//  Selene App - Invitation Model
//

import Foundation

struct Invitation: Identifiable {
    let id: UUID
    let venue: Venue
    let inviter: User
    let invitedAt: Date
    var status: InvitationStatus
    let scheduledTime: Date?
    
    enum InvitationStatus: String {
        case pending = "Pending"
        case accepted = "Accepted"
        case declined = "Declined"
        case expired = "Expired"
    }
    
    init(
        id: UUID = UUID(),
        venue: Venue,
        inviter: User,
        invitedAt: Date = Date(),
        status: InvitationStatus = .pending,
        scheduledTime: Date? = nil
    ) {
        self.id = id
        self.venue = venue
        self.inviter = inviter
        self.invitedAt = invitedAt
        self.status = status
        self.scheduledTime = scheduledTime
    }
}

// Booking model for confirmed reservations
struct Booking: Identifiable {
    let id: UUID
    let venue: Venue
    let dateTime: Date
    let partySize: Int
    let attendees: [User]
    let confirmationCode: String
    
    init(
        id: UUID = UUID(),
        venue: Venue,
        dateTime: Date,
        partySize: Int,
        attendees: [User],
        confirmationCode: String = ""
    ) {
        self.id = id
        self.venue = venue
        self.dateTime = dateTime
        self.partySize = partySize
        self.attendees = attendees
        self.confirmationCode = confirmationCode.isEmpty ? Self.generateCode() : confirmationCode
    }
    
    private static func generateCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }
}

