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
    var guideLabel: UILabel?
    var guideFontSize: CGFloat {
        get {
            return fontSize * 5.0
        }
    }
    var annotationPoint: CGPoint?
    var annotationPage: PDFPage?
    
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
    
    var guideBox: CGRect? {
        get {
            guard let pt = annotationPoint else { return nil }
            let guidePoint = pdfView.convert(pt, to: view)
            return CGRect(origin: guidePoint, size: CGSize(width: 500, height: 100))
        }
    }
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var locationGuide: UILabel!
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
        
        guard let tappedPDFPage = pdfView.page(for: tapLocation, nearest: true) else { return }
        
        annotationPage = tappedPDFPage
        
        annotationPoint = pdfView.convert(tapLocation, to: tappedPDFPage)
        
        updateCoordinates()
        writeAnnotation()
        zoomIn()
//        askUserForText(page: tappedPDFPage, at: convertedPoint)
    }
    
    func updateCoordinates() {
        
        if let annotationPoint = annotationPoint {
            pdfViewLocationLabel.text = "\(annotationPoint.prettyPrint())"
        }
        
        if let guidePoint = guideBox?.origin {
            locationGuide.text = "\(guidePoint.prettyPrint())"
        }
        
        if let pageNumber = annotationPage?.label {
            pdfPageLocationLabel.text = "\(pageNumber)"
        }
    }
    
    func addGuideLabel() {
        guard let box = guideBox else { return }
        let label = UILabel(frame: box)
        label.font = UIFont(name: "Courier", size: guideFontSize)
        label.text = annotationText
        label.layer.borderColor = UIColor.systemPink.cgColor
        label.layer.borderWidth = 2.0
        label.isUserInteractionEnabled = true
        guideLabel = label
        
        view.addSubview(guideLabel!)
    }
    
    func loadSamplePDF() {
        if let path = Bundle.main.path(forResource: "sample", ofType: "pdf") {
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
    
    func zoomIn() {
        guard let to = annotationPoint,
            let page = annotationPage else { return }
        
        pdfView.scaleFactor = 5.0
        
        let rect = CGRect(origin: to, size: CGSize(width: 50, height: 50))
        pdfView.go(to: rect, on: page)
        addGuideLabel()
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
            
            self.writeAnnotation()
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
    
    func writeAnnotation() {
        guard let thisPage = annotationPage,
        let point = annotationPoint else { return }
        
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
        
        thisPage.addAnnotation(annotation)
    }
}
