//
//  DigWorkCallout.swift
//  TumenCity
//
//  Created by Павел Кай on 09.05.2023.
//

import UIKit
import SnapKit

final class DigWorkCallout: Callout {
    
    lazy var stackViewContent: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleView, calloutBody])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var titleView: CalloutIconWithTitleView = {
        return CalloutIconWithTitleView()
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
        
        contentView.addSubview(stackViewContent)
        
        setConstraints()
    }
    
    func configure(annotation: MKDigWorkAnnotation) {
        titleView.setTitle(with: annotation.title, icon: UIImage(named: "digWorkPin") ?? .add)

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
        stackViewContent.snp.makeConstraints {
            $0.top.equalTo(contentView).inset(15)
            $0.horizontalEdges.equalTo(alertBackground).inset(15)
            $0.bottom.equalTo(contentView).inset(15)
        }
    }
    
}
