//
//  CustomBottomSheet.swift
//  TumenCity
//
//  Created by Павел Кай on 13.05.2023.
//

import UIKit
import SnapKit

class CustomBottomSheet: UIViewController {
    
    private var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    var scrollViewOfSheet: UIScrollView?
    var fittingViewOfSheet: UIView?
    var isKeyboardActive = false
    var isFullscreen = false
    
    var topInset: CGFloat {
        40
    }
    
    private lazy var roundedElement: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        return view
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setModal()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
        view.addSubview(roundedElement)
        
        roundedElement.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(8)
            $0.width.equalTo(view).dividedBy(5)
        }
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
        
    private func setModal() {
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    func setViewsForCalculatingPrefferedSize(scrollView: UIScrollView? = nil, fittingView: UIView? = nil) {
        self.scrollViewOfSheet = scrollView
        self.fittingViewOfSheet = fittingView
    }
    
    func changeBottomSheetToCoverAllScreen() {
        isFullscreen = true
        UIView.animate(withDuration: 0.3) {
            self.view.frame = self.presentationController?.containerView?.bounds ?? .zero
            self.view.layoutIfNeeded()
        }
    }
    
    func changeBottomSheetToDefaultHeight() {
        guard !isKeyboardActive else { return }
        isFullscreen = false
        UIView.animate(withDuration: 0.3) {
            self.setPrefferdSize()
            self.view.frame = CGRect(origin: self.pointOrigin!, size: self.preferredContentSize)
        }
    }
    
}

extension CustomBottomSheet {
    
    func setPrefferdSize() {
        guard let fittingViewOfSheet else {
            preferredContentSize = CGSize(width: view.bounds.width,
                                          height: view.bounds.height / 1.5)
            return
        }
        var preferredSize = CGSize(width: view.bounds.width,
                                   height: fittingViewOfSheet.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + topInset * 2)
        
        if preferredSize.height > UIScreen().bounds.height / 2 {
            preferredSize = CGSize(width: view.bounds.width, height: view.bounds.height / 2)
        }
        preferredContentSize = preferredSize
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        isKeyboardActive = true
        view.frame = presentationController?.containerView?.bounds ?? .zero
        if let scrollViewOfSheet {
            scrollViewOfSheet.contentInset.bottom = keyboardFrame.height + 10
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        isKeyboardActive = false
        guard !isFullscreen else { return }
        setPrefferdSize()
        view.frame = CGRect(origin: pointOrigin!, size: preferredContentSize)
        if let scrollViewOfSheet {
            scrollViewOfSheet.contentInset.bottom = 0
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
}

private extension CustomBottomSheet {
#warning("currently remove draggin because of keyboard appearing")
    @objc private func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
//        guard let pointOrigin = self.pointOrigin else { return }
//        
//        let translation = sender.translation(in: view)
//        guard translation.y >= 0 else { return }
//        
//        view.frame.origin.y = pointOrigin.y + translation.y
//        
//        if sender.state == .ended {
//            let draggedToDismiss = translation.y > view.bounds.height / 3.0
//            let dragVelocity = sender.velocity(in: view)
//            if draggedToDismiss || dragVelocity.y >= 1300 {
//                dismiss(animated: true, completion: nil)
//            } else {
//                UIView.animate(withDuration: 0.3) {
//                    self.view.frame.origin.y = pointOrigin.y
//                }
//            }
//        }
    }
    
}

extension CustomBottomSheet: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}

final class PresentationController: UIPresentationController {
    
    let blurEffectView: UIVisualEffectView!
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.isUserInteractionEnabled = true
        blurEffectView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let preferredContentSize = presentedViewController.preferredContentSize
        let height = preferredContentSize.height
        let origin = CGPoint(x: 0, y: self.containerView!.frame.height - height)
        let size = CGSize(width: self.containerView!.frame.width, height: height)
        return CGRect(origin: origin, size: size)
    }
    
    override func presentationTransitionWillBegin() {
        blurEffectView.alpha = 0
        containerView?.addSubview(blurEffectView)
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.alpha = 0.7
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in })
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.alpha = 0
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.removeFromSuperview()
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedView?.layer.cornerRadius = 15
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        blurEffectView.frame = containerView!.bounds
    }
    
    @objc func dismissController(){
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
