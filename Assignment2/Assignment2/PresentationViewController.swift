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
//
class PresentationViewController: NSViewController, ControlDelegate {

    @IBOutlet weak var presentationPDFView: PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func updatePDF(pdf: PDFDocument) {
        presentationPDFView.document = pdf
    }
    
}
