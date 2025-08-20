//
//  env.swift
//  Kalcer
//
//  Created by Gede Pramananda Kusuma Wisesa on 15/08/25.
//

import Foundation

enum Secrets {
    static var supabaseURL: String {
        guard let url = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String else {
            fatalError("Supabase URL not found in secrets")
        }
        let fixedURL = "https://\(url).supabase.co"
        return fixedURL
    }
    static var supabaseKey: String {
        guard let key = Bundle.main.infoDictionary?["SUPABASE_KEY"] as? String else {
            fatalError("Supabase Key not found in secrets")
        }
        return key
    }
}
