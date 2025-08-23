//
//  RecentSearchViewModel.swift
//  Kalcer
//
//  Created by Gede Pramananda Kusuma Wisesa on 22/08/25.
//

import Foundation

class RecentSearchViewModel: ObservableObject {
    @Published var recentSearch: [Patung] = []
    @Published var isLoading = false
    @Published var isError: String? = nil
    
    private let userDefaultsKey = "recentSearchIds"
    private var recentSearchIds: [String] = []
    private let patungViewModel = PatungViewModel()
    
    init() {
        loadRecentSearchIds()
        loadRecentSearch()
    }
    
    func addRecentSearch(_ patung: Patung) {
        let idString = patung.id.uuidString
        
        recentSearchIds.removeAll { $0 == idString }
        recentSearch.removeAll { $0.id == patung.id }
        
        recentSearchIds.insert(idString, at: 0)
        recentSearch.insert(patung, at: 0)
        
        saveRecentSearchIds()
    }
    
    func loadRecentSearch() {
        guard !recentSearchIds.isEmpty else {
            DispatchQueue.main.async {
                self.recentSearch = []
            }
            return
        }
        
        Task {
            do {
                DispatchQueue.main.async {
                    self.isLoading = true
                    self.isError = nil
                }
                
                let ids = recentSearchIds.compactMap { UUID(uuidString: $0) }
                let patungs = try await patungViewModel.getPatungsByIds(ids)
                
                DispatchQueue.main.async {
                    self.recentSearch = patungs
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isError = error.localizedDescription
                }
                print("RecentSearchViewModel.loadRecentSearch() error: \(error.localizedDescription)")
            }
        }
    }
    
    func clearRecentPatungs() {
        recentSearchIds.removeAll()
        recentSearch.removeAll()
        saveRecentSearchIds()
    }
    
    func removeRecentSearch(_ patung: Patung) {
        let idString = patung.id.uuidString
        recentSearchIds.removeAll { $0 == idString }
        recentSearch.removeAll { $0.id == patung.id }
        saveRecentSearchIds()
    }
    
    func removeRecentSearchByOffset(at offsets: IndexSet) {
        let searchesToRemove = offsets.map { recentSearch[$0] }
        
        for patung in searchesToRemove {
            let idString = patung.id.uuidString
            recentSearchIds.removeAll { $0 == idString }
        }
        
        recentSearch.remove(atOffsets: offsets)
        saveRecentSearchIds()
    }
    
    private func loadRecentSearchIds() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let ids = try? JSONDecoder().decode([String].self, from: data) {
            recentSearchIds = ids
        }
    }
    
    private func saveRecentSearchIds() {
        if let data = try? JSONEncoder().encode(recentSearchIds) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
}
