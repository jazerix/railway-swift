//
//  FileDocument.swift
//  RailworkDetection
//
//  Created by Niels Faurskov on 02/12/2022.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct RailwayCoordinates : FileDocument {
    static var readableContentTypes = [UTType.data]
    
    var url : URL? = nil
    
    init(configuration: ReadConfiguration) throws {
        
                    
    }
   
    init(fileUrl: URL) {
        self.url = fileUrl
    }
 
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let content = try String(contentsOf: self.url!)
        let data = Data(content.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
    
    //let url : String
}
