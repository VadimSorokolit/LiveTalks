//
//  UIButton+animateTap.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 26.07.2025.
//
    
import UIKit

extension UIButton {
    
    func animateTap(duration: TimeInterval = 0.2, completion: @escaping () -> Void) {
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: duration, animations: {
                self.transform = CGAffineTransform.identity
            }) { _ in
                completion()
            }
        }
    }
    
}
