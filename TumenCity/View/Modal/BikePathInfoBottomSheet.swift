//
//  BikePathInfoBottomSheet.swift
//  TumenCity
//
//  Created by Павел Кай on 14.05.2023.
//

import UIKit
import SnapKit

class BikePathInfoBottomSheet: CustomBottomSheet {
    
    var bikeInfoItems = [BikePathInfoLegend]()
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 8
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(contentStackView)
        
        contentStackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(25)
            $0.top.equalToSuperview().inset(topInset)
        }
        
        contentStackView.layoutIfNeeded()
        let preferredSize = CGSize(width: view.bounds.width,
                                   height: contentStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + topInset * 2)
        
        preferredContentSize = preferredSize
        
    }
    
    private func createInfoItems() {
        bikeInfoItems.forEach { item in
            let infoIcon = item.icon
            let infoDescription = item.title
            
            let infoItemView = BikePathsInfoItemView()
            infoItemView.configure(infoIcon: infoIcon, infoDescrtiption: infoDescription)
            
            contentStackView.addArrangedSubview(infoItemView)
        }
    }
    
    func configure(bikeInfoItems: [BikePathInfoLegend]) {
        self.bikeInfoItems = bikeInfoItems
        createInfoItems()
    }

}
