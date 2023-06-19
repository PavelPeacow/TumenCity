//
//  LoadingView.swift
//  TumenCity
//
//  Created by Павел Кай on 19.06.2023.
//

import UIKit
import RxSwift
import RxRelay

final class LoadingView: UIView {
    
    var isLoadingSubject = BehaviorRelay(value: false)
    var bag = DisposeBag()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .label
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(activityIndicator)
        backgroundColor = .systemGray.withAlphaComponent(0.5)
        
        activityIndicator.center = center

        setUpBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpBindings() {
        isLoadingSubject
            .asObservable()
            .skip(while: { $0 == false })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] isLoading in
                if isLoading {
                    startLoading()
                } else {
                    stopLoading()
                }
            })
            .disposed(by: bag)
    }
    
    func startLoading() {
        activityIndicator.startAnimating()
        backgroundColor = .systemGray.withAlphaComponent(0.5)
        self.isHidden = false
    }
    
    func stopLoading() {
        activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = .systemGray.withAlphaComponent(0)
        } completion: { _ in
            self.isHidden = true
        }
    }
}
