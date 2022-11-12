//
//  ContentView.swift
//  RailworkDetection
//
//  Created by Niels Faurskov on 08/11/2022.
//

import SwiftUI
import CoreData
import CoreBluetooth

struct ContentView: View {
    
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        TabView {
            Main().tabItem {
                Image(systemName: "tram")
                Text("Diagnostics")
            }
            Log().tabItem {
                Image(systemName: "doc.text")
                Text("Log")
            }
            Recordings().tabItem {
                Image(systemName: "waveform")
                Text("Recordings")
            }
            
        }
        
    }
    

}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
