//
//  ShowErrorAlert.swift
//  TumenCity
//
//  Created by Павел Кай on 19.06.2023.
//

import UIKit

extension UIViewController {
    
    func showErrorAlert(title: String, description: String) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
}


