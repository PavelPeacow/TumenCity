//
//  IndicatorCollectionViewListCell.swift
//  TumenCity
//
//  Created by Павел Кай on 23.07.2023.
//

import UIKit

final class IndicatorCollectionViewListCell: UICollectionViewListCell {
    
    static let identifier = "IndicatorCollectionViewListCell"
    
    func configureCell(title: String, textStyle: UIFont,
                       cellIndex: Int, isSubitem: Bool, detailAction: UIAction) {
        var contentConfiguration = defaultContentConfiguration()
        contentConfiguration.text = title
        contentConfiguration.textProperties.font = textStyle
        contentConfiguration.textProperties.color = .label
        self.contentConfiguration = contentConfiguration
        
        let detailDisclosure = UIButton(type: .detailDisclosure, primaryAction: detailAction)
        let customAccessory = UICellAccessory.CustomViewConfiguration(customView: detailDisclosure,
                                                             placement: .trailing(displayed: .always))
        
        accessories = [.customView(configuration: customAccessory)]
        
        if !isSubitem && cellIndex != 0 {
            let disclosureOptions = UICellAccessory.OutlineDisclosureOptions(style: .header)
            accessories.append(.outlineDisclosure(options: disclosureOptions))
        }
    }
}
