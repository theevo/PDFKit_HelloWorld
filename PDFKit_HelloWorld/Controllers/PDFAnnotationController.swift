//
//  PDFAnnotationController.swift
//  PDFKit_HelloWorld
//
//  Created by Theo Vora on 6/18/20.
//  Copyright © 2020 Theo Vora. All rights reserved.
//

import PDFKit

class PDFAnnotationController {
    
    // MARK: - Private Properties
    
    private static var annotationText = "Hello world"
    private static var fontSize: CGFloat = 15.0
    private static let fontName = "Courier"
    private static let bordersOn = true
    
    
    // MARK: - Computed Properties
    
    private static var annotationTextHeight: CGFloat {
        get {
            return fontSize * 1.3
        }
    }
    
    private static var annotationTextWidth: CGFloat {
        get {
            let length = annotationText.count
            
            guard length > 0 else { return 25.0 }
            
            let width = CGFloat(integerLiteral: length) * 11
            
            return width
        }
    }
    
    
    // MARK: - Public Functions
    
    static func create(text: String, pdfPage: PDFPage, pdfPoint: CGPoint) -> PDFAnnotation {
        annotationText = text
        
        let rect = CGRect(x: pdfPoint.x, y: pdfPoint.y, width: annotationTextWidth, height: annotationTextHeight)
        
        let annotation = PDFAnnotation(bounds: rect, forType: .freeText, withProperties: nil)
        
        annotation.contents = annotationText
        annotation.font = UIFont(name: fontName, size: fontSize)
        annotation.fontColor = .blue
        annotation.color = .clear
        
        if bordersOn {
            let border = PDFBorder()
            border.style = .solid
            border.lineWidth = 3.0
            annotation.border = border
        }
        
        pdfPage.addAnnotation(annotation)
        
        return annotation
    }
    
    static func destroy() {
        
    }
}
