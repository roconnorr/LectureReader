//
//  CustomPDFView.swift
//  storyboard-test
//
//  Created by Rory O'Connor on 20/09/17.
//  Copyright © 2017 Rory O'Connor. All rights reserved.
//

import Cocoa
import Quartz

class CustomPDFView: NSView {
    
    var pdfDoc: PDFDocument?
    var pdfPage: Int = 0

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        //setFill
        if(pdfDoc != nil){
            //add check for pdfpage out of bounds
            let pdfPage0: PDFPage = (pdfDoc?.page(at: pdfPage))!
            let context = NSGraphicsContext.current()?.cgContext
            pdfPage0.draw(with: .cropBox, to: context!)
        }
    }

}
