//
//  CalloutService.swift
//  TumenCity
//
//  Created by Павел Кай on 23.04.2023.
//

import UIKit

final class CalloutService: UIViewController {
    
    private weak var targetViewController: UIViewController!
    
    private lazy var alertBackground: UIView = {
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
    
    lazy var accidentCategoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [address, organization, dateStart, dateFinish])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var address: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    lazy var accident: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var organization: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var dateStart: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var dateFinish: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black.withAlphaComponent(0.75)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view.addGestureRecognizer(gesture)
        
        view.addSubview(stackView)
        
        view.addSubview(alertBackground)
        alertBackground.addSubview(stackView)
        
        setConstraints()
    }
    
    @objc func didTapView() {
        moveOut()
    }
    
    func configure(annotations: [MKItemAnnotation]) {
        guard let annotation = annotations.first else { return }
        
        address.text = "Адрес: \(annotation.markDescription.address)"
        organization.text = "Устраняющая организация:\n\(annotation.orgTitle)"
        dateStart.text = "Дата начала работ:\n\(annotation.dateStart)"
        dateFinish.text = "Дата окончания работ:\n\(annotation.dateFinish)"
        
        let colors = annotations.uniques(by: \.color).map { $0.color }
        
        for annotation in annotations.sorted(by: { $0.index > $1.index }) {
            
            let image = annotation.image
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            
            let label = UILabel()
            label.text = annotation.markDescription.accident
            
            let stackView = UIStackView(arrangedSubviews: [imageView, label])
            stackView.distribution = .fill
            stackView.alignment = .center
            stackView.axis = .horizontal
            stackView.spacing = 8
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                imageView.heightAnchor.constraint(equalToConstant: 25),
                imageView.widthAnchor.constraint(equalToConstant: 25),
            ])
            
            self.stackView.insertArrangedSubview(stackView, at: 1)
            
        }
        
        view.layoutSubviews()
        
        if annotations.count == 1 {
            alertBackground.layer.borderColor = annotation.color.cgColor
        } else {
            alertBackground.addGradientBorder(bounds: alertBackground.bounds, colors: colors)
        }
        alertBackground.layer.borderWidth = 2.5
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

extension CalloutService {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            alertBackground.topAnchor.constraint(equalTo: stackView.topAnchor, constant: -15),
            alertBackground.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 15),
            alertBackground.widthAnchor.constraint(equalToConstant: 280),

            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.leadingAnchor.constraint(equalTo: alertBackground.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: alertBackground.trailingAnchor, constant: -15),
            
        ])
    }
    
}
