//
//  Callout.swift
//  TumenCity
//
//  Created by Павел Кай on 23.04.2023.
//

import UIKit

class Callout: UIViewController {
    
    private weak var targetViewController: UIViewController!
    
    var calloutTapGesture: UITapGestureRecognizer!
    
    lazy var alertBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        view.layer.borderWidth = 2.5
        
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.isUserInteractionEnabled = false
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurView, at: 0)
        
        return view
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.flashScrollIndicators()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(alertBackground)
        alertBackground.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        alertBackground.snp.makeConstraints {
            $0.topMargin.greaterThanOrEqualToSuperview().inset(10)
            $0.bottomMargin.lessThanOrEqualToSuperview().inset(10)
            $0.width.equalToSuperview().inset(10)
            $0.center.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview().priority(.low)
            $0.width.equalToSuperview()
        }
        
        view.backgroundColor = .black.withAlphaComponent(0.75)
        
        calloutTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view.addGestureRecognizer(calloutTapGesture)
    }
    
    @objc func didTapView() {
        moveOut()
    }
    
    func showAlert(in viewController: UIViewController) {
        #warning("show only one callout at time fixed")
        guard viewController.children.count == 0 else { return }
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
            self.removeFromParent()
            self.view.removeFromSuperview()
        }
    }
    
}

