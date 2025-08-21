//
//  SearchSheetComponent.swift
//  Kalcer
//
//  Created by Tude Maha on 20/08/2025.
//

import SwiftUI

struct SearchSheetComponent: View {
    @StateObject private var patungViewModel = PatungViewModel()
    @State private var searchTask: Task<Void, Never>?
    @FocusState private var isTextFieldFocused: Bool
    @Binding var sheetPresentation: PresentationDetent
    @Binding var selectedPatung: Patung?
    @Binding var searchSheet: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 10) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.rgb(red: 127, green: 128, blue: 131))
                        
                        TextField("Search Patung", text: $patungViewModel.searchText)
                            .bold()
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .submitLabel(.return)
                            .focused($isTextFieldFocused)
                            .onChange(of: patungViewModel.searchText) { oldValue, newValue in
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
                            }
                    }
                    .padding(10)
                    .cornerRadius(30)
                    .glassEffect(.regular.tint(.rgba(red: 127, green: 128, blue: 132, alpha: 0.2)).interactive())
                    .onChange(of: isTextFieldFocused) { focused, _ in
                        if !focused {
                            sheetPresentation = .large
                        }
                    }
                    
                    if isTextFieldFocused {
                        Button(action: {
                            isTextFieldFocused = false
                            Task {
                                do {
                                    try await patungViewModel.clearSearch()
                                } catch {
                                    print("Clear search error: \(error.localizedDescription)")
                                }
                            }
                            
                            if sheetPresentation != .height(80) {
                                sheetPresentation = .fraction(0.4)
                            }
                        }) {
                            Image(systemName: "xmark")
                                .foregroundStyle(.black)
                                .padding(13)
                                .clipShape(.circle)
                        }
                        .glassEffect(.regular.tint(.rgba(red: 127, green: 128, blue: 132, alpha: 0.2)).interactive())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                if sheetPresentation == .height(80) || sheetPresentation == .fraction(0.1) {
                    Spacer()
                } else {
                        if !isTextFieldFocused {
                            ScrollView {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("Recent")
                                            .font(Font.title3.bold())
                                        Image(systemName: "chevron.right")
                                    }
                                    .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .center))
                                    
                                    ScrollView(.horizontal) {
                                        HStack(spacing: 20) {
                                            ForEach(0..<3, id: \.self) {
                                                SearchCardComponent(title: "Patung \($0)", subtitle: "Alias patung \($0)", image: "https://picsum.photos/400/300?random=1")
                                            }
                                        }
                                        
                                    }
         
                                    HStack {
                                        Text("Visited")
                                            .font(Font.title3.bold())
                                        Image(systemName: "chevron.right")
                                    }
                                    .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .center))
                                    
                                    ScrollView(.horizontal) {
                                        HStack(spacing: 20) {
                                            ForEach(0..<3, id: \.self) {
                                                SearchCardComponent(title: "Patung \($0)", subtitle: "Alias patung \($0)", image: "https://picsum.photos/400/300?random=1")
                                            }
                                        }
                                        
                                    }
                                }
                                .padding(16)
                                Spacer()
                            }
                        } else {
                            ScrollView {
                                if patungViewModel.searchText.isEmpty {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("Recent")
                                                .font(Font.title3.bold())
                                            Image(systemName: "chevron.right")
                                        }
                                        .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .center))
                                        
                                        VStack {
                                            List {
                                                ForEach(0..<3, id: \.self) {
                                                    SearchListComponent(title: "Patung \($0)", subtitle: "Alias patung \($0)")
                                                }
                                            }
                                            .frame(height: CGFloat(3 * 70))
                                            .cornerRadius(20)
                                            .scrollContentBackground(.hidden)
                                            .listStyle(PlainListStyle())
                                        }
                                        
                                        Spacer()
                                            .frame(height: 20)
             
                                        HStack {
                                            Text("Find by Location")
                                                .font(Font.title3.bold())
                                        }
                                        .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .center))
                                        
                                        List {
                                            ForEach(0..<3, id: \.self) {
                                                SearchListComponent(title: "Patung \($0)", subtitle: "Alias patung \($0)", icon: "building.2.fill")
                                            }
                                        }
                                        .frame(height: CGFloat(3 * 70))
                                        .cornerRadius(20)
                                        .scrollContentBackground(.hidden)
                                        .listStyle(PlainListStyle())
                                        
                                    }
                                    .padding(16)
                                    Spacer()
                                } else {
                                    VStack(alignment: .leading) {
                                        if patungViewModel.searchedPatungs.isEmpty {
                                            Text("No results found")
                                                .foregroundColor(.secondary)
                                                .padding()
                                        } else {
                                            List {
                                                ForEach(patungViewModel.searchedPatungs) { patung in
                                                    SearchListComponent(title: patung.name, subtitle: patung.alias ?? "")
                                                        .onTapGesture {
                                                            selectedPatung = patung
                                                            searchSheet.toggle()
                                                        }
                                                }
                                                
                                            }
                                            .frame(height: CGFloat(min(patungViewModel.searchedPatungs.count, 5) * 70))
                                            .scrollContentBackground(.hidden)
                                            .listStyle(PlainListStyle())
                                        }
                                        
                                    }
                                    .cornerRadius(20)
                                    .padding(16)
                                    
                                    Spacer()
                                }
                            }
                        }
                }
            }
        }
        .onDisappear {
            searchTask?.cancel()
        }
    }
    
    private func performSearch(query: String) async {
        do {
            if query.isEmpty {
            } else {
                try await patungViewModel.searchPatungs(query: query)
            }
        } catch {
            print("Search error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SearchSheetComponent(sheetPresentation: .constant(.fraction(0.4)), selectedPatung: .constant(nil), searchSheet: .constant(false))
}
