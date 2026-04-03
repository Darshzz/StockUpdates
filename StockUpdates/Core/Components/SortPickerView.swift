//
//  SortPickerView.swift
//  StockUpdates
//
//  Created by Darshan Mothreja on 03/04/26.
//

import SwiftUI

struct SortPickerView: View {
    @Binding var selectedOption: SortOption
    
    var body: some View {
        Picker("Sort", selection: $selectedOption) {
            ForEach(SortOption.allCases) { option in
                Text(option.rawValue)
                    .tag(option)
            }
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    @Previewable @State var selectedOption: SortOption = .price
    SortPickerView(selectedOption: $selectedOption)
}
