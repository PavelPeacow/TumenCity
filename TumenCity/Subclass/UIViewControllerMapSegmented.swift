//
//  UIViewControllerMapSegmented.swift
//  TumenCity
//
//  Created by Павел Кай on 08.05.2023.
//

import UIKit
import Combine
import RxSwift

class UIViewControllerMapSegmented: UIViewController {
    private var mainMapView: UIView
    private var registryView: UIView
    private var registrySearchResult: UITableViewController
    
    private var cancellables = Set<AnyCancellable>()
    private var isRegistrySearchEnabled = false
    
    var didEnterText = PassthroughSubject<String, Never>()
    var segmentedIndex: Int {
        segmentControl.selectedSegmentIndex
    }
    
    var didSelectSuggestion: ((String) -> Void)?
    
    var bag = DisposeBag()
    
    private lazy var searchTextfield: SearchTextField = {
        SearchTextField()
    }()
    
    private lazy var suggestionTableView: SuggestionTableView = {
        SuggestionTableView()
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 300, width: view.bounds.width, height: view.bounds.height))
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.alwaysBounceVertical = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = false
        return scrollView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var segmentControl: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()

    init(mainMapView: UIView, registryView: UIView, registrySearchResult: UITableViewController) {
        self.mainMapView = mainMapView
        self.registryView = registryView
        self.registrySearchResult = registrySearchResult
        
        super.init(nibName: nil, bundle: nil)
        
        stackView.addArrangedSubview(mainMapView)
        stackView.addArrangedSubview(registryView)
        
        view.addSubview(searchTextfield)
        view.addSubview(segmentControl)
        view.addSubview(suggestionTableView)
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        setUpSearchController()
//        registerKeyboardNotification()
        addTarget()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func changeToMapSearch() {
        searchTextfield.resetTextfieldState()
        registrySearchResult.view.isHidden = true
        isRegistrySearchEnabled = false
        
        registrySearchResult.removeFromParent()
        registrySearchResult.view.removeFromSuperview()
    }
    
    private func changeToRegistrySearch() {
        searchTextfield.resetTextfieldState()
        isRegistrySearchEnabled = true
        
        self.addChild(registrySearchResult)
        registrySearchResult.view.frame = view.frame
        view.addSubview(registrySearchResult.view)
        registrySearchResult.didMove(toParent: self)
        
        registrySearchResult.view.snp.makeConstraints {
            $0.top.equalTo(searchTextfield.snp.bottom).offset(5)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
        
    private func setUpSearchController() {
        searchTextfield
            .didClearTextPublisher
            .sink { [weak self] in
                self?.registrySearchResult.view.isHidden = true
                self?.suggestionTableView.hideTableSuggestions()
                print("cleearr")
            }
            .store(in: &cancellables)

        searchTextfield
            .textPublisher
            .sink { [weak self] text in
                print("text entered")
                
                guard text.count > 0 else {
                    self?.registrySearchResult.view.isHidden = true
                    self?.suggestionTableView.hideTableSuggestions()
                    return
                }
                
                if self?.isRegistrySearchEnabled == true {
                    self?.registrySearchResult.view.isHidden = false
                    self?.suggestionTableView.hideTableSuggestions()
                } else {
                    self?.registrySearchResult.view.isHidden = true
                    self?.suggestionTableView.showTableSuggestions()
                    self?.suggestionTableView.search(text: text)
                }
                self?.didEnterText.send(text)
            }
            .store(in: &cancellables)
        
        suggestionTableView
            .selectedSuggestionObservable
            .subscribe(onNext: { [unowned self] text in
                searchTextfield.resetTextfieldState()
                didSelectSuggestion?(text)
            })
            .disposed(by: bag)
    }
    
    private func animateAppearingRegistrySearch() {
        self.registrySearchResult.view.isHidden = false
        self.registrySearchResult.view.alpha = 0.0
        
        UIView.animate(withDuration: 0.3) {
            self.registrySearchResult.view.alpha = 1.0
        }
    }
    
    private func animateDissapearingRegistrySearch() {
        UIView.animate(withDuration: 0.3) {
            self.registrySearchResult.view.alpha = 0.0
        } completion: { _ in
            self.registrySearchResult.view.isHidden = true
        }
    }
    
    private func addTarget() {
        segmentControl.addTarget(self, action: #selector(didSlideSegmentedControl(_:)), for: .valueChanged)
    }
        
    final func addItemsToSegmentControll(_ items: [String]) {
        items.forEach {
            segmentControl.insertSegment(withTitle: $0, at: items.firstIndex(of: $0) ?? 0, animated: false)
        }
        segmentControl.selectedSegmentIndex = 0
    }
    
    func resetSegmentedControlAfterRegistryView() {
        segmentControl.selectedSegmentIndex = 0
        segmentControl.sendActions(for: .valueChanged)
    }
    
    func configureSuggestions(_ suggestions: [String]) {
        suggestionTableView.configure(suggestions: suggestions)
    }
}

private extension UIViewControllerMapSegmented {
    @objc func didSlideSegmentedControl(_ sender: UISegmentedControl) {
        navigationItem.searchController = nil
        let index = sender.selectedSegmentIndex
        print(index)
        switch index {
            
        case 0:
            scrollView.scrollRectToVisible(mainMapView.frame, animated: true)
            changeToMapSearch()
        case 1:
            scrollView.scrollRectToVisible(registryView.frame, animated: true)
            changeToRegistrySearch()
        default:
            return
        }
    }
}

private extension UIViewControllerMapSegmented {
    func setConstraints() {
        mainMapView.translatesAutoresizingMaskIntoConstraints = false
        registryView.translatesAutoresizingMaskIntoConstraints = false
        registrySearchResult.view.translatesAutoresizingMaskIntoConstraints = false
        
        searchTextfield.setupTextfieldLayoutIn(view: view)
        
        suggestionTableView.setupSuggestionTableViewInView(view, topConstraint: {
            $0.top.equalTo(searchTextfield.snp.bottom)
        })
        
        segmentControl.snp.makeConstraints {
            $0.height.equalTo(25)
            $0.width.equalToSuperview().multipliedBy(0.95)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(searchTextfield.snp.bottom).offset(5)
        }
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        mainMapView.snp.makeConstraints {
            $0.size.equalTo(scrollView)
        }
        
        registryView.snp.makeConstraints {
            $0.size.equalTo(scrollView)
        }
        
        scrollView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(segmentControl.snp.bottom).offset(5)
            $0.bottom.equalToSuperview()
        }
    }
}

//MARK: - NotificationCenter
#warning("Old code, but can use for future")
//extension UIViewControllerMapSegmented {
//    
//    private func registerKeyboardNotification() {
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//    
//    @objc func keyboardWillShow(notification: NSNotification) {
//        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
//            return
//        }
//        
//        let keyboardHeight = keyboardSize.height
//        
//        UIView.animate(withDuration: 0.25) { [weak self] in
//            self?.mainMapView.frame.origin.y -= keyboardHeight
//        }
//    }
//    
//    @objc func keyboardWillHide(notification: NSNotification) {
//        UIView.animate(withDuration: 0.25) { [weak self] in
//            self?.mainMapView.frame.origin.y = 0
//        }
//    }
//    
//}
