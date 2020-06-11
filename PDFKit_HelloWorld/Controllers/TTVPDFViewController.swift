//
//  TTVPDFViewController.swift
//  PDFKit_HelloWorld
//
//  Created by Theo Vora on 4/13/20.
//  Copyright © 2020 Joy Bending. All rights reserved.
//

import UIKit
import PDFKit

class TTVPDFViewController: UIViewController, UITextFieldDelegate, PDFViewDelegate {
    
    // MARK: - Properties
    
    var annotationText = "Hello world"
    var fontSize: CGFloat = 15.0
    
    
    // MARK: - Computed Properties
    
    var annotationTextHeight: CGFloat {
        get {
            return fontSize * 1.3
        }
    }
    
    var annotationTextWidth: CGFloat {
        get {
            let length = annotationText.count
            
            guard length > 0 else { return 25.0 }
            
            let width = CGFloat(integerLiteral: length) * 11
            
            return width
        }
    }
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var locationUIView: UILabel!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var pdfPageLocationLabel: UILabel!
    @IBOutlet weak var pdfViewLocationLabel: UILabel!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSamplePDF()
        
        recognizeTaps()
    }
    
    
    // MARK: - Helper methods
    
    func recognizeTaps() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(updateLabel))
        gestureRecognizer.numberOfTapsRequired = 1
        pdfView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func updateLabel(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: pdfView)
        
        locationUIView.text = "\(tapLocation.prettyPrint())"
        locationUIView.alpha = 1.0
        
        guard let tappedPDFPage = pdfView.page(for: tapLocation, nearest: true) else { return }
        
        if let pageNumber = tappedPDFPage.label {
            pdfPageLocationLabel.text = "\(pageNumber)"
        }
        
        let convertedPoint = pdfView.convert(tapLocation, to: tappedPDFPage)
        
        pdfViewLocationLabel.text = "\(convertedPoint.prettyPrint())"
        pdfViewLocationLabel.alpha = 1.0
        
        zoomIn(to: convertedPoint, page: tappedPDFPage)
//        askUserForText(page: tappedPDFPage, at: convertedPoint)
    }
    
    func loadSamplePDF() {
        if let path = Bundle.main.path(forResource: "sample", ofType: "pdf") { // read file name sample.pdf
            let url = URL(fileURLWithPath: path)
            if let pdfDocument = PDFDocument(url: url) {
                pdfView.autoScales = true
                pdfView.displayMode = .singlePage
                pdfView.displayDirection = .vertical
                pdfView.document = pdfDocument
                pdfView.backgroundColor = .black
//                pdfView.usePageViewController(false)
            }
        }
    }
    
    func zoomIn(to: CGPoint, page: PDFPage) {
        pdfView.scaleFactor = 5.0
        
        let rect = CGRect(origin: to, size: CGSize(width: 50, height: 50))
        pdfView.go(to: rect, on: page)
    }
    
    func askUserForText(page: PDFPage, at point: CGPoint) {
        let alert = UIAlertController(title: "PDF Annotation", message: "Write something", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.delegate = self
            textField.text = WordGenerator.shared.gimme()
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .sentences
        }
        
        let saveButton = UIAlertAction(title: "Save", style: .default) { (_) in
            guard let body = alert.textFields?.first?.text,
                !body.isEmpty else { return }
            
            self.annotationText = body
            
            self.writeAnnotation(page: page, at: point)
//            self.resetScaleFactor()
        }
        alert.addAction(saveButton)
        
        let cancelButton = UIAlertAction(title: "nvm", style: .cancel) { (_) in
            self.resetZoom()
        }
        alert.addAction(cancelButton)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    func resetZoom() {
        pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
    }
    
    func writeAnnotation(page: PDFPage, at point: CGPoint) {
        resetZoom()
        guard let document = pdfView.document else { return }
        
        let thisPage = document.page(at: document.index(for: page))
        
        let rect = CGRect(x: point.x, y: point.y, width: annotationTextWidth, height: annotationTextHeight)
        
        let annotation = PDFAnnotation(bounds: rect, forType: .freeText, withProperties: nil)
        
        annotation.contents = annotationText
        annotation.font = UIFont(name: "Courier", size: fontSize)
        annotation.fontColor = .blue
        
        let border = PDFBorder()
        border.style = .solid
        border.lineWidth = 3.0
        
        annotation.border = border
        
        annotation.color = .clear
        
        thisPage?.addAnnotation(annotation)
    }
}
