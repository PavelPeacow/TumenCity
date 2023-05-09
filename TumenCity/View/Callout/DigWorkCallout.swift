//
//  DigWorkCallout.swift
//  TumenCity
//
//  Created by Павел Кай on 09.05.2023.
//

import UIKit
import SnapKit

final class DigWorkCallout: Callout {
    
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
    
    lazy var stackViewContent: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [stackViewTitle, calloutBody])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var stackViewTitle: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [calloutIcon, calloutTitle])
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    lazy var calloutIcon: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "digWorkPin")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    lazy var calloutTitle: UILabel = {
        let label = UILabel()
        label.font = . systemFont(ofSize: 17, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var calloutBody: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertBackground.layer.borderColor = UIColor.green.cgColor
        
        alertBackground.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(stackViewContent)
        
        setConstraints()
    }
    
    func configure(annotation: MKDigWorkAnnotation) {
        calloutTitle.text = annotation.title
        
        let modifiedHtmlString = annotation.contentDescription.replacingOccurrences(of: "<p>", with: "<p style=\"margin: 0; padding: 0;\">")
        
        if let htmlData = modifiedHtmlString.data(using: .unicode) {
            
            let attributedString = try? NSMutableAttributedString(data: htmlData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
            calloutBody.attributedText = attributedString
            calloutBody.textColor = .label
            calloutBody.font = UIFont.systemFont(ofSize: 16)
        }

    }
    
}

extension DigWorkCallout {
    
    func setConstraints() {
        alertBackground.snp.makeConstraints {
            $0.topMargin.greaterThanOrEqualToSuperview().inset(10)
            $0.bottomMargin.lessThanOrEqualToSuperview().inset(10)
            $0.width.equalToSuperview().inset(25)
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
        
        stackViewContent.snp.makeConstraints {
            $0.top.equalTo(contentView).inset(15)
            $0.horizontalEdges.equalTo(alertBackground).inset(15)
            $0.bottom.equalTo(contentView).inset(15)
        }
    }
    
}
