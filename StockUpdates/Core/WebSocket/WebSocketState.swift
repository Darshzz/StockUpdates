//
//  WebSocketState.swift
//  StockUpdates
//
//  Created by Darshan Mothreja on 03/04/26.
//

import SwiftUI

/// Represents the user-facing lifecycle states of the websocket connection.
enum WebSocketState: Equatable {
    case idle
    case connecting
    case connected
    case disconnected
    case failed
}

extension WebSocketState {
    /// Button title associated with each connection state.
    var title: String {
        switch self {
        case .connected: return "Stop"
        case .connecting: return "Connecting..."
        case .disconnected, .idle: return "Start"
        case .failed: return "Retry"
        }
    }
    
    /// Status text shown near the stock list.
    var description: String {
        switch self {
        case .connected: return "Connected"
        case .connecting: return "Connecting..."
        case .disconnected, .idle: return "Disconnected"
        case .failed: return "Try Again"
        }
    }
    
    /// Button background color for the current action state.
    var color: Color {
        switch self {
        case .connected: return .red
        case .connecting: return .orange
        case .disconnected, .idle: return .green
        case .failed: return .yellow
        }
    }
    
    /// Text color used for the connection status label.
    var descriptionColor: Color {
        switch self {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected, .idle: return .red
        case .failed: return .yellow
        }
    }
}
