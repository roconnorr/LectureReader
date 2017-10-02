//
//  PDFContainer.swift
//  Assignment2
//
//  Created by Rory O'Connor on 2/10/17.
//  Copyright © 2017 Rory O'Connor. All rights reserved.
//

import Cocoa
import Quartz

//class to store the location of a PDF file, as well as its note related information
class PDFContainer: NSObject {

    var path: String
    
    //a note's index in the array corresponds to its page
    var pageNotes: [String] = [String](repeating: "", count: 50)
    
    var fileNote: String = ""
    
    init(path: String){
        self.path = path
    }
}
