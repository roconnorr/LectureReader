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
class PDFContainer: NSObject, NSCoding {

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
    
    //initalizer for an empty PDFContainer
    init(path: String){
        self.path = path
    }
    
    //complete initalizer (for use by NSCoding methods)
    init(path: String, pageNotes: [Int: String], pageTimes: [Int: Double], bookmarks: [Int], fileNote: String){
        self.path = path
        self.pageNotes = pageNotes
        self.pageTimes = pageTimes
        self.bookmarks = bookmarks
        self.fileNote = fileNote
    }
    
    // MARK: NSCoding
    
    //methods to implement persistent storage
    
    //decode PDFContainer object
    required convenience init?(coder decoder: NSCoder) {
        guard let path = decoder.decodeObject(forKey: "path") as? String,
            let pageNotes = decoder.decodeObject(forKey: "pageNotes") as? [Int: String],
            let pageTimes = decoder.decodeObject(forKey: "pageTimes") as? [Int: Double],
            let bookmarks = decoder.decodeObject(forKey: "bookmarks") as? [Int],
            let fileNote = decoder.decodeObject(forKey: "fileNote") as? String
            else { return nil }
        
        self.init(
            path: path,
            pageNotes: pageNotes,
            pageTimes: pageTimes,
            bookmarks: bookmarks,
            fileNote: fileNote
        )
    }
    
    //encode PDFContainer object
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.path, forKey: "path")
        aCoder.encode(self.pageNotes, forKey: "pageNotes")
        aCoder.encode(self.pageTimes, forKey: "pageTimes")
        aCoder.encode(self.bookmarks, forKey: "bookmarks")
        aCoder.encode(self.fileNote, forKey: "fileNote")
    }
    
    //save PDFContainer object in UserDefaults
    func save(){
        let encoded = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(encoded, forKey: self.path)
    }
    
    //retrieve PDFContainer object from UserDefaults by key (if it exists)
    static func retrieveData(key: String) -> PDFContainer?{
        guard let decodedNSDataBlob = UserDefaults.standard.object(forKey: key) as? Data,
            let loadedPDFContainer = NSKeyedUnarchiver.unarchiveObject(with: decodedNSDataBlob) as? PDFContainer
            else {
                return nil
        }
        
        return loadedPDFContainer
    }
}
