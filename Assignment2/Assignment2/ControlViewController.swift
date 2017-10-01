//
//  ViewController.swift
//  Assignment2
//
//  Created by Rory O'Connor on 25/09/17.
//  Copyright © 2017 Rory O'Connor. All rights reserved.
//

import Cocoa
import Quartz

protocol ControlDelegate {
    func updatePDF(pdf: PDFDocument)
}

class ControlViewController: NSViewController {

    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var controlPDFView: PDFView!
    
    //@IBOutlet weak var ourThumbnailView: PDFThumbnailView!
    
    @IBOutlet weak var pageLabel: NSTextField!
    
    @IBOutlet weak var pageNumber: NSTextField!
    
    var presentationWindow: NSWindow!
    var presentationController: PresentationViewController!
    
    //var pdfModel: PDFModel = PDFModel()
    
    var pdfDoc: PDFDocument?
    //var pdfPage0: PDFPage?
    
    //weak var delegate: ControlDelegate?
    var delegate: ControlDelegate? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set up the view after loading
        
        //set pdfView options
        controlPDFView.autoScales = true
        controlPDFView.displayMode = .singlePage
        
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
        if controlPDFView.canGoToNextPage() {
            controlPDFView.goToNextPage(Any?.self)
        }
    }
    
    
    @IBAction func prevPageButton(_ sender: Any) {
        if controlPDFView.canGoToPreviousPage(){
            controlPDFView.goToPreviousPage(Any?.self)
        }
    }
    
    @IBAction func pageNumberEntered(_ sender: NSTextField) {
        let page = controlPDFView.document?.page(at: Int(pageNumber.stringValue)! - 1)
        if(page != nil) {
            controlPDFView.go(to: page!)
        }
    }
    
    
    @IBAction func zoomInButton(_ sender: NSButton) {
        controlPDFView.zoomIn(Any?.self)
    }
    
    @IBAction func zoomOutButton(_ sender: NSButton) {
        controlPDFView.zoomOut(Any?.self)
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
                        //is a folder
                        print("is a folder")
                        
                    }else{
                        //is a file
                        let pdf = PDFDocument(url: result!)
                        //PDFModel.pdfDoc = pdf
                        pdfDoc = pdf
                        controlPDFView.document = pdf
                        alertDelegate()
                    }
                }
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    
    @IBAction func newWindowButton(_ sender: Any) {
        //get a reference to the storyboard
        let storyboard = NSStoryboard(name: "Main",bundle: nil)
        //create an instance of the presentation controller
        presentationController = storyboard.instantiateController(withIdentifier: "presentationViewController") as! PresentationViewController
        //assign the delegate variable
        delegate = presentationController
        
        //create a window and windowcontroller
        presentationWindow = NSWindow(contentViewController: presentationController)
        presentationWindow?.makeKeyAndOrderFront(self)
        let vc = NSWindowController(window: presentationWindow)
        //display the window
        vc.showWindow(self)
        
        //update the presentation view pdf
        alertDelegate()
    }
    
    func alertDelegate() {
        if let newPdf = pdfDoc {
            //only update the delegate if it exits
            delegate?.updatePDF(pdf: newPdf)
        }
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

