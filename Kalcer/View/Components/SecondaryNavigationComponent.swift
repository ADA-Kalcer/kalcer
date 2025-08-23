//
//  SecondaryNavigationComponent.swift
//  Kalcer
//
//  Created by Tude Maha on 22/08/2025.
//

import SwiftUI

struct SecondaryNavigationComponent: View {
    @Binding var tourModeState: Bool
    @Binding var locationState: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            Button {
                tourModeState.toggle()
            } label: {
                Image(systemName: "headphones")
                    .font(.title2)
                    .foregroundStyle(Color.rgb(red: 64, green: 64, blue: 1))
            }
            .padding()
            .glassEffect(.regular.interactive())
            
            Button {
                locationState.toggle()
            } label: {
                Image(systemName: locationState ? "location.fill" : "location")
                    .font(.title2)
                    .foregroundStyle(Color.rgb(red: 64, green: 64, blue: 1))
            }
            .padding()
            .glassEffect(.regular.interactive())
        }
    }
}

#Preview {
    SecondaryNavigationComponent(
        tourModeState: .constant(true),
        locationState: .constant(true)
    )
}
