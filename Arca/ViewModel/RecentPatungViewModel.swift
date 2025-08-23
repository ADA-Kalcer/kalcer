//
//  RecentPatungViewModel.swift
//  Kalcer
//
//  Created by Gede Pramananda Kusuma Wisesa on 22/08/25.
//

import Foundation

class RecentPatungViewModel: ObservableObject {
    @Published var recentPatungs: [Patung] = []
    @Published var isLoading = false
    @Published var isError: String? = nil
    
    private let userDefaultsKey = "recentPatungIds"
    private var recentPatungIds: [String] = []
    private let patungViewModel = PatungViewModel()
    
    init() {
        loadRecentPatungIds()
        loadRecentPatungs()
    }
    
    func addRecentPatung(_ patung: Patung) {
        let idString = patung.id.uuidString
        
        recentPatungIds.removeAll { $0 == idString }
        recentPatungs.removeAll { $0.id == patung.id }
        
        recentPatungIds.insert(idString, at: 0)
        recentPatungs.insert(patung, at: 0)
        
        saveRecentPatungIds()
    }
    
    func loadRecentPatungs() {
        guard !recentPatungIds.isEmpty else {
            DispatchQueue.main.async {
                self.recentPatungs = []
            }
            return
        }
        
        Task {
            do {
                DispatchQueue.main.async {
                    self.isLoading = true
                    self.isError = nil
                }
                
                let ids = recentPatungIds.compactMap { UUID(uuidString: $0) }
                let patungs = try await patungViewModel.getPatungsByIds(ids)
                
                DispatchQueue.main.async {
                    self.recentPatungs = patungs
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isError = error.localizedDescription
                }
                print("RecentPatungViewModel.loadRecentPatungs() error: \(error.localizedDescription)")
            }
        }
    }
    
    func clearRecentPatungs() {
        recentPatungIds.removeAll()
        recentPatungs.removeAll()
        saveRecentPatungIds()
    }
    
    func removeRecentPatung(_ patung: Patung) {
        let idString = patung.id.uuidString
        recentPatungIds.removeAll { $0 == idString }
        recentPatungs.removeAll { $0.id == patung.id }
        saveRecentPatungIds()
    }
    
    func removeRecentPatungByOffset(at offsets: IndexSet) {
        let patungsToRemove = offsets.map { recentPatungs[$0] }
        
        for patung in patungsToRemove {
            let idString = patung.id.uuidString
            recentPatungIds.removeAll { $0 == idString }
        }
        
        recentPatungs.remove(atOffsets: offsets)
        saveRecentPatungIds()
    }
    
    private func loadRecentPatungIds() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let ids = try? JSONDecoder().decode([String].self, from: data) {
            recentPatungIds = ids
        }
    }
    
    private func saveRecentPatungIds() {
        if let data = try? JSONEncoder().encode(recentPatungIds) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
}


