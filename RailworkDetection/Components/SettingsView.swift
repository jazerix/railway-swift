//
//  Settings.swift
//  RailworkDetection
//
//  Created by Niels Faurskov on 30/11/2022.
//

import SwiftUI

struct SettingsView: View {
    @Binding var selectedTrain : String?
    @Binding var selectedSurface : String?
    
    var body: some View {
        List {
            Section(header: Text("Train Type")) {
                ListSelection(selected: $selectedTrain, text: "IC3")
                ListSelection(selected: $selectedTrain, text: "IC4")
            }
            Section(header: Text("Surface Type")) {
                ListSelection(selected: $selectedSurface, text: "Rug")
                ListSelection(selected: $selectedSurface, text: "Plastic")
            }
        }.listStyle(GroupedListStyle())
    }
}

struct SettingsView_Previews: PreviewProvider {
    @State static var train : String? = "IC3"
    @State static var surface : String? = "Plastic"
    
    static var previews: some View {
        SettingsView(selectedTrain: $train, selectedSurface: $surface).preferredColorScheme(.dark)
    }
}
