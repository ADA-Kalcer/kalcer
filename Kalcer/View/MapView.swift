//
//  ContentView.swift
//  Kalcer
//
//  Created by Tude Maha on 15/08/2025.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var searchQuery = ""
    @State private var searchSheet = true
    @State private var selection: PresentationDetent = .height(80)
    
    var body: some View {
        NavigationView {
            ZStack {
                Map()
            }
        }
        .sheet(isPresented: $searchSheet) {
            SearchSheet()
                .presentationDetents([.height(80), .fraction(0.4), .large], selection: $selection)
                .presentationBackgroundInteraction(.enabled)
                .interactiveDismissDisabled(true)
        }
    }
}

struct SearchSheet: View {
    @State private var searchQuery = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 10) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.rgb(red: 127, green: 128, blue: 131))
                        
                        TextField("Search patung, city, or region", text: $searchQuery)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .focused($isTextFieldFocused)
                    }
                    .padding(10)
                    .background(Color.rgba(red: 127, green: 128, blue: 131, alpha: 0.2))
                    .cornerRadius(30)
                    
                    if isTextFieldFocused {
                        Button(action: {
                            isTextFieldFocused = false
                            searchQuery = ""
                        }) {
                            Image(systemName: "xmark")
                                .foregroundStyle(.black)
                                .padding(13)
                                .background(Color.rgba(red: 127, green: 128, blue: 131, alpha: 0.2))
                                .clipShape(.circle)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
            }
        }
    }
}

#Preview {
    MapView()
}
