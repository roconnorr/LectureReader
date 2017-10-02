//
//  ViewController.swift
//  Assignment2
//
//  Created by Rory O'Connor on 25/09/17.
//  Copyright © 2017 Rory O'Connor. All rights reserved.
//

import Cocoa
import Quartz

/**
 Protocol to be implemented by the presentation view controller
 */
protocol ControlDelegate {
    func updatePDF(pdf: PDFDocument)
    func nextPage()
    func prevPage()
    func zoomIn()
    func zoomOut()
}

/**
 View controller for the control window (main window) of the application.
 */
class ControlViewController: NSViewController, NSTextFieldDelegate {
    
    //MARK: Outlets
    
    @IBOutlet weak var window: NSWindow!
    
    //the PDFView for the control window
    @IBOutlet weak var controlPDFView: PDFView!
    
    //displays total pages of the current file
    @IBOutlet weak var totalPagesLabel: NSTextField!
    
    //displays current lecture name
    @IBOutlet weak var currentLectureLabel: NSTextField!

    //field for diplaying current page, also takes valid int input and changes pages
    @IBOutlet weak var pageNumberTextField: NSTextField!
    
    //takes notes for the current file
    @IBOutlet weak var fileNotesTextField: NSTextField!
    
    //take notes for tue current page
    @IBOutlet weak var pageNotesTextField: NSTextField!
    
    
    //MARK: Variables
    
    //current page
    var currentPageIndex: Int = 1
    
    //current lecture file
    var currentLectureIndex: Int = 0
    
    //reference to the pop out presentation window
    var presentationWindow: NSWindow!
    
    //reference to the presentation view controller
    var presentationController: PresentationViewController!
    
    //instance of the PDF file data storage class
    var pdfModel: PDFModel = PDFModel()
    
    //presentation delegate reference
    var presentationDelegate: ControlDelegate? = nil
    
    /**
     comment
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the PDFView options
        controlPDFView.autoScales = true
        controlPDFView.displayMode = .singlePage
        
        //set textfield delegates
        fileNotesTextField.delegate = self
        pageNotesTextField.delegate = self
    }
    
    //MARK: Actions
    
    /**
     Action for the next lecture button, if the next lecture exists,
     changes the lecture and performs required setup
     */
    @IBAction func nextLectureButton(_ sender: NSButton) {
        //check if the next lecture exists
        let isIndexValid = pdfModel.openPDFs.indices.contains(currentLectureIndex + 1)
        
        if isIndexValid {
            currentLectureIndex += 1
            currentPageIndex = 1
            
            //retrieve the next pdf file and update the control and presentation PDFViews
            let pdf = pdfModel.openPDFs[currentLectureIndex]
            let newPDF = getPDFFromPath(path: pdf.path)
            controlPDFView.document = newPDF
            updateDelegate(currentPDF: newPDF!)
            
            //load notes
            fileNotesTextField.stringValue = pdfModel.openPDFs[currentLectureIndex].fileNote
            pageNotesTextField.stringValue = pdfModel.openPDFs[currentLectureIndex].pageNotes[currentPageIndex]
            
            //start at the first page
            controlPDFView.goToFirstPage(Any?.self)
            
            //set labels and page number field
            currentLectureLabel.stringValue = "Lecture " + (currentLectureIndex + 1).description
            totalPagesLabel.stringValue = "/" + String(describing: controlPDFView.document!.pageCount)
            pageNumberTextField.stringValue = currentPageIndex.description
        }
    }
    
    /**
     Action for the previous lecture button, if the previous lecture exists,
     changes the lecture and performs required setup
     */
    @IBAction func prevLectureButton(_ sender: NSButton) {
        //check if the next lecture exists
        let isIndexValid = pdfModel.openPDFs.indices.contains(currentLectureIndex - 1)
        
        if isIndexValid {
            currentLectureIndex -= 1
            currentPageIndex = 1
            
            //retrieve the next pdf file and update the control and presentation PDFViews
            let pdf = pdfModel.openPDFs[currentLectureIndex]
            let newPDF = getPDFFromPath(path: pdf.path)
            controlPDFView.document = newPDF
            updateDelegate(currentPDF: newPDF!)
            
            //load notes
            fileNotesTextField.stringValue = pdfModel.openPDFs[currentLectureIndex].fileNote
            pageNotesTextField.stringValue = pdfModel.openPDFs[currentLectureIndex].pageNotes[currentPageIndex]
            
            //start at the first page
            controlPDFView.goToFirstPage(Any?.self)
            
            //set labels and page number field
            currentLectureLabel.stringValue = "Lecture " + (currentLectureIndex + 1).description
            totalPagesLabel.stringValue = "/" + String(describing: controlPDFView.document!.pageCount)
            pageNumberTextField.stringValue = currentLectureIndex.description
        }
    }
    
    /**
     comment
     */
    @IBAction func nextPageButton(_ sender: NSButton) {
        if controlPDFView.canGoToNextPage() {
            controlPDFView.goToNextPage(Any?.self)
            currentPageIndex += 1
            pageNumberTextField.stringValue = currentPageIndex.description
            pageNotesTextField.stringValue = pdfModel.openPDFs[currentLectureIndex].pageNotes[currentPageIndex]
            presentationDelegate?.nextPage()
        }
    }
    
    /**
     comment
     */
    @IBAction func prevPageButton(_ sender: Any) {
        if controlPDFView.canGoToPreviousPage(){
            controlPDFView.goToPreviousPage(Any?.self)
            currentPageIndex -= 1
            pageNumberTextField.stringValue = currentPageIndex.description
            pageNotesTextField.stringValue = pdfModel.openPDFs[currentLectureIndex].pageNotes[currentPageIndex]
            presentationDelegate?.prevPage()
        }
    }
    
    /**
     comment
     */
    @IBAction func zoomInButton(_ sender: NSButton) {
        controlPDFView.zoomIn(Any?.self)
        presentationDelegate?.zoomIn()
    }
    
    /**
     comment
     */
    @IBAction func zoomOutButton(_ sender: NSButton) {
        controlPDFView.zoomOut(Any?.self)
        presentationDelegate?.zoomOut()
    }
    
    /**
     comment
     */
    @IBAction func pageNumberEntered(_ sender: NSTextField) {
        currentPageIndex = Int(pageNumberTextField.stringValue)! - 1
        let page = controlPDFView.document?.page(at: currentPageIndex)
        
        if(page != nil){
            controlPDFView.go(to: page!)
            pageNotesTextField.stringValue = pdfModel.openPDFs[currentLectureIndex].pageNotes[currentPageIndex]
        }
    }
    
    /**
     comment
     */
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
                        var pdfLocations = extractPDFFiles(atPath: result!.path, withExtension: "pdf")
                        
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
                            currentPageIndex = 1
                            
                            pageNumberTextField.stringValue = currentPageIndex.description
                            totalPagesLabel.stringValue = "/" + String(describing: controlPDFView.document!.pageCount)
                            
                            
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
                        currentPageIndex = 1
                        pageNumberTextField.stringValue = currentPageIndex.description
                        totalPagesLabel.stringValue = "/" + String(describing: controlPDFView.document!.pageCount)
                    }
                }
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    /**
     comment
     */
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
            presentationDelegate = presentationController
            
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
    
    //MARK: Utility Functions
    
    /**
     comment
     */
    override func controlTextDidChange(_ obj: Notification) {
        if let txtFld = obj.object as? NSTextField {
            switch txtFld.tag {
            //file notes
            case 201:
                let isIndexValid = pdfModel.openPDFs.indices.contains(currentLectureIndex)
                if isIndexValid {
                    pdfModel.openPDFs[currentLectureIndex].fileNote = txtFld.stringValue
                }else{
                    txtFld.stringValue = ""
                }
            //page notes
            case 202:
                let isIndexValid = pdfModel.openPDFs.indices.contains(currentLectureIndex)
                if isIndexValid {
                    pdfModel.openPDFs[currentLectureIndex].pageNotes[currentPageIndex] = txtFld.stringValue
                }else{
                    txtFld.stringValue = ""
                }
            default:
                break
                
            }
        }
    }
    
    /**
     comment
     */
    func extractPDFFiles(atPath path: String, withExtension fileExtension:String) -> [String] {
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
    
    /**
     comment
     */
    func getPDFFromPath(path: String) -> PDFDocument?{
        //get url from path string
        let newUrl = URL.init(fileURLWithPath: path)
        //get a reference to the pdf at the path
        return PDFDocument(url: newUrl)
    }
    
    /**
     comment
     */
    func updateDelegate(currentPDF: PDFDocument) {
        presentationDelegate?.updatePDF(pdf: currentPDF)
    }
    
    /**
     comment
     */
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

