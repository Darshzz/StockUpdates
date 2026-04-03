//
//  PrimaryButtonModifier.swift
//  StockUpdates
//
//  Created by Darshan Mothreja on 03/04/26.
//

import SwiftUI

/// Applies the shared visual style used by primary action buttons.
struct PrimaryButtonModifier: ViewModifier {
    
    /// Allows each button to override the default accent color.
    var backgroundColor: Color = .orange
    
    func body(content: Content) -> some View {
        content
            // The modifier centralizes padding, typography, and rounded styling.
            .padding()
            .font(.custom("Avenir-Medium", size: 14))
            .foregroundStyle(.white)
            .background(backgroundColor)
            .cornerRadius(25)
    }
}
