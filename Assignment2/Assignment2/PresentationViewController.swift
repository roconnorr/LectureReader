//
//  Presentation.swift
//  Assignment2
//
//  Created by Rory O'Connor on 26/09/17.
//  Copyright © 2017 Rory O'Connor. All rights reserved.
//
//
import Cocoa
import Quartz

class PresentationViewController: NSViewController, ControlDelegate {
    
    @IBOutlet weak var presentationPDFView: PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //set up pdfView options
        presentationPDFView.autoScales = true
        presentationPDFView.displayMode = .singlePage
    }
    
    func updatePDF(pdf: PDFDocument) {
        presentationPDFView.document = pdf
    }
    
    func nextPage() {
        if presentationPDFView.canGoToNextPage() {
            presentationPDFView.goToNextPage(Any?.self)
        }
    }
    
    func prevPage() {
        if presentationPDFView.canGoToPreviousPage(){
            presentationPDFView.goToPreviousPage(Any?.self)
        }
    }
    
    func zoomIn() {
        presentationPDFView.zoomIn(Any?.self)
    }
    
    func zoomOut() {
        presentationPDFView.zoomOut(Any?.self)
    }
}
