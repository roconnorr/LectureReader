//
//  ViewController.swift
//  Assignment2
//
//  Created by Rory O'Connor on 25/09/17.
//  Copyright © 2017 Rory O'Connor. All rights reserved.
//

import Cocoa
import Quartz

class ViewController: NSViewController {

    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var ourPDF: PDFView!
    
    //@IBOutlet weak var ourThumbnailView: PDFThumbnailView!
    
    @IBOutlet weak var pageLabel: NSTextField!
    
    @IBOutlet weak var pageNumber: NSTextField!
    
    
    var pdfDoc: PDFDocument?
    //var pdfPage0: PDFPage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set up the view after loading
        
        //set pdfView options
        ourPDF.autoScales = true
        ourPDF.displayMode = .singlePage
        
        //ourThumbnailView.pdfView = ourPDF
        
        //customPDF.pdfDoc = pdfDoc
        //customPDF.pdfPage = 0
        //pageNumber.stringValue = customPDF.pdfPage.description
        
        //        if(pdfDoc != nil){
        //            print("asdf")
        //            let pdfPage0: PDFPage = (pdfDoc?.page(at: 0))!
        //            //let context = NSGraphicsContext.current()?.cgContext
        //            CGContext.
        //            pdfPage0.draw(with: .artBox, to: )
        //        }
    }
    
    @IBAction func nextPageButton(_ sender: NSButton) {
        if ourPDF.canGoToNextPage() {
            ourPDF.goToNextPage(Any?.self)
        }
    }
    
    
    @IBAction func prevPageButton(_ sender: Any) {
        if ourPDF.canGoToPreviousPage(){
            ourPDF.goToPreviousPage(Any?.self)
        }
    }
    
    @IBAction func zoomInButton(_ sender: NSButton) {
        ourPDF.zoomIn(Any?.self)
    }
    
    @IBAction func zoomOutButton(_ sender: NSButton) {
        ourPDF.zoomOut(Any?.self)
    }
    
    
    @IBAction func openButton(_ sender: Any) {
        let dialog = NSOpenPanel();
        
        //set dialog options
        dialog.title                   = "Choose a .txt file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["pdf"];
        
        //open the dialog
        if (dialog.runModal() == NSModalResponseOK) {
            let result = dialog.url // Pathname of the file
            if (result != nil) {
                
                var isDirectory: ObjCBool = false
                //check if the returned URL refers to a folder or a file
                if FileManager.default.fileExists(atPath: result!.path, isDirectory: &isDirectory) {
                    if isDirectory.boolValue == true {
                        //folder
                        print("is a folder")
                    }else{
                        //file
                        let pdf = PDFDocument(url: result!)
                        print("is a file")
                        ourPDF.document = pdf
                    }
                }
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

