//
//  UIViewController+Extras.swift
//  ASA Vault
//
//  Created by Dheeraj Chauhan on 31/05/21.
//

import UIKit


extension UIViewController {
    
    /// An alert view
    func showAlert(title: String?, message: String?) -> UIAlertController {
       return showAlert(title: title, message: message) { () in }
    }

    func showAlert(title: String?, message: String?, completionAction:@escaping () -> Void)  -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        DispatchQueue.main.async {
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                completionAction()
            }))
            self.present(alert, animated: true, completion: nil)
        }
        return alert
    }

}
