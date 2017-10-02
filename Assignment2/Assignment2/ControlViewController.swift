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
     Perform setup after the view has loaded
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
     Handles next page button clicked event.
     If its possible to go foward one page, go foward
     on control and presentation views and set number
     and notes text fields
     */
    @IBAction func nextPageButton(_ sender: NSButton) {
        if controlPDFView.canGoToNextPage() {
            //go to the next page and set index
            controlPDFView.goToNextPage(Any?.self)
            presentationDelegate?.nextPage()
            currentPageIndex += 1
            
            //set page number and page notes fields
            pageNumberTextField.stringValue = currentPageIndex.description
            pageNotesTextField.stringValue = pdfModel.openPDFs[currentLectureIndex].pageNotes[currentPageIndex]
        }
    }
    
    /**
     Handles previous page button clicked event.
     If its possible to go back one page, go back
     on control and presentation views and set number
     and notes text fields
     */
    @IBAction func prevPageButton(_ sender: Any) {
        if controlPDFView.canGoToPreviousPage(){
            //go to the prev page and set index
            controlPDFView.goToPreviousPage(Any?.self)
            presentationDelegate?.prevPage()
            currentPageIndex -= 1
            
            //set page number and page notes fields
            pageNumberTextField.stringValue = currentPageIndex.description
            pageNotesTextField.stringValue = pdfModel.openPDFs[currentLectureIndex].pageNotes[currentPageIndex]
        }
    }
    
    /**
     Handles zoom in button clicked event.
     Zooms in the control and presentation views
     */
    @IBAction func zoomInButton(_ sender: NSButton) {
        controlPDFView.zoomIn(Any?.self)
        presentationDelegate?.zoomIn()
    }
    
    /**
     Handles zoom out button clicked event.
     Zooms out the control and presentation views
     */
    @IBAction func zoomOutButton(_ sender: NSButton) {
        controlPDFView.zoomOut(Any?.self)
        presentationDelegate?.zoomOut()
    }
    
    /**
     Handles text entered in pageNumberTextField, if a valid page was entered,
     go to that page
     */
    @IBAction func pageNumberEntered(_ sender: NSTextField) {
        //check if the string entered is an int
        if let input = Int(pageNumberTextField.stringValue){
            //get the page at the entered number
            let page = controlPDFView.document?.page(at: input-1)
            
            //check that the retrieved page exists
            if(page != nil){
                //go to the page and open the page notes
                controlPDFView.go(to: page!)
                pageNotesTextField.stringValue = pdfModel.openPDFs[currentLectureIndex].pageNotes[currentPageIndex]
            }
        }
    }
    
    /**
     Handles open button clicked event, opens a file picker dialog,
     handles opening individual files and folders and displays valid pdfs
     that the user opens
     */
    @IBAction func openButton(_ sender: Any) {
        let dialog = NSOpenPanel();
        
        //set dialog options
        dialog.title                   = "Choose a .pdf file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["pdf"];
        
        //open the dialog
        if (dialog.runModal() == NSModalResponseOK) {
            //URL of the opened file/folder
            let result = dialog.url
            if (result != nil) {
                var isDirectory: ObjCBool = false
                //check if the returned URL refers to a folder or a file
                if FileManager.default.fileExists(atPath: result!.path, isDirectory: &isDirectory) {
                    //is a folder
                    if isDirectory.boolValue == true {
                        
                        //open all pdf files in the folder and put them in the model
                        var pdfLocations = extractPDFFiles(atPath: result!.path, withExtension: "pdf")
                        
                        //sort the pdfs numerically so they are in lecture order
                        pdfLocations = pdfLocations.sorted { $0.compare($1, options: .numeric) == .orderedAscending }
                        
                        //clear old pdfs
                        pdfModel.openPDFs.removeAll()
                        
                        //create a new pdf container array and populate it with paths to PDF files
                        var newPDFContainers: [PDFContainer] = [PDFContainer]()
                        for location in pdfLocations {
                            newPDFContainers.append(PDFContainer(path: location))
                        }
                        
                        //set the open pdfs array
                        pdfModel.openPDFs = newPDFContainers
    
                        //check if any pdfs were opened
                        let isIndexValid = pdfModel.openPDFs.indices.contains(0)
                        
                        if isIndexValid {
                            //retrieve the first PDFDocument from its path
                            let modelPdf = pdfModel.openPDFs[0]
                            let newPDF = getPDFFromPath(path: modelPdf.path)
                            
                            //update control and presentation PDFViews
                            controlPDFView.document = newPDF!
                            updateDelegate(currentPDF: newPDF!)
                            
                            //opened PDF starts at page 1
                            currentPageIndex = 1
                            
                            //set labels and page number field
                            pageNumberTextField.stringValue = currentPageIndex.description
                            totalPagesLabel.stringValue = "/" + String(describing: controlPDFView.document!.pageCount)
                            currentLectureLabel.stringValue = "Lecture " + (currentLectureIndex + 1).description
                        }else{
                            //if no PDFs were found, do nothing
                            print("No PDFs in this folder")
                        }
                        
                    }else{
                        //user chose a single PDF, get reference to it
                        let pdf = PDFDocument(url: result!)
                        
                        //clear open documents array
                        pdfModel.openPDFs.removeAll()
                        
                        //add new PDFContainer containing the path
                        pdfModel.openPDFs.append(PDFContainer(path: result!.path))
                        
                        //update control and presentation PDFViews
                        controlPDFView.document = pdf
                        updateDelegate(currentPDF: pdf!)
                        
                        //opened PDF starts at page 1
                        currentPageIndex = 1
                        
                        //set labels and page number field
                        pageNumberTextField.stringValue = currentPageIndex.description
                        totalPagesLabel.stringValue = "/" + String(describing: controlPDFView.document!.pageCount)
                        currentLectureLabel.stringValue = "Lecture " + (currentLectureIndex + 1).description
                    }
                }
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    /**
     Recieves the new window button clicked event, initializes the
     new window and performs required setup
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
            
            //update the presentation view pdf if a pdf is currently open
            if let openPDF = controlPDFView.document {
                updateDelegate(currentPDF: openPDF)
            }
        }
    }
    
    //MARK: Utility Functions
    
    /**
     Overrides NSTextFieldDelegate method for detecting when text is entered.
     Handles changes in both note entry fields
     */
    override func controlTextDidChange(_ obj: Notification) {
        if let txtFld = obj.object as? NSTextField {
            switch txtFld.tag {
            //fileNotesTextField
            case 201:
                //check if a lecture is currently open
                let isIndexValid = pdfModel.openPDFs.indices.contains(currentLectureIndex)
                
                if isIndexValid {
                    //store the state of the text box in the note model
                    pdfModel.openPDFs[currentLectureIndex].fileNote = txtFld.stringValue
                }else{
                    //if no lecture is open, prevent text entry
                    txtFld.stringValue = ""
                }
            //pageNotesTextField
            case 202:
                //check if a lecture is currently open
                let isIndexValid = pdfModel.openPDFs.indices.contains(currentLectureIndex)
                
                if isIndexValid {
                    //store the state of the text box in the note model
                    pdfModel.openPDFs[currentLectureIndex].pageNotes[currentPageIndex] = txtFld.stringValue
                }else{
                    //if no lecture is open, prevent text entry
                    txtFld.stringValue = ""
                }
            default:
                break
            }
        }
    }
    
    /**
     Helper function for retriving the path of each PDF file in a folder
     given a folder path and a file extension
     */
    func extractPDFFiles(atPath path: String, withExtension fileExtension:String) -> [String] {
        let pathURL = NSURL(fileURLWithPath: path, isDirectory: true)
        var allFiles: [String] = []
        let fileManager = FileManager.default
        
        //iterate over each file in the directory
        if let enumerator = fileManager.enumerator(atPath: path) {
            for file in enumerator {
                //if the file matches the given file extension, add it to the result array
                if let path = NSURL(fileURLWithPath: file as! String, relativeTo: pathURL as URL).path,
                                    path.hasSuffix(".\(fileExtension)"){
                    allFiles.append(path)
                }
            }
        }
        
        return allFiles
    }
    
    /**
     Helper function for retriving a PDFDocument from a path
     */
    func getPDFFromPath(path: String) -> PDFDocument?{
        //get url from path string
        let newUrl = URL.init(fileURLWithPath: path)
        //get a reference to the pdf at the path
        return PDFDocument(url: newUrl)
    }
    
    /**
     Helper function for updating the presentation view with a new pdf
     */
    func updateDelegate(currentPDF: PDFDocument) {
        presentationDelegate?.updatePDF(pdf: currentPDF)
    }
}

