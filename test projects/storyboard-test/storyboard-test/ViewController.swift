//
//  ViewController.swift
//  storyboard-test
//
//  Created by Rory O'Connor on 15/09/17.
//  Copyright © 2017 Rory O'Connor. All rights reserved.
//

import Cocoa
import Quartz

class ViewController: NSViewController {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var ourPDF: PDFView!
    @IBOutlet weak var ourThumbnailView: PDFThumbnailView!
    
    @IBOutlet weak var customPDF: CustomPDFView!
    
    
    @IBOutlet weak var pageNumber: NSTextField!
    
    
    var pdfDoc: PDFDocument?
    //var pdfPage0: PDFPage?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        ourPDF.autoScales = true
        ourPDF.displayMode = .singlePage
        ourThumbnailView.pdfView = ourPDF
        loadTestPDF()
        
        customPDF.pdfDoc = pdfDoc
        customPDF.pdfPage = 0
        pageNumber.stringValue = customPDF.pdfPage.description
        
//        if(pdfDoc != nil){
//            print("asdf")
//            let pdfPage0: PDFPage = (pdfDoc?.page(at: 0))!
//            //let context = NSGraphicsContext.current()?.cgContext
//            CGContext.
//            pdfPage0.draw(with: .artBox, to: )
//        }
        
    }
    
    func loadTestPDF(){
        print("nomeme")
        if let url = Bundle.main.url(forResource: "Resources/Lecture1", withExtension: "pdf"){
            pdfDoc = PDFDocument(url: url)
            print("meme")
            //ourPDF.document = pdf
            
        }
    }
    
    
    @IBAction func nextPageButton(_ sender: NSButton) {
        customPDF.pdfPage += 1
        //print(customPDF.pdfPage)
        pageNumber.stringValue = customPDF.pdfPage.description
        customPDF.needsDisplay = true
    }

    @IBAction func zoomButton(_ sender: NSButton) {
        ourPDF.zoomIn(Any?.self)
    }
    
    @IBAction func openButton(_ sender: Any) {
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a .txt file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["pdf"];
        
        if (dialog.runModal() == NSModalResponseOK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
//                let path = result!.path
//                print(result);
                //filename_field.stringValue = path
                
                let pdf = PDFDocument(url: result!)
                print("meme")
                ourPDF.document = pdf
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

