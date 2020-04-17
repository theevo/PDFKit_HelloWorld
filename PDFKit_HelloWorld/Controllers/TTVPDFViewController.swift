//
//  TTVPDFViewController.swift
//  PDFKit_HelloWorld
//
//  Created by Theo Vora on 4/13/20.
//  Copyright © 2020 Joy Bending. All rights reserved.
//

import UIKit
import PDFKit

class TTVPDFViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    
    var annotationText = "Hello world"
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var locationUIView: UILabel!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var pdfPageLocationLabel: UILabel!
    @IBOutlet weak var pdfViewLocationLabel: UILabel!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSamplePDF()
        //        askUserForText()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(updateLabel))
        gestureRecognizer.numberOfTapsRequired = 1
        pdfView.addGestureRecognizer(gestureRecognizer)
    }
    
    
    
    
    // MARK: - Helper methods
    
    @objc func updateLabel(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: pdfView)
        
        locationUIView.text = "\(tapLocation.prettyPrint())"
        locationUIView.alpha = 1.0
        
        UIView.animate(withDuration: 2.0) {
            self.locationUIView.alpha = 0.0
        }
        
        guard let tappedPDFPage = pdfView.page(for: tapLocation, nearest: true) else { return }
        
        if let pageNumber = tappedPDFPage.label {
            print("Page #: \(pageNumber)")
            pdfPageLocationLabel.text = "\(pageNumber)"
        }
        
        let convertedPoint = pdfView.convert(tapLocation, to: tappedPDFPage)
        
        pdfViewLocationLabel.text = "\(convertedPoint.prettyPrint())"
        pdfViewLocationLabel.alpha = 1.0
        
        UIView.animate(withDuration: 2.0) {
            self.pdfViewLocationLabel.alpha = 0.0
        }
        
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
            }
        }
    }
    
    func askUserForText() {
        let alert = UIAlertController(title: "PDF Annotation", message: "Write something", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.delegate = self
            textField.placeholder = "Hey Jude"
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .sentences
        }
        
        let saveButton = UIAlertAction(title: "Save", style: .default) { (_) in
            guard let body = alert.textFields?.first?.text,
                !body.isEmpty else { return }
            
            self.annotationText = body
            self.writeAnnotation()
        }
        alert.addAction(saveButton)
        
        let cancelButton = UIAlertAction(title: "nvm", style: .cancel, handler: nil)
        alert.addAction(cancelButton)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    func writeAnnotation() {
        guard let document = pdfView.document else { return }
        
        let firstPage = document.page(at: 0)
        
        let annotation = PDFAnnotation(bounds: CGRect(x: 200, y: 300, width: 300, height: 100), forType: .freeText, withProperties: nil)
        
        annotation.contents = annotationText
        
        annotation.font = UIFont.systemFont(ofSize: 45.0)
        
        annotation.fontColor = .blue
        
        annotation.color = .clear
        
        firstPage?.addAnnotation(annotation)
        
    }
    
    
}
