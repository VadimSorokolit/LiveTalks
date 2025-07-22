//
//  UIColor+Hex.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//
    
import UIKit

extension UIColor {
    
    convenience init(hex: Int, opacity: CGFloat = 1.0) {
        let red   = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >>  8) & 0xFF) / 255.0
        let blue  = CGFloat((hex >> 0) & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: opacity)
    }
    
}
