//
//  RecentListView.swift
//  Kalcer
//
//  Created by Gede Pramananda Kusuma Wisesa on 22/08/25.
//

import SwiftUI

struct RecentListView: View {
    @ObservedObject var recentPatungViewModel: RecentPatungViewModel
    @ObservedObject var recentSearchViewModel: RecentSearchViewModel
    
    @Binding var recentSource: RecentSource
    @Binding var selectedPatung: Patung?
    
    var body: some View {
        ScrollView {
            VStack {
                List {
                    ForEach(recentSource == .annotate ? recentPatungViewModel.recentPatungs : recentSearchViewModel.recentSearch) { patung in
                        SearchListComponent(title: patung.name, subtitle: patung.address ?? "No address")
                            .onTapGesture {
                                selectedPatung = patung
                            }
                    }
                    .onDelete(perform: deleteRecent)
                }
                .frame(height: CGFloat(min(recentSource == .annotate ? recentPatungViewModel.recentPatungs.count : recentSearchViewModel.recentSearch.count, 5) * 70))
                .cornerRadius(20)
                .scrollContentBackground(.hidden)
                .listStyle(PlainListStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            
        }
        .navigationTitle("Recent")
        .navigationBarTitleDisplayMode(.large)
        
        
    }
    
    private func deleteRecent(at offsets: IndexSet) {
        switch recentSource {
        case .annotate:
            recentPatungViewModel.removeRecentPatungByOffset(at: offsets)
        case .search:
            recentSearchViewModel.removeRecentSearchByOffset(at: offsets)
        }
        
    }
}

#Preview {
    RecentListView(
        recentPatungViewModel: RecentPatungViewModel(),
        recentSearchViewModel: RecentSearchViewModel(),
        recentSource: .constant(.annotate),
        selectedPatung: .constant(nil)
    )
}
