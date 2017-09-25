//
//  AppDelegate.swift
//  no-storyboard-test
//
//  Created by Rory O'Connor on 15/09/17.
//  Copyright © 2017 Rory O'Connor. All rights reserved.
//

import Cocoa
import Quartz

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    @IBOutlet weak var ourPDF: PDFView!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        ourPDF.autoScales = true
        ourPDF.displayMode = .singlePage
        //ourThumbnailView.pdfView = ourPDF
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func zoomInButton(_ sender: NSButton) {
        ourPDF.zoomIn(Any?.self)
    }
    
    @IBAction func zoomOutButton(_ sender: NSButton) {
        ourPDF.zoomOut(Any?.self)
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


}

