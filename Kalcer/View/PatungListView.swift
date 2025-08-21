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
    @State private var searchTask: Task<Void, Never>?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search patungs...", text: $patungViewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: patungViewModel.searchText, { oldValue, newValue in
                            searchTask?.cancel()
                            searchTask = Task {
                                do {
                                    try await Task.sleep(nanoseconds:
                                                            500_000_000)
                                    if !Task.isCancelled {
                                        await performSearch(query: newValue)
                                    }
                                } catch {
                                    
                                }
                            }
                        })
                    
                    if !patungViewModel.searchText.isEmpty {
                        Button("Clear") {
                            Task {
                                do {
                                    try await patungViewModel.clearSearch()
                                } catch {
                                    print("Clear search error: \(error.localizedDescription)")
                                }
                               
                            }
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
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
            
        }
        .onAppear{
            Task {
                try await patungViewModel.getPatungs()
            }
        }
        .onDisappear {
            searchTask?.cancel()
        }
        .sheet(item: $selectedPatung) { patung in
            NavigationView {
                PatungDetailView(patung: patung)
                    .toolbar {
                        ToolbarItem(placement:
                                .navigationBarTrailing) {
                                    Button("Done") {
                                        selectedPatung = nil
                                    }
                                }
                    }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        
        
        
        
    }
    
    private func performSearch(query: String) async {
        do {
            if query.isEmpty {
                try await patungViewModel.getPatungs()
            } else {
                try await patungViewModel.searchPatungs(query: query)
            }
        } catch {
            print("Search error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    PatungListView()
}
