//
//  CustomPDFView.swift
//  Assignment2
//
//  Created by Rory O'Connor on 5/10/17.
//  Copyright © 2017 Rory O'Connor. All rights reserved.
//

import Cocoa
import Quartz

/**
 Subclass of PDFView to disable scrolling to change pages
 */
class CustomPDFView: PDFView {
    
    //override convenience page change methods to disable page scrolling
    //while keeping zoomed scrolling and text selection functionality
    override func goToNextPage(_ sender: Any?) {}
    override func goToPreviousPage(_ sender: Any?) {}
}
