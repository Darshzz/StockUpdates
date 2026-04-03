//
//  WebSocketState.swift
//  StockUpdates
//
//  Created by Darshan Mothreja on 03/04/26.
//

import SwiftUI

enum WebSocketState: Equatable {
    case idle
    case connecting
    case connected
    case disconnected
    case failed
}

extension WebSocketState {
    var title: String {
        switch self {
        case .connected: return "Stop"
        case .connecting: return "Connecting..."
        case .disconnected, .idle: return "Start"
        case .failed: return "Retry"
        }
    }
    
    var description: String {
        switch self {
        case .connected: return "Connected"
        case .connecting: return "Connecting..."
        case .disconnected, .idle: return "Disconnected"
        case .failed: return "Try Again"
        }
    }
    
    var color: Color {
        switch self {
        case .connected: return .red
        case .connecting: return .orange
        case .disconnected, .idle: return .green
        case .failed: return .yellow
        }
    }
    
    var descriptionColor: Color {
        switch self {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected, .idle: return .red
        case .failed: return .yellow
        }
    }
}
