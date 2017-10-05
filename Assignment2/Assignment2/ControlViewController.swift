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
    func updatePDF(pdf: PDFDocument, scaleFactor: CGFloat)
    func goToPage(page: PDFPage)
    func zoomIn()
    func zoomOut()
    func fitToPage()
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
    
    //displays and recieves slide pause times
    @IBOutlet weak var slideTimeTextField: NSTextField!
    
    @IBOutlet weak var startSlideshowButton: NSButton!
    
    
    //MARK: Variables
    
    //store open PDFs
    var openPDFs: [PDFContainer] = [PDFContainer]()
    
    //current page
    var currentPageIndex: Int = 1
    
    //current lecture file
    var currentLectureIndex: Int = 0
    
    //appdelegate reference for handling menu items
    let appDelegate = NSApplication.shared().delegate as! AppDelegate
    
    //reference to the pop out presentation window
    var presentationWindow: NSWindow!
    
    //reference to the presentation view controller
    var presentationController: PresentationViewController!
    
    //presentation delegate reference
    var presentationDelegate: ControlDelegate? = nil
    
    //store the last search result selection
    var lastSearchResult: PDFSelection? = nil
    
    //timer variable for slideshow
    var slideTimer = Timer()
    
    //run loop reference for timer
    let runLoop = RunLoop.current
    
    var timerRunning: Bool = false
    
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
        slideTimeTextField.delegate = self
    }
    
    //MARK: Actions
    
    /**
     Action for the next lecture button, if the next lecture exists,
     changes the lecture and performs required setup
     */
    @IBAction func nextLectureButton(_ sender: NSButton) {
        //check if the next lecture exists
        let isIndexValid = openPDFs.indices.contains(currentLectureIndex + 1)
        
        if isIndexValid {
            currentLectureIndex += 1
            
            //retrieve the next pdf file and update the control and presentation PDFViews
            let pdf = openPDFs[currentLectureIndex]
            let newPDF = getPDFFromPath(path: pdf.path)
            controlPDFView.document = newPDF
            updateDelegate(currentPDF: newPDF!)
            
            //start at the first page
            changePage(pageNumber: 1)
            
            //update bookmarks menu
            updateBookmarkMenuItems()
        }
    }
    
    /**
     Action for the previous lecture button, if the previous lecture exists,
     changes the lecture and performs required setup
     */
    @IBAction func prevLectureButton(_ sender: NSButton) {
        //check if the next lecture exists
        let isIndexValid = openPDFs.indices.contains(currentLectureIndex - 1)
        
        if isIndexValid {
            currentLectureIndex -= 1
            
            //retrieve the next pdf file and update the control and presentation PDFViews
            let pdf = openPDFs[currentLectureIndex]
            let newPDF = getPDFFromPath(path: pdf.path)
            controlPDFView.document = newPDF
            updateDelegate(currentPDF: newPDF!)
            
            //start at the first page
            changePage(pageNumber: 1)
            
            //update bookmarks menu
            updateBookmarkMenuItems()
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
            currentPageIndex += 1
            changePage(pageNumber: currentPageIndex)
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
            currentPageIndex -= 1
            changePage(pageNumber: currentPageIndex)
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
     Handles fit to page button clicked event.
     Resets the scale factor of views to 1
     */
    @IBAction func fitToPageButton(_ sender: NSButton) {
        controlPDFView.scaleFactor = 1.0
        presentationDelegate?.fitToPage()
    }
    
    /**
     Handles bookmark page button clicked event.
     Adds the page number to the PDFContainer
     */
    @IBAction func bookmarkPageButton(_ sender: NSButton) {
        let isIndexValid = openPDFs.indices.contains(currentLectureIndex)
        
        //if there is a lecture open, add the current page as a bookpark
        if isIndexValid {
            //if the bookmark doesn't already exist, add it.
            if !openPDFs[currentLectureIndex].bookmarks.contains(currentPageIndex){
                openPDFs[currentLectureIndex].bookmarks.append(currentPageIndex)
                //update the menu with current bookmarks
                updateBookmarkMenuItems()
            }
            
        }
    }
    
    /**
     Handles bookmark menu item clicked event.
     Changes the page to the bookmark
     */
    func bookmarkMenuAction(_ sender: NSMenuItem){
        changePage(pageNumber: sender.tag)
    }
    
    /**
     Handles text entered in pageNumberTextField, if a valid page was entered,
     go to that page
     */
    @IBAction func pageNumberEntered(_ sender: NSTextField) {
        //check if the string entered is an int
        if let input = Int(pageNumberTextField.stringValue){
            changePage(pageNumber: input)
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
                        openPDFs.removeAll()
                        
                        //create a new pdf container array and populate it with paths to PDF files
                        var newPDFContainers: [PDFContainer] = [PDFContainer]()
                        for location in pdfLocations {
                            newPDFContainers.append(PDFContainer(path: location))
                        }
                        
                        //set the open pdfs array
                        openPDFs = newPDFContainers
    
                        //check if any pdfs were opened
                        let isIndexValid = openPDFs.indices.contains(0)
                        
                        if isIndexValid {
                            //retrieve the first PDFDocument from its path
                            let modelPdf = openPDFs[0]
                            let newPDF = getPDFFromPath(path: modelPdf.path)
                            
                            //update control and presentation PDFViews
                            controlPDFView.document = newPDF!
                            updateDelegate(currentPDF: newPDF!)
                            
                            //opened PDF starts at page 1
                            currentPageIndex = 1
                            
                            //set labels and page number field
                            changePage(pageNumber: currentPageIndex)
                            
                        }else{
                            //if no PDFs were found, do nothing
                            print("No PDFs in this folder")
                        }
                        
                    }else{
                        //user chose a single PDF, get reference to it
                        let pdf = PDFDocument(url: result!)
                        
                        //clear open documents array
                        openPDFs.removeAll()
                        
                        //add new PDFContainer containing the path
                        openPDFs.append(PDFContainer(path: result!.path))
                        
                        //update control and presentation PDFViews
                        controlPDFView.document = pdf
                        updateDelegate(currentPDF: pdf!)
                        
                        //opened PDF starts at page 1
                        currentPageIndex = 1
                        
                        changePage(pageNumber: currentPageIndex)
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
                changePage(pageNumber: currentPageIndex)
            }
        }
    }
    
    /**
     Recieves search string entered event, searches the document
     for the first occurence of the string, if the search is entered again,
     continues to next result
     */
    @IBAction func searchStringEntered(_ sender: NSSearchField) {
        //set and pass the last search result. If it is nil search starts at the start of the document
        //if not nil, finds the next result
        lastSearchResult = controlPDFView.document?.findString(sender.stringValue, from: lastSearchResult, withOptions: Int(NSString.CompareOptions.caseInsensitive.rawValue))
        
        //if the search returned a result, highlight it and scroll the view to the selection
        controlPDFView.setCurrentSelection(lastSearchResult, animate: true)
        controlPDFView.scrollSelectionToVisible(Any?.self)
        
        //if a page is currently opened, change page to set fields
        if let page  = controlPDFView.currentPage {
            currentPageIndex = (controlPDFView.document?.index(for: page))! + 1
            changePage(pageNumber: currentPageIndex)
        }
    }
    
    /**
     Starts a presentation by creating a one off timer that calls the automatic
     page changing function
     */
    @IBAction func startPresentationButton(_ sender: NSButton) {
        let isIndexValid = openPDFs.indices.contains(currentLectureIndex)
        
        if isIndexValid {
            if timerRunning == false {
                timerRunning = true
                // Create a timer object that calls the nextPage method every second
                slideTimer = Foundation.Timer(timeInterval: openPDFs[currentLectureIndex].pageTimes[currentPageIndex], target: self, selector: #selector(automaticPageChange(_:)), userInfo: nil, repeats: false)
        
                runLoop.add(slideTimer, forMode: RunLoopMode.commonModes)
            
                //change the button image
                
                startSlideshowButton.image = NSImage(named: "pause")
            }else{
                timerRunning = false
                slideTimer.invalidate()
                startSlideshowButton.image = NSImage(named: "play")
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
                let isIndexValid = openPDFs.indices.contains(currentLectureIndex)
                
                if isIndexValid {
                    //store the state of the text box in the note model
                    openPDFs[currentLectureIndex].fileNote = txtFld.stringValue
                }else{
                    //if no lecture is open, prevent text entry
                    txtFld.stringValue = ""
                }
            //pageNotesTextField
            case 202:
                //check if a lecture is currently open
                let isIndexValid = openPDFs.indices.contains(currentLectureIndex)
                
                if isIndexValid {
                    //store the state of the text box in the note model
                    openPDFs[currentLectureIndex].pageNotes[currentPageIndex] = txtFld.stringValue
                }else{
                    //if no lecture is open, prevent text entry
                    txtFld.stringValue = ""
                }
            //slide length field
            case 203:
                //check if a lecture is currently open
                let isIndexValid = openPDFs.indices.contains(currentLectureIndex)
                
                if isIndexValid {
                    if let time = Double(txtFld.stringValue){
                        openPDFs[currentLectureIndex].pageTimes[currentPageIndex] = time
                    }
                }else{
                    txtFld.stringValue = ""
                }
            default:
                break
            }
        }
    }
    
    
    /**
     Helper function for changing pages, finds the page at the index and
     updates the view, also updates notes, labels and other info
     */
    func changePage(pageNumber: Int){
        
        let isIndexValid = openPDFs.indices.contains(currentLectureIndex)
        
        if isIndexValid {
            currentPageIndex = pageNumber
            
            if let page = controlPDFView.document?.page(at: currentPageIndex - 1){
                controlPDFView.go(to: page)
                presentationDelegate?.goToPage(page: page)
        
                //load notes
                fileNotesTextField.stringValue = openPDFs[currentLectureIndex].fileNote
                pageNotesTextField.stringValue = openPDFs[currentLectureIndex].pageNotes[currentPageIndex]
                
                //load slide time
                slideTimeTextField.stringValue = openPDFs[currentLectureIndex].pageTimes[currentPageIndex].description
        
                //set labels and page number field
                currentLectureLabel.stringValue = "Lecture " + (currentLectureIndex + 1).description
                totalPagesLabel.stringValue = "/" + String(describing: controlPDFView.document!.pageCount)
                pageNumberTextField.stringValue = currentPageIndex.description
                
            
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
     Helper function for populating the bookmarks menu with bookmarks
     from the current lecture
     */
    func updateBookmarkMenuItems(){
        appDelegate.bookmarksMenu.removeAllItems()
        
        for page in openPDFs[currentLectureIndex].bookmarks{
            let newItem = NSMenuItem(title: "Page: " + page.description, action: #selector(bookmarkMenuAction(_:)), keyEquivalent: "")
            
            newItem.tag = page
            appDelegate.bookmarksMenu.addItem(newItem)
        }
    }
    
    /**
     Helper function to be called by the start presentation function
     sets up a new timer with the correct value to trigger itself
     */
    func automaticPageChange(_ theTimer:Foundation.Timer){
        let isIndexValid = openPDFs.indices.contains(currentLectureIndex + 1)
        
        if isIndexValid {
            currentPageIndex += 1
            changePage(pageNumber: currentPageIndex)
            slideTimer = Foundation.Timer(timeInterval: openPDFs[currentLectureIndex].pageTimes[currentPageIndex], target: self, selector: #selector(automaticPageChange(_:)), userInfo: nil, repeats: false)
        
            //attach timer to the event loop
            runLoop.add(slideTimer, forMode: RunLoopMode.commonModes)
        }
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
        presentationDelegate?.updatePDF(pdf: currentPDF, scaleFactor: controlPDFView.scaleFactor)
    }
}

