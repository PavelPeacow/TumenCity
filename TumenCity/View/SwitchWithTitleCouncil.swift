//
//  SwitchWithTitleCouncil.swift
//  TumenCity
//
//  Created by Павел Кай on 15.07.2023.
//

import UIKit

enum SwitchWithTitleCouncilType: String {
    case ddit = "ДДиТ"
    case vao = "УВАО"
    case cao = "УЦАО"
    case lao = "УЛАО"
    case kao = "УКАО"
}

class SwitchWithTitleCouncil: SwitchWithTitle {
    
    let type: SwitchWithTitleCouncilType
    
    init(switchTitle: String, isOn: Bool = false, onTintColor: UIColor? = nil, backgroundColor: UIColor? = nil, type: SwitchWithTitleCouncilType) {
        self.type = type
        super.init(switchTitle: switchTitle, isOn: isOn, onTintColor: onTintColor, backgroundColor: backgroundColor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
