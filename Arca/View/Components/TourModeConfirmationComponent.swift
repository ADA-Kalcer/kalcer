//
//  SupabaseErrorComponent.swift
//  Kalcer
//
//  Created by Tude Maha on 23/08/2025.
//

import SwiftUI

struct TourModeConfirmationComponent: View {
    @Binding var showConfirmation: Bool
    @Binding var tourModeState: Bool
    @Binding var tourModeShowAgain: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "headphones")
                .font(.system(size: 60))
            Text("Tour Mode Activated")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Enjoy an audio guide as you explore! Learn info about each patung you passby—no need to stop, just listen and discover.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .containerRelativeFrame(.horizontal) { width, _ in
                    width * 0.8
                }
            
            Button {
                showConfirmation = false
                tourModeState = true
            } label: {
                Text("OK")
                    .bold()
                    .foregroundStyle(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 10)
                    .background(.arcaPrimary)
                    .clipShape(.capsule)
            }
            
            Button {
                tourModeShowAgain = false
                showConfirmation = false
                tourModeState = true
            } label: {
                Text("Don't show me again")
                    .foregroundStyle(.arcaPrimary)
            }
        }
        .padding()
        .glass()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.7))
    }
}

#Preview {
    TourModeConfirmationComponent(
        showConfirmation: .constant(true),
        tourModeState: .constant(true),
        tourModeShowAgain: .constant(true)
    )
}
