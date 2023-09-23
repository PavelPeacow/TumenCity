//
//  LoadingViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 19.06.2023.
//

import UIKit
import RxSwift
import RxRelay

enum LoadingViewType {
    case secondaryLoading
}

final class LoadingViewController: UIViewController {
    
    let type: LoadingViewType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    init(type: LoadingViewType? = nil) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        view.backgroundColor = .systemBackground
        if let type {
            view.backgroundColor = .systemBackground.withAlphaComponent(0.5)
        }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .label
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func showLoadingViewControllerIn(_ viewController: UIViewController, then: (() -> Void)? = nil) {
        viewController.addChild(self)
        self.view.frame = viewController.view.bounds
        viewController.view.addSubview(self.view)
        self.didMove(toParent: viewController)
        viewController.navigationItem.searchController?.searchBar.isHidden = true
        viewController.navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = false }
        then?()
    }
    
    func removeLoadingViewControllerIn(_ viewController: UIViewController, then: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3) {
            self.view.alpha = 0.0
            viewController.navigationItem.searchController?.searchBar.isHidden = false
            viewController.navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = true }
        } completion: { _ in
            let load = viewController.children.first { $0 is LoadingViewController }
            load?.willMove(toParent: nil)
            load?.view.removeFromSuperview()
            load?.removeFromParent()
            then?()
        }
    }
}
