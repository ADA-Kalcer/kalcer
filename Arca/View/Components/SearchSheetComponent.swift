//
//  SearchSheetComponent.swift
//  Kalcer
//
//  Created by Tude Maha on 20/08/2025.
//

import SwiftUI
import MapKit

struct SearchSheetComponent: View {
    @ObservedObject var patungViewModel: PatungViewModel
    @ObservedObject var recentPatungViewModel: RecentPatungViewModel
    @ObservedObject var recentSearchViewModel: RecentSearchViewModel
    @ObservedObject var bookmarkPatungViewModel: BookmarkPatungViewModel
    
    @State private var searchTask: Task<Void, Never>?
    @FocusState private var isTextFieldFocused: Bool
    
    @Binding var sheetPresentation: PresentationDetent
    @Binding var selectedPatung: Patung?
    @Binding var searchSheet: Bool
    @Binding var recentSheet: Bool
    @Binding var recentSource: RecentSource
    @Binding var cameraPosition: MapCameraPosition
    @Binding var bookmarkSheet: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 10) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        
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
                                    .onTapGesture {
                                        searchSheet = false
                                        recentSource = .annotate
                                        recentSheet = true
                                    }
                                    .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .center))
                                    
                                    
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                                        ForEach(recentPatungViewModel.recentPatungs.prefix(4)) { patung in
                                            SearchCardComponent(title: patung.name, subtitle: patung.address ?? "No address", image: patung.displayImageUrl ?? "")
                                                .onTapGesture {
                                                    selectedPatung = patung
                                                    cameraPosition = MapUtils.zoomMapCamera(
                                                        latitude: Double(selectedPatung?.latitude ?? 0),
                                                        longitude: Double(selectedPatung?.longitude ?? 0)
                                                    )
                                                    searchSheet = false
                                                }
                                        }
                                    }
                                    
                                    Spacer()
                                        .frame(height: 20)
         
                                    HStack {
                                        Text("Bookmark")
                                            .font(Font.title3.bold())
                                        Image(systemName: "chevron.right")
                                    }
                                    .onTapGesture {
                                        searchSheet = false
                                        bookmarkSheet = true
                                    }
                                    .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .center))
                                    
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                                        ForEach(bookmarkPatungViewModel.bookmarkPatungs.prefix(4)) { patung in
                                            SearchCardComponent(title: patung.name, subtitle: patung.address ?? "No address", image: patung.displayImageUrl ?? "")
                                                .onTapGesture {
                                                    searchSheet = false
                                                    selectedPatung = patung
                                                    cameraPosition = MapUtils.zoomMapCamera(
                                                        latitude: Double(selectedPatung?.latitude ?? 0),
                                                        longitude: Double(selectedPatung?.longitude ?? 0)
                                                    )
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
                                        .onTapGesture {
                                            searchSheet = false
                                            recentSource = .search
                                            recentSheet = true
                                        }
                                        
                                        VStack {
                                            List {
                                                ForEach(recentSearchViewModel.recentSearch.prefix(3)) { patung in
                                                    SearchListComponent(title: patung.name, subtitle: patung.address ?? "No address", withSuffix: false)
                                                        .onTapGesture {
                                                            selectedPatung = patung
                                                            recentSearchViewModel.addRecentSearch(patung)
                                                            cameraPosition = MapUtils.zoomMapCamera(
                                                                latitude: Double(selectedPatung?.latitude ?? 0),
                                                                longitude: Double(selectedPatung?.longitude ?? 0)
                                                            )
                                                            searchSheet = false
                                                        }
                                                }
                                                .onDelete(perform: deleteRecentSearch)
                                            }
                                            .frame(height: CGFloat(min(recentSearchViewModel.recentSearch.count, 5) * 70))
                                            .cornerRadius(20)
                                            .scrollContentBackground(.hidden)
                                            .listStyle(PlainListStyle())
                                        }
                                        
                                        Spacer()
                                            .frame(height: 20)
                                        
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
                                                    SearchListComponent(title: patung.name, subtitle: patung.address ?? "No address", withSuffix: false)
                                                        .onTapGesture {
                                                            selectedPatung = patung
                                                            recentSearchViewModel.addRecentSearch(patung)
                                                            cameraPosition = MapUtils.zoomMapCamera(
                                                                latitude: Double(selectedPatung?.latitude ?? 0),
                                                                longitude: Double(selectedPatung?.longitude ?? 0)
                                                            )
                                                            searchSheet = false
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
            if !query.isEmpty {
                try await patungViewModel.searchPatungs(query: query)
            }
        } catch {
            print("Search error: \(error.localizedDescription)")
        }
    }
    
    private func deleteRecentSearch(at offsets: IndexSet) {
        recentSearchViewModel.removeRecentSearchByOffset(at: offsets)
    }
}

#Preview {
    SearchSheetComponent(
        patungViewModel: PatungViewModel(),
        recentPatungViewModel: RecentPatungViewModel(),
        recentSearchViewModel: RecentSearchViewModel(),
        bookmarkPatungViewModel: BookmarkPatungViewModel(),
        sheetPresentation: .constant(.fraction(0.4)),
        selectedPatung: .constant(nil),
        searchSheet: .constant(false),
        recentSheet: .constant(false),
        recentSource: .constant(.annotate),
        cameraPosition: .constant(MapCameraPosition.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: -8.6, longitude: 115.08),
                span: MKCoordinateSpan(latitudeDelta: 1.2, longitudeDelta: 1.4)
            )
        )),
        bookmarkSheet: .constant(false)
    )
}
