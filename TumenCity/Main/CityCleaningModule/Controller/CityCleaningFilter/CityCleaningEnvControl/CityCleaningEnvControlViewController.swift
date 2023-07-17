//
//  CityCleaningEnvControlViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 12.07.2023.
//

import UIKit

class CityCleaningEnvControlViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let loadingController = LoadingViewController()
        loadingController.showLoadingViewControllerIn(self)
        view.backgroundColor = .systemBackground
    }
    


}
