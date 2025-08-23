//
//  SupabaseErrorComponent.swift
//  Kalcer
//
//  Created by Tude Maha on 23/08/2025.
//

import SwiftUI

struct SupabaseErrorComponent: View {
    @ObservedObject var patungViewModel: PatungViewModel
    @Binding var searchSheet: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.icloud")
                .font(.system(size: 60))
                .foregroundColor(.red)
            Text("Something went wrong!")
                .font(.title2)
                .fontWeight(.semibold)
            Text(patungViewModel.isError?.description ??
                 "Unknown error occurred")
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            
            Button("Retry") {
                Task {
                    try await patungViewModel.getPatungs()
                    searchSheet = true
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .onAppear {
            searchSheet = false
        }
        .padding()
        .glassEffect(in: .rect(cornerRadius: 16))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.7))
    }
}

#Preview {
    SupabaseErrorComponent(
        patungViewModel: PatungViewModel(),
        searchSheet: .constant(true)
    )
}
