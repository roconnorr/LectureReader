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
    func nextPage()
    func prevPage()
    func zoomIn()
    func zoomOut()
}

class ControlViewController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var controlPDFView: PDFView!
    
    //@IBOutlet weak var thumbnailView: PDFThumbnailView!
    
    @IBOutlet weak var pageLabel: NSTextField!
    
    @IBOutlet weak var pageNumber: NSTextField!
    
    @IBOutlet weak var currentLectureLabel: NSTextField!
    
    
    @IBOutlet weak var fileNotesTextField: NSTextField!
    
    @IBOutlet weak var pageNotesTextField: NSTextField!
    
    
    var currentLectureIndex: Int = 0
    
    var presentationWindow: NSWindow!
    
    var presentationController: PresentationViewController!
    
    var pdfModel: PDFModel = PDFModel()
    
    var delegate: ControlDelegate? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set pdfView options
        controlPDFView.autoScales = true
        controlPDFView.displayMode = .singlePage
        
        //set text delegates
        fileNotesTextField.delegate = self
        pageNotesTextField.delegate = self
        //ourThumbnailView.pdfView = ourPDF
    }
    
    @IBAction func nextLectureButton(_ sender: NSButton) {
        var isIndexValid = pdfModel.openPDFs.indices.contains(currentLectureIndex + 1)
        if isIndexValid != false{
            isIndexValid = true
        }else{
            isIndexValid = false
        }
        
        if isIndexValid {
            currentLectureIndex += 1
            let pdf = pdfModel.openPDFs[currentLectureIndex]
            
            let newPDF = getPDFFromPath(path: pdf.path)
            //update
            controlPDFView.document = newPDF
            updateDelegate(currentPDF: newPDF!)
            //currentLectureIndex = currentLectureIndex + 1
            currentLectureLabel.stringValue = "Lecture " + (currentLectureIndex + 1).description
            
            //if the pdf changed, start at the first page
            controlPDFView.goToFirstPage(Any?.self)
        }
    }
    
    
    @IBAction func prevLectureButton(_ sender: NSButton) {
        var isIndexValid = pdfModel.openPDFs.indices.contains(currentLectureIndex - 1)
        if isIndexValid != false{
            isIndexValid = true
        }else{
            isIndexValid = false
        }
        
        if isIndexValid {
            currentLectureIndex -= 1
            //get path
            let pdf = pdfModel.openPDFs[currentLectureIndex]
            //get pdf file
            let newPDF = getPDFFromPath(path: pdf.path)
            
            //update
            controlPDFView.document = newPDF
            updateDelegate(currentPDF: newPDF!)
            //currentLectureIndex = currentLectureIndex + 1
            currentLectureLabel.stringValue = "Lecture " + (currentLectureIndex + 1).description
            
            //if the pdf changed, start at the first page
            controlPDFView.goToFirstPage(Any?.self)
        }
    }
    
    
    @IBAction func nextPageButton(_ sender: NSButton) {
        if controlPDFView.canGoToNextPage() {
            controlPDFView.goToNextPage(Any?.self)
        }
        
        delegate?.nextPage()
    }
    
    
    @IBAction func prevPageButton(_ sender: Any) {
        if controlPDFView.canGoToPreviousPage(){
            controlPDFView.goToPreviousPage(Any?.self)
        }
        
        delegate?.prevPage()
    }
    
    
    @IBAction func zoomInButton(_ sender: NSButton) {
        controlPDFView.zoomIn(Any?.self)
        delegate?.zoomIn()
    }
    
    @IBAction func zoomOutButton(_ sender: NSButton) {
        controlPDFView.zoomOut(Any?.self)
        delegate?.zoomOut()
    }
    
    
    @IBAction func pageNumberEntered(_ sender: NSTextField) {
        let page = controlPDFView.document?.page(at: Int(pageNumber.stringValue)! - 1)
        
        if(page != nil){
            controlPDFView.go(to: page!)
        }
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
                        //open all pdf files in the folder and put them in the model
                        var pdfLocations = extractAllFile(atPath: result!.path, withExtension: "pdf")
                        
                        //sort the pdfs numerically so they are in lecture order
                        pdfLocations = pdfLocations.sorted { $0.compare($1, options: .numeric) == .orderedAscending }
                        //clear old pdfs
                        pdfModel.openPDFs.removeAll()
                        
                        var newPDFContainers: [PDFContainer] = [PDFContainer]()
                        
                        for location in pdfLocations {
                            newPDFContainers.append(PDFContainer(path: location))
                        }
                        
                        pdfModel.openPDFs = newPDFContainers
    
                        //check if any pdfs were opened
                        let isIndexValid = pdfModel.openPDFs.indices.contains(0)
                        
                        if isIndexValid {
                            
                            let pdf = pdfModel.openPDFs[0]
                            let newPDF = getPDFFromPath(path: pdf.path)
                            controlPDFView.document = newPDF!
                            updateDelegate(currentPDF: newPDF!)
                            
                            currentLectureLabel.stringValue = "Lecture " + (currentLectureIndex + 1).description
                        }else{
                            print("No PDFs in this folder")
                        }
                        
                    }else{
                        //is a file
                        let pdf = PDFDocument(url: result!)
                        //put the opened document in the model
                        //clear open documents array
                        pdfModel.openPDFs.removeAll()
                        //add path to array
                        pdfModel.openPDFs.append(PDFContainer(path: result!.path))
                        //set the pdfview document
                        controlPDFView.document = pdf
                        //update the pdf of the presentation view
                        updateDelegate(currentPDF: pdf!)
                    }
                }
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    func extractAllFile(atPath path: String, withExtension fileExtension:String) -> [String] {
        let pathURL = NSURL(fileURLWithPath: path, isDirectory: true)
        var allFiles: [String] = []
        let fileManager = FileManager.default
        if let enumerator = fileManager.enumerator(atPath: path) {
            for file in enumerator {
                if let path = NSURL(fileURLWithPath: file as! String, relativeTo: pathURL as URL).path, path.hasSuffix(".\(fileExtension)"){
                    allFiles.append(path)
                }
            }
        }
        return allFiles
    }
    
    
    @IBAction func newWindowButton(_ sender: Any) {
        //check if the window is already open in full screen mode
        //or if it is visible (e.g. open but not full screen)
        var isWindowFullscreen = false
        var isWindowVisible = false
        
        if let window = presentationWindow {
            isWindowFullscreen = window.styleMask.contains(NSWindowStyleMask.fullScreen)
            isWindowVisible = window.isVisible
        }
        
        //if the window is not already open, create the window
        if !isWindowFullscreen && !isWindowVisible {
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
            if let openPDF = controlPDFView.document {
                updateDelegate(currentPDF: openPDF)
            }
        }
    }
    
    
    func updateDelegate(currentPDF: PDFDocument) {
        delegate?.updatePDF(pdf: currentPDF)
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        if let txtFld = obj.object as? NSTextField {
            switch txtFld.tag {
            //file notes
            case 201:
                pdfModel.openPDFs[currentLectureIndex].fileNote = txtFld.stringValue
            //page notes
            case 202:
                break;
                //controlPDFView.currentDestination?.
               // pdfModel.openPDFs[currentLectureIndex].pageNotes[pageNumber] = txtFld.stringValue
            default:
                break
                
            }
        }
    }
    
    func getPDFFromPath(path: String) -> PDFDocument?{
        //get url from path string
        let newUrl = URL.init(fileURLWithPath: path)
        //get a reference to the pdf at the path
        return PDFDocument(url: newUrl)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
