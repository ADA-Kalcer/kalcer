//
//  BookmarkListView.swift
//  Kalcer
//
//  Created by Gede Pramananda Kusuma Wisesa on 23/08/25.
//

import SwiftUI

struct BookmarkListView: View {
    @ObservedObject var bookmarkPatungViewModel: BookmarkPatungViewModel
    
    @Binding var selectedPatung: Patung?
    
    var body: some View {
        ScrollView {
            VStack {
                List {
                    ForEach(bookmarkPatungViewModel.bookmarkPatungs) { patung in
                        SearchListComponent(title: patung.name, subtitle: patung.address ?? "No address", icon: "bookmark")
                            .onTapGesture {
                                selectedPatung = patung
                            }
                    }
                    .onDelete(perform: deleteBookmark)
                }
                .frame(height: CGFloat(min(bookmarkPatungViewModel.bookmarkPatungs.count, 5) * 70))
                .cornerRadius(20)
                .scrollContentBackground(.hidden)
                .listStyle(PlainListStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            
        }
        .navigationTitle("Bookmark")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func deleteBookmark(at offsets: IndexSet) {
        bookmarkPatungViewModel.removeBookmarkPatungByOffset(at: offsets)
        
    }
}

#Preview {
    BookmarkListView(
        bookmarkPatungViewModel: BookmarkPatungViewModel(),
        selectedPatung: .constant(nil)
    )
}
