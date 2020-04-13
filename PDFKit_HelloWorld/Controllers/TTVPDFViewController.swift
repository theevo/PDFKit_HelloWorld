//
//  TTVPDFViewController.swift
//  PDFKit_HelloWorld
//
//  Created by Theo Vora on 4/13/20.
//  Copyright © 2020 Theo Vora. All rights reserved.
//

import UIKit
import PDFKit

class TTVPDFViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var pdfView: PDFView!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSamplePDF()
        writeHello()
    }
    
    
    // MARK: - Helper methods
    
    func loadSamplePDF() {
        if let path = Bundle.main.path(forResource: "sample", ofType: "pdf") { // read file name sample.pdf
            let url = URL(fileURLWithPath: path)
            if let pdfDocument = PDFDocument(url: url) {
                pdfView.autoScales = true
                pdfView.displayMode = .singlePageContinuous
                pdfView.displayDirection = .vertical
                pdfView.document = pdfDocument
                pdfView.backgroundColor = .black
            }
        }
    }
    
    func writeHello() {
        guard let document = pdfView.document else { return }
        
        let firstPage = document.page(at: 0)
        
        let annotation = PDFAnnotation(bounds: CGRect(x: 200, y: 300, width: 300, height: 100), forType: .freeText, withProperties: nil)
        
        annotation.contents = "Hello world"
        
        annotation.font = UIFont.systemFont(ofSize: 45.0)
        
        annotation.fontColor = .blue
        
        annotation.color = .clear
        
        firstPage?.addAnnotation(annotation)
        
    }
    

}
