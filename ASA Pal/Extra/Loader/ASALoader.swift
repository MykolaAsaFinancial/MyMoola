//
//  ASALoader.swift
//  ASA Vault
//
//  Created by Vakul Saini
//

import UIKit

class ASALoader: UIView {

    @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loaderLabel: UILabel!
    
    static let shared = ASALoader.view()
    static func view() -> ASALoader {
        let outlets = Bundle.main.loadNibNamed("ASALoader", owner: self, options: nil)
        var obj: ASALoader?
        for outlet in outlets ?? [] {
            if let out = outlet as? ASALoader {
                obj = out
                obj?.activityColor = .white
                break
            }
        }
        return obj!
    }
    
    var isAlreadyShowing: Bool {
        return self.superview != nil
    }
    
    var activityColor: UIColor = .darkGray {
        didSet {
            activityIndicator.color = activityColor
        }
    }
}

// MARK:- Methods
extension ASALoader {
    func show() {
        if let window = AppDelegate.shared.window {
            show(inView: window)
        }
    }
    
    func show(inView view: UIView) {
        if isAlreadyShowing {
            return
        }
        
        if Thread.isMainThread {
            self.frame = view.bounds
            self.alpha = 0.0
            self.activityIndicator.startAnimating()
            view.addSubview(self)
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1.0
            }
        }
        else {
            DispatchQueue.main.async {
                self.frame = view.bounds
                self.alpha = 0.0
                self.activityIndicator.startAnimating()
                view.addSubview(self)
                UIView.animate(withDuration: 0.3) {
                    self.alpha = 1.0
                }
            }
        }
    }
    
    func hide() {
        if Thread.isMainThread {
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 0.0
            }) { (finished) in
                self.activityIndicator.stopAnimating()
                self.removeFromSuperview()
            }
        }
        else {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 0.0
                }) { (finished) in
                    self.activityIndicator.stopAnimating()
                    self.removeFromSuperview()
                }
            }
        }
    }
}
