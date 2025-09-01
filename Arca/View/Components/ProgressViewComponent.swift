//
//  ProgressModalComponent.swift
//  Kalcer
//
//  Created by Tude Maha on 23/08/2025.
//

import SwiftUI

struct ProgressModalComponent: View {
    var body: some View {
        ProgressView("Loading patungs...")
            .padding()
            .glass()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black.opacity(0.7))
    }
}

#Preview {
    ProgressModalComponent()
}
