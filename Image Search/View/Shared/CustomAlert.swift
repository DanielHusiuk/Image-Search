//
//  CustomAlert.swift
//  Image Search
//
//  Created by Daniel Husiuk on 08.10.2026.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, message: String, actionTitle: String) {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: actionTitle, style: .default))
            present(alert, animated: true)
        }
    }
