//
//  DigWorkFilterBottomSheet.swift
//  TumenCity
//
//  Created by Павел Кай on 13.05.2023.
//

import UIKit
import SnapKit
import RxSwift

enum DigWorkZones: String, CaseIterable {
    case all = "Все"
    case vao = "ВАО"
    case cao = "ЦАО"
    case lao = "ЛАО"
    case kao = "КАО"
}

enum DigWorkTypesOfWork: String, CaseIterable {
    case all = "Все"
    case reconstruction = "Реконструкция, перенос, переустройство, ремонт ИК"
    case incidents = "Аварии, инцидента на ИК"
    case techAdding = "Технологическое присоединение к сетям ИТ"
    case adsConstructions = "Установка/эксплуатация рекламных конструкций"
}

enum DigWorkStatus: String, CaseIterable {
    case all = "Все"
    case notificationSend = "Подано уведомление"
    case registered = "Зарегистрировано"
    case refuse = "Отказано"
    case awaitWork = "Ожидание работы"
    case inWork = "В работе"
    case recovery = "Восстановление"
    case warranty = "Гарантийный период"
    case completeWork = "Завершенная работа"
    case expertise = "Экспертиза"
    case awaitSummer = "Ожидание восстановления в летнем варианте"
    case error = "Ошибка"
}

final class DigWorkFilterBottomSheet: CustomBottomSheet {
    
    private lazy var zones = DigWorkZones.allCases
    private lazy var typeOfWork = DigWorkTypesOfWork.allCases
    private lazy var status = DigWorkStatus.allCases
    
//    lazy var selectedPerson = ""
    private lazy var selectedZone = zones[0]
    private lazy var selectedTypeOfWork = typeOfWork[0]
    private lazy var selectedStatus = status[0]
    private lazy var selectedDateAfter = ""
    private lazy var selectedDateBefore = ""
    
    private let selectedFilter = PublishSubject<DigWorkFilter>()
    private let didDismissed = PublishSubject<Void>()
    
    var selectedFilterObservable: Observable<DigWorkFilter> {
        selectedFilter.asObservable()
    }
    var didDismissedObservable: Observable<Void> {
        didDismissed.asObservable()
    }
    
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
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [personFilter, zoneFilter, typeOfWorkFilter,
                                                       statusFilter, dateAfterFilter, dateBeforeFilter,
                                                       submitFilterBtn, clearFilterBtn])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var personFilter: FilterView = {
        let filter = FilterView(filterLabel: L10n.DigWork.BottomSheet.personFilterString)
        filter.translatesAutoresizingMaskIntoConstraints = false
        filter.textField.delegate = self
        return filter
    }()
    
    lazy var zoneFilter: FilterView = {
        let filter = FilterView(filterLabel: L10n.DigWork.BottomSheet.zoneFilterString)
        filter.translatesAutoresizingMaskIntoConstraints = false
        filter.textField.text = zones[0].rawValue
        filter.textField.inputView = filterTypePickerView
        filter.textField.inputAccessoryView = createDoneToolbar()
        filter.textField.delegate = self
        return filter
    }()
    
    lazy var typeOfWorkFilter: FilterView = {
        let filter = FilterView(filterLabel: L10n.DigWork.BottomSheet.typeOfWorkFilterString)
        filter.translatesAutoresizingMaskIntoConstraints = false
        filter.textField.inputView = filterTypePickerView
        filter.textField.inputAccessoryView = createDoneToolbar()
        filter.textField.text = typeOfWork[0].rawValue
        filter.textField.delegate = self
        return filter
    }()
    
    lazy var statusFilter: FilterView = {
        let filter = FilterView(filterLabel: L10n.DigWork.BottomSheet.statusFilterString)
        filter.translatesAutoresizingMaskIntoConstraints = false
        filter.textField.inputView = filterTypePickerView
        filter.textField.inputAccessoryView = createDoneToolbar()
        filter.textField.text = status[0].rawValue
        filter.textField.delegate = self
        return filter
    }()
    
    lazy var dateAfterFilter: FilterView = {
        let filter = FilterView(filterLabel: L10n.DigWork.BottomSheet.dateAfterFilterString)
        filter.translatesAutoresizingMaskIntoConstraints = false
        filter.textField.inputView = filterDatePickerViewAfter
        filter.textField.inputAccessoryView = createDoneToolbar()
        filter.textField.text = formatDate(Date())
        return filter
    }()
    
    lazy var dateBeforeFilter: FilterView = {
        let filter = FilterView(filterLabel: L10n.DigWork.BottomSheet.dateBeforeFilterString)
        filter.translatesAutoresizingMaskIntoConstraints = false
        filter.textField.inputView = filterDatePickerViewBefore
        filter.textField.inputAccessoryView = createDoneToolbar()
        return filter
    }()
    
    lazy var filterTypePickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    
    lazy var filterDatePickerViewAfter: UIDatePicker = {
        let screenWidth = UIScreen.main.bounds.width
        let picker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
        picker.addTarget(self, action: #selector(didSelectDate), for: .valueChanged)
        picker.datePickerMode = .date
        picker.calendar = .current
        picker.maximumDate = Date()
        picker.preferredDatePickerStyle = .wheels
        picker.sizeToFit()
        return picker
    }()
    
    lazy var filterDatePickerViewBefore: UIDatePicker = {
        let screenWidth = UIScreen.main.bounds.width
        let picker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
        picker.addTarget(self, action: #selector(didSelectDate), for: .valueChanged)
        picker.datePickerMode = .date
        picker.calendar = .current
        picker.minimumDate = Date()
        picker.preferredDatePickerStyle = .wheels
        picker.sizeToFit()
        return picker
    }()
    
    lazy var submitFilterBtn: MainButton = {
        let btn = MainButton(title: L10n.ButtonTitle.submitFilterBtnStrings)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didTapSubmitBtn), for: .touchUpInside)
        return btn
    }()
    
    lazy var clearFilterBtn: MainButton = {
        let btn = MainButton(title: L10n.ButtonTitle.clearFilterBtn)
        btn.translatesAutoresizingMaskIntoConstraints = false
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
        setViewsForCalculatingPrefferedSize(scrollView: scrollView, fittingView: contentStackView)
        setPrefferdSize()
    }
    
    func createDoneToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()

        let doneButton = UIBarButtonItem(
            title: L10n.DigWork.BottomSheet.toolbarDone,
            style: .done,
            target: self,
            action: #selector(doneButtonTapped)
        )
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        return toolbar
    }
    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    private func formatModel() -> DigWorkFilter {
        let person = personFilter.textField.text ?? ""
        let formatedZone = formatZoneModel()
        let formatedTypeOfWork = formatTypeOfWorkModel()
        let formatedStatus = formatStatusModel()
        let startDate = selectedDateAfter
        let endDate = selectedDateBefore
        
        return DigWorkFilter(person: person, zone: formatedZone, missionType: formatedTypeOfWork,
                             state: formatedStatus, startWorkTime: startDate, endWorkTime: endDate)
    }
    
    private func formatZoneModel() -> String {
        switch selectedZone {
            
        case .all:
            ""
        case .vao:
            "3067f20c-800f-46ca-9316-911a39f716c7"
        case .cao:
            "768eac72-1dbd-4cad-9d6d-fccdd0a5809a"
        case .lao:
            "c9e821e3-eb5a-4585-83cb-b67661bca8bb"
        case .kao:
            "eb21086b-b5fa-462b-9e4a-6a554cf01d5c"
        }
    }
    
    private func formatTypeOfWorkModel() -> String {
        switch selectedTypeOfWork {

        case .all:
            ""
        case .reconstruction:
            "RECONSTRUCTION"
        case .incidents:
            "LIQUIDATION_ACCIDENT"
        case .techAdding:
            "TECHNOLOGICAL_CONNECTION"
        case .adsConstructions:
            "ADVERTISING_STRUCTURE"
        }
    }
    
    private func formatStatusModel() -> String {
        switch selectedStatus {
            
        case .all:
            ""
        case .notificationSend:
            "NOTIFICATION_FILED"
        case .registered:
            "REGISTERED"
        case .refuse:
            "REFUSAL"
        case .awaitWork:
            "WAITING_WORK"
        case .inWork:
            "WAITING_WORK"
        case .recovery:
            "RECOVERY"
        case .warranty:
            "WARRANTY_PERIOD"
        case .completeWork:
            "COMPLETED_WORK"
        case .expertise:
            "EXPERTISE"
        case .awaitSummer:
            "WAITING_SUMMER_TYPE_RECOVERY"
        case .error:
            "ERROR"
        }
    }
}

#warning("Do filter logic")
extension DigWorkFilterBottomSheet {
    
    @objc func didSelectDate(_ datePicker: UIDatePicker) {
        if dateAfterFilter.textField.inputView == datePicker {
            dateAfterFilter.textField.text = formatDate(datePicker.date)
            selectedDateAfter = dateAfterFilter.textField.text ?? ""
        } else if dateBeforeFilter.textField.inputView == datePicker {
            dateBeforeFilter.textField.text = formatDate(datePicker.date)
            selectedDateBefore = dateBeforeFilter.textField.text ?? ""
        }
    }
    
    @objc func didTapSubmitBtn() {
        let model = formatModel()
        selectedFilter
            .onNext(model)
        dismiss(animated: true)
    }
    
    @objc func didTapClearBtn() {
        didDismissed
            .onNext(())
        dismiss(animated: true)
    }
    
    @objc func doneButtonTapped() {
        view.endEditing(true)
    }
}

extension DigWorkFilterBottomSheet: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        filterTypePickerView.reloadAllComponents()
        filterTypePickerView.selectRow(0, inComponent: 0, animated: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
            return zones[row].rawValue
        } else if typeOfWorkFilter.textField.isFirstResponder {
            return typeOfWork[row].rawValue
        } else if statusFilter.textField.isFirstResponder {
            return status[row].rawValue
        }
        return nil
    }

}

extension DigWorkFilterBottomSheet: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if zoneFilter.textField.isFirstResponder {
            zoneFilter.textField.text = zones[row].rawValue
            selectedZone = zones[row]
        } else if typeOfWorkFilter.textField.isFirstResponder {
            typeOfWorkFilter.textField.text = typeOfWork[row].rawValue
            selectedTypeOfWork = typeOfWork[row]
        } else if statusFilter.textField.isFirstResponder {
            statusFilter.textField.text = status[row].rawValue
            selectedStatus = status[row]
        }
    }
    
}
