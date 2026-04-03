//
//  PrimaryButtonModifier.swift
//  StockUpdates
//
//  Created by Darshan Mothreja on 03/04/26.
//

import SwiftUI

struct PrimaryButtonModifier: ViewModifier {
    
    var backgroundColor: Color = .orange
    
    func body(content: Content) -> some View {
        content
            .padding()
            .font(.custom("Avenir-Medium", size: 14))
            .foregroundStyle(.white)
            .background(backgroundColor)
            .cornerRadius(25)
    }
}
