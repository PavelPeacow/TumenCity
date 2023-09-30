//
//  ScrollableCheckBoxesList.swift
//  TumenCity
//
//  Created by Павел Кай on 21.05.2023.
//

import UIKit

enum ScrollableCheckBoxesListType {
    case objectType
    case periodType
}

protocol ScrollableCheckBoxesListDelegate: AnyObject {
    func didTapSelectAllCheckBoxesBtn(with type: ScrollableCheckBoxesListType)
    func didTapUnSelectAllCheckBoxesBtn(with type: ScrollableCheckBoxesListType)
}

final class ScrollableCheckBoxesList: UIView {
    
    var checkBoxes = [CheckBoxWithTitle]()
    
    var listType: ScrollableCheckBoxesListType!
    
    weak var delegate: ScrollableCheckBoxesListDelegate?
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var checkBoxesListStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [checkBoxesBtnsStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 6
        return stackView
    }()
    
    lazy var checkBoxesBtnsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [selectAllObjectTypeCheckboxes, unSelectAllObjectTypeCheckboxes])
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal
        return stackView
    }()
    
    lazy var selectAllObjectTypeCheckboxes: MainButton = {
        let btn = MainButton(title: L10n.TradeObjects.BottomSheet.Buttons.selectAll)
        btn.addTarget(self, action: #selector(didTapSelectAllObjectTypeCheckboxesBtn), for: .touchUpInside)
        return btn
    }()
    
    lazy var unSelectAllObjectTypeCheckboxes: MainButton = {
        let btn = MainButton(title: L10n.TradeObjects.BottomSheet.Buttons.deselectAll)
        btn.addTarget(self, action: #selector(didTapUnSelectAllObjectTypeCheckboxesBtn), for: .touchUpInside)
        return btn
    }()
        
    init(listType: ScrollableCheckBoxesListType) {
        super.init(frame: .zero)
        
        self.listType = listType
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(checkBoxesListStackView)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview().priority(.low)
            $0.width.equalToSuperview()
        }
        
        checkBoxesListStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addCheckBox(_ checkBox: CheckBoxWithTitle) {
        checkBoxes.append(checkBox)
        checkBoxesListStackView.addArrangedSubview(checkBox)
    }
    
    func hideScrollableCheckBoxesList(_ force: Bool) {
        checkBoxes.forEach { $0.isHidden = force }
        checkBoxesBtnsStackView.arrangedSubviews.forEach { $0.isHidden = force }
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.isHidden = force
            
        }
    }
    
}

extension ScrollableCheckBoxesList {
    
    @objc func didTapSelectAllObjectTypeCheckboxesBtn() {
        checkBoxes.forEach {
            $0.selectCheckBox()
        }
        
        delegate?.didTapSelectAllCheckBoxesBtn(with: listType)
    }
    
    @objc func didTapUnSelectAllObjectTypeCheckboxesBtn() {
        checkBoxes.forEach {
            $0.unSelectCheckBox()
        }
        
        delegate?.didTapUnSelectAllCheckBoxesBtn(with: listType)
    }
    
}
