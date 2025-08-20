//
//  SearchSheetComponent.swift
//  Kalcer
//
//  Created by Tude Maha on 20/08/2025.
//

import SwiftUI

struct SearchSheetComponent: View {
    @State private var searchQuery = ""
    @FocusState private var isTextFieldFocused: Bool
    @Binding var sheetPresentation: PresentationDetent
    
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
                    //                    .background(Color.rgba(red: 127, green: 128, blue: 131, alpha: 0.2))
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
                            searchQuery = ""
                            if sheetPresentation != .height(80) {
                                sheetPresentation = .fraction(0.4)
                            }
                        }) {
                            Image(systemName: "xmark")
                                .foregroundStyle(.black)
                                .padding(13)
                            //                                .background(Color.rgba(red: 127, green: 128, blue: 131, alpha: 0.2))
                                .clipShape(.circle)
                        }
                        .glassEffect(.regular.tint(.rgba(red: 127, green: 128, blue: 132, alpha: 0.2)).interactive())
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
    SearchSheetComponent(sheetPresentation: .constant(.fraction(0.4)))
}
