//
//  BookmarkPatungViewModel.swift
//  Kalcer
//
//  Created by Gede Pramananda Kusuma Wisesa on 23/08/25.
//

import Foundation

class BookmarkPatungViewModel: ObservableObject {
    @Published var bookmarkPatungs: [Patung] = []
    @Published var isLoading = false
    @Published var isError: String? = nil
    
    private let userDefaultsKey = "bookmarkPatungIds"
    private var bookmarkPatungIds: [String] = []
    private let patungViewModel = PatungViewModel()
    
    init() {
        loadBookmarkPatungIds()
        loadBookmarkPatungs()
    }
    
    func addBookmarkPatung(_ patung: Patung) {
        let idString = patung.id.uuidString
        
        bookmarkPatungIds.removeAll { $0 == idString }
        bookmarkPatungs.removeAll { $0.id == patung.id }
        
        bookmarkPatungIds.insert(idString, at: 0)
        bookmarkPatungs.insert(patung, at: 0)
        
        saveBookmarkPatungIds()
    }
    
    func loadBookmarkPatungs() {
        guard !bookmarkPatungIds.isEmpty else {
            DispatchQueue.main.async {
                self.bookmarkPatungs = []
            }
            return
        }
        
        Task {
            do {
                DispatchQueue.main.async {
                    self.isLoading = true
                    self.isError = nil
                }
                
                let ids = bookmarkPatungIds.compactMap { UUID(uuidString: $0) }
                let patungs = try await patungViewModel.getPatungsByIds(ids)
                
                DispatchQueue.main.async {
                    self.bookmarkPatungs = patungs
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isError = error.localizedDescription
                }
                print("BookmarkPatungViewModel.loadBookmarkPatungs() error: \(error.localizedDescription)")
            }
        }
    }
    
    func clearBookmarkPatungs() {
        bookmarkPatungIds.removeAll()
        bookmarkPatungs.removeAll()
        saveBookmarkPatungIds()
    }
    
    func removeBookmarkPatung(_ patung: Patung) {
        let idString = patung.id.uuidString
        bookmarkPatungIds.removeAll { $0 == idString }
        bookmarkPatungs.removeAll { $0.id == patung.id }
        saveBookmarkPatungIds()
    }
    
    func removeBookmarkPatungByOffset(at offsets: IndexSet) {
        let patungsToRemove = offsets.map { bookmarkPatungs[$0] }
        
        for patung in patungsToRemove {
            let idString = patung.id.uuidString
            bookmarkPatungIds.removeAll { $0 == idString }
        }
        
        bookmarkPatungs.remove(atOffsets: offsets)
        saveBookmarkPatungIds()
    }
    
    func isBookmarked(_ patung: Patung) -> Bool {
        return bookmarkPatungIds.contains(patung.id.uuidString)
    }
    
    func toggleBookmark(_ patung: Patung) {
        if isBookmarked(patung) {
            removeBookmarkPatung(patung)
        } else {
            addBookmarkPatung(patung)
        }
    }
    
    private func loadBookmarkPatungIds() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let ids = try? JSONDecoder().decode([String].self, from: data) {
            bookmarkPatungIds = ids
        }
    }
    
    private func saveBookmarkPatungIds() {
        if let data = try? JSONEncoder().encode(bookmarkPatungIds) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
}
