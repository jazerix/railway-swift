//
//  Recordings.swift
//  RailworkDetection
//
//  Created by Niels Faurskov on 10/11/2022.
//

import SwiftUI

struct Recordings: View {
           
    @State var urls : [URL] = []
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                ForEach(urls, id: \.path) { url in
                    FileItem(url: url)
                }
                Spacer()
            }
            .padding()
            .navigationBarTitle("Past Recordings", displayMode: .inline)
        }
        .onAppear {
            let manager = FileManager.default
            guard let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
            let enumerator = manager.enumerator(
                at: url,
                includingPropertiesForKeys: resourceKeys
            )!;
            
            for case let fileURL as URL in enumerator {
                self.urls.append(fileURL)
            }
        }
        .onDisappear {
            urls.removeAll()
        }
        
    }
}

struct Recordings_Previews: PreviewProvider {
    static var previews: some View {
        Recordings().preferredColorScheme(.dark)
    }
}
