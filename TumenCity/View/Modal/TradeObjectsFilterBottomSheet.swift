//
//  TradeObjectsFilterBottomSheet.swift
//  TumenCity
//
//  Created by Павел Кай on 20.05.2023.
//

import UIKit

final class TradeObjectsFilterBottomSheet: CustomBottomSheet {
    
    lazy var objectTypeCheckBoxesScrollable: ScrollableCheckBoxesList = {
        let scrollable = ScrollableCheckBoxesList(listType: .objectType)
        scrollable.translatesAutoresizingMaskIntoConstraints = false
        scrollable.delegate = self
        return scrollable
    }()
    
    lazy var periodCheckBoxesScrollable: ScrollableCheckBoxesList = {
        let scrollable = ScrollableCheckBoxesList(listType: .periodType)
        scrollable.translatesAutoresizingMaskIntoConstraints = false
        scrollable.delegate = self
        return scrollable
    }()
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [addressFilter, purposeFilter, objectTypeFilter, objectTypeCheckBoxesScrollable, periodFilter, periodCheckBoxesScrollable, clearFilterBtn, submitFilterBtn, clearFilterBtn])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var addressFilter: FilterView = {
        let filter = FilterView(filterLabel: Strings.TradeObjectsModule.BottomSheet.address)
        filter.translatesAutoresizingMaskIntoConstraints = false
        return filter
    }()
    
    lazy var purposeFilter: FilterView = {
        let filter = FilterView(filterLabel: Strings.TradeObjectsModule.BottomSheet.purpose)
        filter.translatesAutoresizingMaskIntoConstraints = false
        return filter
    }()
    
    lazy var objectTypeFilter: FilterView = {
        let filter = FilterView(filterLabel: Strings.TradeObjectsModule.BottomSheet.objectType)
        filter.textField.delegate = self
        filter.translatesAutoresizingMaskIntoConstraints = false
        return filter
    }()
    
    lazy var periodFilter: FilterView = {
        let filter = FilterView(filterLabel: Strings.TradeObjectsModule.BottomSheet.period)
        filter.textField.delegate = self
        filter.translatesAutoresizingMaskIntoConstraints = false
        return filter
    }()
    
    lazy var submitFilterBtn: MainButton = {
        let btn = MainButton(title: Strings.ButtonTitle.submitFilterBtnStrings)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didTapSubmitBtn), for: .touchUpInside)
        return btn
    }()
    
    lazy var clearFilterBtn: UIButton = {
        let btn = MainButton(title: Strings.ButtonTitle.clearFilterBtn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didTapClearBtn), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(contentStackView)
        
        objectTypeCheckBoxesScrollable.snp.makeConstraints {
            $0.height.equalTo(100)
        }
        
        periodCheckBoxesScrollable.snp.makeConstraints {
            $0.height.equalTo(100)
        }
        
        contentStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(25)
            $0.top.equalToSuperview().inset(topInset)
        }
        
        setCheckBoxes()
        
        let size = CGSize(width: view.bounds.width, height: contentStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + topInset * 2)
        
        preferredContentSize = size
    }
    
    private func setCheckBoxes() {
        Strings.TradeObjectsModule.BottomSheet.checkBoxTypes.forEach { type in
            let checkBox = CheckBoxWithTitle(title: type)
            objectTypeCheckBoxesScrollable.addCheckBox(checkBox)
        }
        

        Strings.TradeObjectsModule.BottomSheet.checkBoxPeriod.forEach { period in
            let checkBox = CheckBoxWithTitle(title: period)
            periodCheckBoxesScrollable.addCheckBox(checkBox)
        }
    }
    
    private func hideScrollableCheckBoxList(by textField: UITextField, isHidden: Bool) {
        if textField == objectTypeFilter.textField {
            objectTypeCheckBoxesScrollable.hideScrollableCheckBoxesList(isHidden)
        }
        else if textField == periodFilter.textField {
            periodCheckBoxesScrollable.hideScrollableCheckBoxesList(isHidden)
        }
    }
    
}

extension TradeObjectsFilterBottomSheet {
        
    @objc func didTapSubmitBtn() {
        
    }
    
    @objc func didTapClearBtn() {
        
    }
    
}

extension TradeObjectsFilterBottomSheet: ScrollableCheckBoxesListDelegate {
    
    func didTapSelectAllCheckBoxesBtn(with type: ScrollableCheckBoxesListType) {
        print(type)
    }
    
    func didTapUnSelectAllCheckBoxesBtn(with type: ScrollableCheckBoxesListType) {
        print(type)
    }
    
}

extension TradeObjectsFilterBottomSheet: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideScrollableCheckBoxList(by: textField, isHidden: false)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        hideScrollableCheckBoxList(by: textField, isHidden: true)
    }
    
}
