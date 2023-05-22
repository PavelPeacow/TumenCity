//
//  TradeObjectsFilterBottomSheet.swift
//  TumenCity
//
//  Created by Павел Кай on 20.05.2023.
//

import UIKit

protocol TradeObjectsFilterBottomSheetDelegate: AnyObject {
    func didTapSubmitBtn(_ searchFilter: TradeObjectsSearch)
    func didTapClearBtn()
}

final class TradeObjectsFilterBottomSheet: CustomBottomSheet {
    
    var isObjectTypeFilterHidden = true {
        willSet {
            newValue ? objectTypeFilterBtn.setTitleColor(.label, for: .normal)
            : objectTypeFilterBtn.setTitleColor(.blue, for: .normal)
        }
    }
    var isPeriodFilterHidden = true {
        willSet {
            newValue ? periodFilterBtn.setTitleColor(.label, for: .normal)
            : periodFilterBtn.setTitleColor(.blue, for: .normal)
        }
    }
    
    var tradeObjectsType = [TradeObjectTypeRow]()
    var tradeObjectsPeriod = [TradeObjectPeriodRow]()
    
    var selectedTradeObjectsTypeID = Set<String>()
    var selectedTradeObjectsPeriodID = Set<String>()
    
    weak var delegate: TradeObjectsFilterBottomSheetDelegate?
    
    lazy var scrollViewMain: UIScrollView = {
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
    
    lazy var objectTypeCheckBoxesScrollable: ScrollableCheckBoxesList = {
        let scrollable = ScrollableCheckBoxesList(listType: .objectType)
        scrollable.translatesAutoresizingMaskIntoConstraints = false
        scrollable.delegate = self
        scrollable.isHidden = true
        return scrollable
    }()
    
    lazy var periodCheckBoxesScrollable: ScrollableCheckBoxesList = {
        let scrollable = ScrollableCheckBoxesList(listType: .periodType)
        scrollable.translatesAutoresizingMaskIntoConstraints = false
        scrollable.delegate = self
        scrollable.isHidden = true
        return scrollable
    }()
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [addressFilter, purposeFilter, objectTypeFilterBtn, objectTypeCheckBoxesScrollable, periodFilterBtn, periodCheckBoxesScrollable, clearFilterBtn, submitFilterBtn, clearFilterBtn])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var addressFilter: FilterView = {
        let filter = FilterView(filterLabel: Strings.TradeObjectsModule.BottomSheet.address)
        filter.translatesAutoresizingMaskIntoConstraints = false
        filter.textField.delegate = self
        return filter
    }()
    
    lazy var purposeFilter: FilterView = {
        let filter = FilterView(filterLabel: Strings.TradeObjectsModule.BottomSheet.purpose)
        filter.translatesAutoresizingMaskIntoConstraints = false
        filter.textField.delegate = self
        return filter
    }()
    
    lazy var objectTypeFilterBtn: MainButton = {
        let btn = MainButton(title: Strings.TradeObjectsModule.typeObject, cornerRadius: 8)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didTapObjectTypeFilterBtn), for: .touchUpInside)
        btn.backgroundColor = .systemGray5
        return btn
    }()
    
    lazy var periodFilterBtn: MainButton = {
        let btn = MainButton(title: Strings.TradeObjectsModule.period, cornerRadius: 8)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didTapPeriodFilterBtn), for: .touchUpInside)
        btn.backgroundColor = .systemGray5
        return btn
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
        
        setCallbacks()
        registerKeyboardNotification()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollViewMain)
        scrollViewMain.addSubview(contentView)
        contentView.addSubview(contentStackView)
        
        scrollViewMain.snp.makeConstraints {
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
        
        objectTypeCheckBoxesScrollable.snp.makeConstraints {
            $0.height.equalTo(100)
        }
        
        periodCheckBoxesScrollable.snp.makeConstraints {
            $0.height.equalTo(100)
        }
        
        preferredContentSize = CGSize(width: view.bounds.width,
                                      height: view.bounds.height / 1.5)
    }
    
    private func setCheckBoxes() {
        tradeObjectsType.forEach { type in
            let checkBox = CheckBoxWithTitle(title: type.title, checkBoxFilterId: type.id)
            objectTypeCheckBoxesScrollable.addCheckBox(checkBox)
        }
        
        tradeObjectsPeriod.forEach { period in
            let checkBox = CheckBoxWithTitle(title: period.title, checkBoxFilterId: period.id)
            periodCheckBoxesScrollable.addCheckBox(checkBox)
        }
    }
    
    private func hideScrollableCheckBoxList(_ checkBoxList: ScrollableCheckBoxesList, isHidden: Bool) {
        isHidden ? checkBoxList.hideScrollableCheckBoxesList(true) : checkBoxList.hideScrollableCheckBoxesList(false)
    }
    
    private func setCallbacks() {
        objectTypeCheckBoxesScrollable.checkBoxes.forEach {
            $0.didTapCheckBoxCallback = { id, isTapped in
                print(id, isTapped)
                
                if isTapped {
                    self.selectedTradeObjectsTypeID.insert(id)
                } else {
                    self.selectedTradeObjectsTypeID.remove(id)
                }
                
            }
        }
        
        periodCheckBoxesScrollable.checkBoxes.forEach {
            $0.didTapCheckBoxCallback = { id, isTapped in
                
                if isTapped {
                    self.selectedTradeObjectsPeriodID.insert(id)
                } else {
                    self.selectedTradeObjectsPeriodID.remove(id)
                }
            }
        }
        
        objectTypeCheckBoxesScrollable.checkBoxes.forEach {
            $0.selectCheckBox()
        }
        
        periodCheckBoxesScrollable.checkBoxes.forEach {
            $0.selectCheckBox()
        }
        
        let periodOperation = tradeObjectsPeriod
            .filter { !selectedTradeObjectsPeriodID.contains($0.id) }
            .map { $0.id }
            .joined(separator: ",")
        
        let objectType = tradeObjectsType
            .filter { !selectedTradeObjectsTypeID.contains($0.id) }
            .map { $0.id }
            .joined(separator: ",")
        
        print(periodOperation)
        print(objectType)
    }
    
    func configureFilters(tradeObjectsType: [TradeObjectTypeRow], tradeObjectsPeriod: [TradeObjectPeriodRow]) {
        self.tradeObjectsType = tradeObjectsType
        self.tradeObjectsPeriod = tradeObjectsPeriod
        
        setCheckBoxes()
    }
    
}

extension TradeObjectsFilterBottomSheet {
    
    @objc func didTapObjectTypeFilterBtn() {
        isObjectTypeFilterHidden.toggle()
        hideScrollableCheckBoxList(objectTypeCheckBoxesScrollable, isHidden: isObjectTypeFilterHidden)
    }
    
    @objc func didTapPeriodFilterBtn() {
        isPeriodFilterHidden.toggle()
        hideScrollableCheckBoxList(periodCheckBoxesScrollable, isHidden: isPeriodFilterHidden)
    }
    
    @objc func didTapSubmitBtn() {
        let periodOperation = tradeObjectsPeriod
            .filter { !selectedTradeObjectsPeriodID.contains($0.id) }
            .map { $0.id }
            .joined(separator: ",")
        
        let objectType = tradeObjectsType
            .filter { !selectedTradeObjectsTypeID.contains($0.id) }
            .map { $0.id }
            .joined(separator: ",")
        
        let locationAddress = addressFilter.textField.text ?? ""
        let intendedPurpose = purposeFilter.textField.text ?? ""
        
        let searchFilter = TradeObjectsSearch(periodOperation: periodOperation, objectType: objectType,
                                              locationAddress: locationAddress, numberObjectScheme: "",
                                              intendedPurpose: intendedPurpose)
        
        delegate?.didTapSubmitBtn(searchFilter)
        dismiss(animated: true)
    }
    
    @objc func didTapClearBtn() {
        delegate?.didTapClearBtn()
        dismiss(animated: true)
    }
    
}

//MARK: - NotificationCenter

extension TradeObjectsFilterBottomSheet {
    
    private func registerKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let keyboardHeight = keyboardSize.height
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollViewMain.contentInset = contentInsets
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollViewMain.contentInset = contentInsets
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
    
}