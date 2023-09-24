//
//  UIViewController+NetworkReachability.swift
//  TumenCity
//
//  Created by Павел Кай on 23.09.2023.
//

import UIKit

extension UIViewController {
    func setupNetworkReachability(becomeAvailable: @escaping () -> Void,
                                  becomeUnavailable: (() -> Void)? = nil) {
        NetworkReachability.shared.becomeUnavailable = {
            SnackBarView(type: .noConnection,
                         andShowOn: self.view)
            becomeUnavailable?()
        }
        
        NetworkReachability.shared.becomeAvailable = {
            SnackBarView(type: .withConnection,
                         andShowOn: self.view)
            becomeAvailable()
        }
    }
}
