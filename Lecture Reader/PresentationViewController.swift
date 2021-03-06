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

/**
 View controller for the presentation window. Conforms to the 
 ControlDelegate protocol so that its methods can be called by
 the control window controller
 */
class PresentationViewController: NSViewController, ControlDelegate {
    
    @IBOutlet weak var presentationPDFView: PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up pdfView options
        presentationPDFView.autoScales = true
        presentationPDFView.displayMode = .singlePage
    }
    
    func updatePDF(pdf: PDFDocument, scaleFactor: CGFloat) {
        presentationPDFView.document = pdf
        presentationPDFView.scaleFactor = scaleFactor
    }
    
    func goToPage(page: PDFPage) {
        presentationPDFView.go(to: page)
    }
    
    func zoomIn() {
        presentationPDFView.zoomIn(Any?.self)
    }
    
    func zoomOut() {
        presentationPDFView.zoomOut(Any?.self)
    }
    
    func fitToPage() {
        presentationPDFView.scaleFactor = 1.0
    }
}
