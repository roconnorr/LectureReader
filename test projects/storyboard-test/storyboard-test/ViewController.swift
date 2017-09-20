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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ourPDF.displayMode = PDFDisplayMode.singlePage
        ourThumbnailView.pdfView = ourPDF
        loadTestPDF()
    }
    
    func loadTestPDF(){
//        print("nomeme")
//        if let url = Bundle.main.url(forResource: "Resources/react", withExtension: "pdf"){
//            //let pdf = PDFDocument(url: url)
//            print("meme")
//            //ourPDF.document = pdf
//            
//        }
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

