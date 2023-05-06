//
//  Callout.swift
//  TumenCity
//
//  Created by Павел Кай on 23.04.2023.
//

import UIKit

class Callout: UIViewController {
    
    private weak var targetViewController: UIViewController!
    
    lazy var alertBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.isUserInteractionEnabled = false
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurView, at: 0)
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(alertBackground)
        view.backgroundColor = .black.withAlphaComponent(0.75)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view.addGestureRecognizer(gesture)
    }
    
    @objc func didTapView() {
        moveOut()
    }
    
    func showAlert(in viewController: UIViewController) {
        targetViewController = viewController

        targetViewController.addChild(self)
        self.view.frame = targetViewController.view.frame
        targetViewController.view.addSubview(self.view)
        self.didMove(toParent: targetViewController)
        targetViewController.navigationController?.navigationBar.isUserInteractionEnabled = false
        
        moveIn()
    }
        
    private func moveIn() {
        self.view.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        self.view.alpha = 0.0
        
        UIView.animate(withDuration: 0.24) {
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.view.alpha = 1.0
        }
    }
    
    private func moveOut() {
        UIView.animate(withDuration: 0.24, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
            self.view.alpha = 0.0
        }) { _ in
            self.targetViewController.navigationController?.navigationBar.isUserInteractionEnabled = true
            self.view.removeFromSuperview()
        }
    }
    
}

