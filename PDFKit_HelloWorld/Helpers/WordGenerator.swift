//
//  WordGenerator.swift
//  PDFKit_HelloWorld
//
//  Created by Theo Vora on 5/18/20.
//  Copyright © 2020 Theo Vora. All rights reserved.
//

import Foundation

class WordGenerator {
    
    private let words: [String]
    private let wordsCount: Int
    
    static let shared = WordGenerator()
    
    init() {
        if let wordsFilePath = Bundle.main.path(forResource: "words", ofType: nil) {
            do {
                let wordsString = try String(contentsOfFile: wordsFilePath)
                
                self.words = wordsString.components(separatedBy: .newlines)
                self.wordsCount = self.words.count
                return
                
            } catch { // contentsOfFile throws an error
                print("Error: \(error)")
            }
        }
        
        self.words = []
        self.wordsCount = 0
    }
    
    func gimme() -> String {
        
        let randomNumber: Int = numericCast(arc4random_uniform(numericCast(wordsCount)))
        
        let randomWord: String = words[randomNumber]

        return randomWord
    }
}
