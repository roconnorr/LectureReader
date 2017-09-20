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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadTestPDF()
    }
    
    func loadTestPDF(){
        print("nomeme")
        if let url = Bundle.main.url(forResource: "Resources/react", withExtension: "pdf"){
            let pdf = PDFDocument(url: url)
            print("meme")
            ourPDF.document = pdf
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

