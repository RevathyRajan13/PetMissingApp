//
//  UIVIew+Extensions.swift
//  Second Opinion Doctors Form
//
//  Created by Revathy - iOS Dev on 07/12/24.
//

import Foundation
import UIKit

var activityIndicator = UIActivityIndicatorView(style: .white)

extension UIView {
    func showBlurLoader(){
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.color = UIColor(named: "AppThemeColor")
        
        activityIndicator.startAnimating()
        activityIndicator.center = self.center
        self.addSubview(activityIndicator)
    }
    
    func removeBluerLoader() {
        activityIndicator.stopAnimating()
    }
    
    
    func bounce(duration: TimeInterval = 0.5, scale: CGFloat = 1.2, repeatAnimation: Bool = false) {
        UIView.animate(withDuration: duration / 2,
                       animations: {
                           self.transform = CGAffineTransform(scaleX: scale, y: scale)
                       }) { _ in
            UIView.animate(withDuration: duration / 2, animations: {
                self.transform = CGAffineTransform.identity
            }) { _ in
                if repeatAnimation {
                    // Call the bounce function again to repeat the animation
                    self.bounce(duration: duration, scale: scale, repeatAnimation: repeatAnimation)
                }
            }
        }
    }
    
    func shadowView() {
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOpacity = 0.6
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 5
    }
}
