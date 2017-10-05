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
 class to store the location of a PDF file, as well as note and 
 bookmark information
 */
class PDFContainer: NSObject {

    //path of the PDF file
    var path: String
    
    //page notes and times stored in dictionaries to allow for
    //any number of pages
    var pageNotes: [Int: String] = [:]
    var pageTimes: [Int: Double] = [:]
    
    //store bookmarks
    var bookmarks: [Int] = [Int]()
    
    //store note for this file
    var fileNote: String = ""
    
    init(path: String){
        self.path = path
    }
}
