//
//  PatungViewModel.swift
//  Kalcer
//
//  Created by Gede Pramananda Kusuma Wisesa on 15/08/25.
//

import Foundation
import Supabase

enum Table {
    static let patungs = "patungs"
}

class PatungViewModel: ObservableObject {
    @Published var patungs: [Patung] = []
    @Published var isLoading = false
    @Published var isError: String? = nil
    
    let supabase: SupabaseClient
    init() {
        guard let url = URL(string: Secrets.supabaseURL) else {
            fatalError("Invalid Supabase URL: \(Secrets.supabaseURL)")
        }
        
        self.supabase = SupabaseClient(
            supabaseURL: url,
            supabaseKey: Secrets.supabaseKey
        )
        
    }
    
    func getPatungs() async throws {
        do {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            
            let patungs: [Patung] = try await supabase
                .from("patungs")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
            
            print("Patungs count: \(patungs.count) items")
            print("Patungs list: \(patungs)")
        
            
            DispatchQueue.main.async {
                self.patungs = patungs
                self.isLoading = false
                self.isError = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.isError = error.localizedDescription
            }
            print("PatungViewModel.getPatungs() patungs: \(patungs)")
            print("PatungViewModel.getPatungs() error: \(error.localizedDescription)")
        }
    }
}

