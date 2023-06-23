//
//  LoadingViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 19.06.2023.
//

import UIKit
import RxSwift
import RxRelay

final class LoadingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    private func setUpView() {
        view.backgroundColor = .systemBackground
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .label
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func showLoadingViewControllerIn(_ viewController: UIViewController, then: (() -> Void)? = nil) {
        let loadingVC = LoadingViewController()
        viewController.addChild(loadingVC)
        loadingVC.view.frame = viewController.view.bounds
        viewController.view.addSubview(loadingVC.view)
        loadingVC.didMove(toParent: viewController)
        then?()
    }
    
    func removeLoadingViewControllerIn(_ viewController: UIViewController, then: (() -> Void)? = nil) {
        for childVC in viewController.children {
            if childVC is LoadingViewController {
                childVC.willMove(toParent: nil)
                childVC.view.removeFromSuperview()
                childVC.removeFromParent()
            }
        }
        then?()
    }
}
