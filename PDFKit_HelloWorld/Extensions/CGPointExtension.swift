//
//  CGPointExtension.swift
//  PDFKit_HelloWorld
//
//  Created by Theo Vora on 4/15/20.
//  Copyright © 2020 Theo Vora. All rights reserved.
//

import UIKit.UITapGestureRecognizer

extension CGPoint {
    func prettyPrint() -> String {
        return "\(self.x.truncateAfterTwoPlaces()), \(self.y.truncateAfterTwoPlaces())"
    }
}


extension CGFloat {
    func truncateAfterTwoPlaces() -> CGFloat {
        let places: CGFloat = 2.0
        return CGFloat(floor(pow(10.0, places) * self)/pow(10.0, places))
    }
}
