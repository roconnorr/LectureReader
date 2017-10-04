//
//  PDFContainer.swift
//  Assignment2
//
//  Created by Rory O'Connor on 2/10/17.
//  Copyright © 2017 Rory O'Connor. All rights reserved.
//

import Cocoa
import Quartz

/**
 class to store the location of a PDF file, as well as its note related information
 */
class PDFContainer: NSObject {

    //path of the PDF file
    var path: String
    
    //a note's index in the array corresponds to its page
    var pageNotes: [String] = [String](repeating: "", count: 50)
    var pageTimes: [Double] = [Double](repeating: 2.0, count: 50)
    
    //hashmaps instead of arrays?
    
    //var bookmarks: [Int: String] = [:]
    var bookmarks: [Int] = [Int]()
    
    var fileNote: String = ""
    
    init(path: String){
        self.path = path
    }
    
    //set array size function
    //or make pageNotes a dictionary
}
