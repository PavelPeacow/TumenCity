//
//  UIViewController+Child.swift
//  TumenCity
//
//  Created by Павел Кай on 12.07.2023.
//

import UIKit

extension UIViewController {
    func addChildViewController(_ child: UIViewController) {
        view.addSubview(child.view)
        addChild(child)
        child.didMove(toParent: self)
    }
}
