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
    
    // MARK: - Private Properties
    
    let dictionaryOn: Bool = false
    let xOffsetPDFAnnotation: CGFloat = -3.0
    let yOffsetPDFAnnotation: CGFloat = -5.0
    
    
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
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecognizer.numberOfTapsRequired = 1
        pdfView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: pdfView)
        
        locationUIView.text = "\(tapLocation.prettyPrint())"
        locationUIView.alpha = 1.0
        
        guard let tappedPDFPage = pdfView.page(for: tapLocation, nearest: true) else { return }
        
        if let pageNumber = tappedPDFPage.label {
            print("Page #: \(pageNumber)")
            pdfPageLocationLabel.text = "\(pageNumber)"
        }
        
        var convertedPoint = pdfView.convert(tapLocation, to: tappedPDFPage)
        convertedPoint.x += xOffsetPDFAnnotation
        convertedPoint.y += yOffsetPDFAnnotation
        
        pdfViewLocationLabel.text = "\(convertedPoint.prettyPrint())"
        pdfViewLocationLabel.alpha = 1.0
        
        askUserForText(page: tappedPDFPage, atPDFPoint: convertedPoint)
    }
    
    func loadSamplePDF() {
        if let path = Bundle.main.path(forResource: "f1040", ofType: "pdf") {
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
    
    func askUserForText(page: PDFPage, atPDFPoint point: CGPoint) {
        let alert = UIAlertController(title: "PDF Annotation", message: "Write something", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.delegate = self
            textField.text = self.dictionaryOn ? WordGenerator.shared.gimme() : ""
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .sentences
        }
        
        let saveButton = UIAlertAction(title: "Save", style: .default) { (_) in
            guard let body = alert.textFields?.first?.text,
                !body.isEmpty else { return }
            
            
            let annotation = PDFAnnotationController.create(text: body, pdfPage: page, pdfPoint: point)
            self.addToUndo(annotation)
            
//            self.annotationText = body
            
            
//            self.writeAnnotation(page: page, at: point)
        }
        alert.addAction(saveButton)
        
        let cancelButton = UIAlertAction(title: "nvm", style: .cancel, handler: nil)
        alert.addAction(cancelButton)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}


// MARK: - Undo & Redo
extension TTVPDFViewController {
    func addToUndo(_ annotation: PDFAnnotation) {
        
        undoManager?.registerUndo(withTarget: self, handler: { (selfTarget) in
            selfTarget.removeAnnotation(annotation)
        })
        undoManager?.setActionName(annotation.contents?.truncateIfNeeded() ?? "annotation")
    }
    
    func removeAnnotation(_ annotation: PDFAnnotation) {
        
        undoManager?.registerUndo(withTarget: self, handler: { (selfTarget) in
            selfTarget.addToUndo(annotation)
            PDFAnnotationController.restore(annotation)
        })
        undoManager?.setActionName(annotation.contents?.truncateIfNeeded() ?? "annotation")
        
        PDFAnnotationController.destroy(annotation)
    }
    
    func restore() {
//        pdfView.layoutDocumentView()
    }
}

extension String {
    func truncateIfNeeded() -> String {
        return "\(self.count > 10 ? self.prefix(7) + "..." : self )"
    }
}
