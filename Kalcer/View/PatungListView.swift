//
//  PatungListView.swift
//  Kalcer
//
//  Created by Gede Pramananda Kusuma Wisesa on 19/08/25.
//

import SwiftUI

struct PatungListView: View {
    @StateObject private var patungViewModel = PatungViewModel()
    @State private var selectedPatung: Patung?
    @State private var showingDetail = false
    
    var body: some View {
        NavigationStack {
            if patungViewModel.isLoading {
                ProgressView("Loading patungs...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                if patungViewModel.isError == nil {
                    if patungViewModel.patungs.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "figure.stand")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("No Patungs Found")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("There are no patungs available at the moment.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    } else {
                        List {
                            ForEach(patungViewModel.patungs) { patung in
                                HStack(spacing: 12) {
                                    AsyncImage(url: URL(string: patung.displayImageUrl ?? "")) { image
                                        in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                    }
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(patung.name)
                                            .font(.headline)
                                        Text(patung.alias ?? "")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 4)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedPatung = patung
                                    showingDetail.toggle()
                                }
                            }
                        }
                        .navigationTitle("All Patungs")
                    }
                } else {
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
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .navigationTitle("All Patungs")
                }
            }
        }
        .onAppear{
            Task {
                try await patungViewModel.getPatungs()
            }
        }
        .sheet(isPresented: $showingDetail) {
            if let selectedPatung = selectedPatung {
                NavigationView {
                    PatungDetailView(patung: selectedPatung)
                        .toolbar {
                            ToolbarItem(placement:
                                    .navigationBarTrailing) {
                                        Button("Done") {
                                            showingDetail = false
                                        }
                                    }
                        }
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
        
        
    }
}

#Preview {
    PatungListView()
}
