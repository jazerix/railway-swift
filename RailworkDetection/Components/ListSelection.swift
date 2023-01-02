//
//  ListSelection.swift
//  RailworkDetection
//
//  Created by Niels Faurskov on 30/11/2022.
//

import SwiftUI

struct ListSelection: View {
    
    @Binding var selected : String?
    var text : String
    
    var body: some View {
        HStack {
            Text(text)
            Spacer()
            if (selected == text)
            {
                Image(systemName: "checkmark").foregroundColor(.blue)
            }
        }.onTapGesture {
            selected = text
        }
    }
}

struct ListSelection_Previews: PreviewProvider {
    @State static var selected : String? = "Test"
    static var previews: some View {
        ListSelection(selected: $selected, text: "Test").previewLayout(.fixed(width: 300, height: 100)).previewDisplayName("Selected")
        ListSelection(selected: $selected, text: "Demo").previewLayout(.fixed(width: 300, height: 100)).previewDisplayName("Not Selected")
        
    }
}
