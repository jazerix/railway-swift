//
//  FileItem.swift
//  RailworkDetection
//
//  Created by Niels Faurskov on 01/12/2022.
//

import SwiftUI

struct FileItem: View {
    var url : URL
    @State var createdAt : Date = Date.now
    @State var showExporter = false
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(url.lastPathComponent).font(.title3)
                Text(formatDate(date: createdAt)).font(.footnote).foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
            }
            Spacer()
            Button {
                showExporter.toggle()
            } label: {
                Image(systemName: "square.and.arrow.up").scaleEffect(1.4)
            }.fileExporter(
                isPresented: $showExporter,
                document: RailwayCoordinates(fileUrl: url),
                contentType: .data,
                defaultFilename: url.lastPathComponent,
                onCompletion: {result in
                    if case .success = result {
                        print("success")
                    }
                    else {
                        print("failure")
                    }
                })
        }.padding().background(Color(red: 0.1, green: 0.1, blue: 0.1)).cornerRadius(14)
            .onAppear {
                do {
                    let attr = try FileManager.default.attributesOfItem(atPath: url.path())
                    createdAt = attr[FileAttributeKey.creationDate] as? Date ?? Date.now
                } catch {
                    print(error)
                }
            }
    }
    
    func formatDate(date : Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "MMM d, YYYY - HH:mm:ss"
        return dateFormatter.string(from: date)
    }
}

struct FileItem_Previews: PreviewProvider {
    static var previews: some View {
        FileItem(url: URL(string: "/test")!).preferredColorScheme(.dark)
    }
}
