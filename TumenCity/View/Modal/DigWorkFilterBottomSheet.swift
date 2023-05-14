//
//  DigWorkFilterBottomSheet.swift
//  TumenCity
//
//  Created by Павел Кай on 13.05.2023.
//

import UIKit
import SnapKit

final class DigWorkFilterBottomSheet: CustomBottomSheet {
    
    let zones = Strings.DigWorkFilterBottomSheet.zones
    let typeOfWork = Strings.DigWorkFilterBottomSheet.typeOfWork
    let status = Strings.DigWorkFilterBottomSheet.status
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [personFilter, zoneFilter, typeOfWorkFilter,
                                                       statusFilter, dateAfterFilter, dateBeforeFilter,
                                                       submitFilterBtn, clearFilterBtn])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var personFilter: FilterView = {
        let filter = FilterView(filterLabel: Strings.DigWorkFilterBottomSheet.personFilterString)
        filter.translatesAutoresizingMaskIntoConstraints = false
        return filter
    }()
    
    lazy var zoneFilter: FilterView = {
        let filter = FilterView(filterLabel: Strings.DigWorkFilterBottomSheet.zoneFilterString)
        filter.translatesAutoresizingMaskIntoConstraints = false
        filter.textField.text = zones.first
        filter.textField.inputView = filterTypePickerView
        filter.textField.delegate = self
        return filter
    }()
    
    lazy var typeOfWorkFilter: FilterView = {
        let filter = FilterView(filterLabel: Strings.DigWorkFilterBottomSheet.typeOfWorkFilterString)
        filter.translatesAutoresizingMaskIntoConstraints = false
        filter.textField.inputView = filterTypePickerView
        filter.textField.text = typeOfWork.first
        filter.textField.delegate = self
        return filter
    }()
    
    lazy var statusFilter: FilterView = {
        let filter = FilterView(filterLabel: Strings.DigWorkFilterBottomSheet.statusFilterString)
        filter.translatesAutoresizingMaskIntoConstraints = false
        filter.textField.inputView = filterTypePickerView
        filter.textField.text = status.first
        filter.textField.delegate = self
        return filter
    }()
    
    lazy var dateAfterFilter: FilterView = {
        let filter = FilterView(filterLabel: Strings.DigWorkFilterBottomSheet.dateAfterFilterString)
        filter.translatesAutoresizingMaskIntoConstraints = false
        filter.textField.inputView = filterDatePickerView
        return filter
    }()
    
    lazy var dateBeforeFilter: FilterView = {
        let filter = FilterView(filterLabel: Strings.DigWorkFilterBottomSheet.dateBeforeFilterString)
        filter.translatesAutoresizingMaskIntoConstraints = false
        filter.textField.inputView = filterDatePickerView
        return filter
    }()
    
    lazy var filterTypePickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    
    lazy var filterDatePickerView: UIDatePicker = {
        let picker = UIDatePicker()
        picker.addTarget(self, action: #selector(didSelectDate), for: .valueChanged)
        picker.datePickerMode = .date
        return picker
    }()
    
    lazy var submitFilterBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 12
        btn.layer.borderColor = UIColor.gray.cgColor
        btn.layer.borderWidth = 1
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle(Strings.DigWorkFilterBottomSheet.submitFilterBtnStrings, for: .normal)
        btn.setTitleColor(.label, for: .normal)
        btn.addTarget(self, action: #selector(didTapSubmitBtn), for: .touchUpInside)
        return btn
    }()
    
    lazy var clearFilterBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 12
        btn.layer.borderColor = UIColor.gray.cgColor
        btn.layer.borderWidth = 1
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle(Strings.DigWorkFilterBottomSheet.clearFilterBtn, for: .normal)
        btn.setTitleColor(.label, for: .normal)
        btn.addTarget(self, action: #selector(didTapClearBtn), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)
        
        scrollView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(topInset)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview().priority(.low)
            $0.width.equalToSuperview()
        }
        
        contentStackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(25)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        contentStackView.layoutIfNeeded()
        var preferredSize = CGSize(width: view.bounds.width,
                                   height: contentStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + topInset * 2)
        
        if preferredSize.height > UIScreen().bounds.height / 2 {
            preferredSize = CGSize(width: view.bounds.width, height: view.bounds.height / 2)
        }
        
        preferredContentSize = preferredSize
        print(preferredContentSize)
    }
    
}

#warning("Do filter logic")
extension DigWorkFilterBottomSheet {
    
    @objc func didSelectDate(_ datePicker: UIDatePicker) {
        
    }
    
    @objc func didTapSubmitBtn() {
        dismiss(animated: true)
    }
    
    @objc func didTapClearBtn() {
        view.endEditing(true)
    }
    
}

extension DigWorkFilterBottomSheet: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        filterTypePickerView.reloadAllComponents()
        filterTypePickerView.selectRow(0, inComponent: 0, animated: false)
    }
    
}

extension DigWorkFilterBottomSheet: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if zoneFilter.textField.isFirstResponder {
            return zones.count
        } else if typeOfWorkFilter.textField.isFirstResponder {
            return typeOfWork.count
        } else if statusFilter.textField.isFirstResponder {
            return status.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if zoneFilter.textField.isFirstResponder {
            return zones[row]
        } else if typeOfWorkFilter.textField.isFirstResponder {
            return typeOfWork[row]
        } else if statusFilter.textField.isFirstResponder {
            return status[row]
        }
        return nil
    }

}

extension DigWorkFilterBottomSheet: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if zoneFilter.textField.isFirstResponder {
            zoneFilter.textField.text = zones[row]
        } else if typeOfWorkFilter.textField.isFirstResponder {
            typeOfWorkFilter.textField.text = typeOfWork[row]
        } else if statusFilter.textField.isFirstResponder {
            statusFilter.textField.text = status[row]
        }
        view.endEditing(true)
    }
    
}
