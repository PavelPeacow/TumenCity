//
//  UIViewControllerMapSegmented.swift
//  TumenCity
//
//  Created by Павел Кай on 08.05.2023.
//

import UIKit

class UIViewControllerMapSegmented: UIViewController {
        
    private var mainMapView: UIView
    private var registryView: UIView
    private var registrySearchResult: UITableViewController
    
    var segmentedIndex: Int {
        segmentControl.selectedSegmentIndex
    }
    
    private lazy var searchController: UISearchController = {
        let search = UISearchController()
        search.searchResultsUpdater = self
        search.hidesNavigationBarDuringPresentation = false
        return search
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
        
        view.addSubview(segmentControl)
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        setUpSearchController()
        registerKeyboardNotification()
        addTarget()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func changeSearchController(withSearchResultsController: Bool = false) {
        let search = UISearchController(searchResultsController: withSearchResultsController ? registrySearchResult : nil)
        search.searchResultsUpdater = self
        search.hidesNavigationBarDuringPresentation = false
        searchController = search
        setUpSearchController()
    }
    
    private func setUpSearchController() {
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Введите адрес..."
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
    
}

extension UIViewControllerMapSegmented: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) { }
}

private extension UIViewControllerMapSegmented {
    
    @objc func didSlideSegmentedControl(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        print(index)
        switch index {
            
        case 0:
            scrollView.scrollRectToVisible(mainMapView.frame, animated: true)
            changeSearchController()
        case 1:
            scrollView.scrollRectToVisible(registryView.frame, animated: true)
            changeSearchController(withSearchResultsController: true)
        default:
            return
        }
    }
    
}

private extension UIViewControllerMapSegmented {
    
    func setConstraints() {
        mainMapView.translatesAutoresizingMaskIntoConstraints = false
        registryView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            segmentControl.heightAnchor.constraint(equalToConstant: 25),
            segmentControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            segmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            mainMapView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            mainMapView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            registryView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            registryView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            scrollView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 5),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.safeAreaInsets.bottom + 10),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
        ])
    }
    
}

//MARK: - NotificationCenter

extension UIViewControllerMapSegmented {
    
    private func registerKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let keyboardHeight = keyboardSize.height
        
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.mainMapView.frame.origin.y -= keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.mainMapView.frame.origin.y = 0
        }
    }
    
}
