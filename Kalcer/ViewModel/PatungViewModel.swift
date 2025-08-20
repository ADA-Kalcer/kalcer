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
    static let patungMedia = "patung_media"
    static let mediaType = "media_type"
    static let materials = "materials"
    static let patungMaterial = "patung_material"
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
                .from(Table.patungs)
                .select("""
                                  *,
                                  patung_media(
                                      id, patung_id, type, url,
                                      media_type(id, type, created_at)
                                  ),
                                  patung_material(
                                      id, patung_id, material_id,
                                      materials(id, name, created_at, updated_at)
                                  )
                              """)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            print("PatungViewModel.getPatungs() patung list: \(patungs)")
            
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
            print("PatungViewModel.getPatungs() error: \(error.localizedDescription)")
        }
    }
    
    func getPatungById(_ id: UUID) async throws -> Patung? {
        do {
            let patung: Patung = try await supabase
                .from(Table.patungs)
                .select("""
                              *,
                              patung_media(
                                  id, patung_id, type, url,
                                  media_type(id, type, created_at)
                              ),
                              patung_material(
                                  id, patung_id, material_id,
                                  materials(id, name, created_at, updated_at)
                              )
                          """)
                .eq("id", value: id.uuidString.lowercased())
                .single()
                .execute()
                .value
            
            return patung
        } catch {
            print("PatungViewModel.getPatungById() error for patung \(id): \(error.localizedDescription)")
            throw error
        }
    }
    
    func getMediaForPatung(_ patungId: UUID) async throws -> [PatungMedia] {
        print("running get media for patung \(patungId)")
        do {
            let media: [PatungMedia] = try await supabase
                .from(Table.patungMedia)
                .select()
                .eq("patung_id", value: patungId.uuidString.lowercased())
                .execute()
                .value
            
            return media
        } catch {
            print("PatungViewModel.getMediaForPatung error: for patung \(patungId): \(error.localizedDescription)")
            throw error
        }
    }
}

