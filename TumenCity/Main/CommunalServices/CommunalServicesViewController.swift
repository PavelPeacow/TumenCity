//
//  ViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 15.02.2023.
//

import UIKit
import MapKit
import YandexMapsMobile

final class CommunalServicesViewController: UIViewController {
    
    lazy var mainMapView = CommunalServicesView()
    lazy var registyView = RegistryView()
    lazy var registrySearchResult = RegistySearchResultViewController()
    
    let viewModel = CommunalServicesViewModel()
    var timer: Timer?
    
    var didTapSearchBar = false
    
    lazy var searchController: UISearchController = {
        let search = UISearchController()
        search.searchResultsUpdater = self
        search.searchBar.delegate = self
        return search
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 300, width: view.bounds.width, height: view.bounds.height))
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.alwaysBounceVertical = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.isScrollEnabled = false
        return scrollView
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [mainMapView, registyView])
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var segmentControl: UISegmentedControl = {
        let items = ["Карта", "Реестр"]
        let segment = UISegmentedControl(items: items)
        segment.selectedSegmentIndex = 0
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()
    
    lazy var segmentLine: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 1))
        view.backgroundColor = .red
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainMapView.map.setDefaultRegion()
        view.addSubview(segmentControl)
        segmentControl.addSubview(segmentLine)
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        view.backgroundColor = .systemBackground
        
        title = "Отключение ЖКУ"
        
        registerKeyboardNotification()
        setUpSearchController()
        addTarget()
        setDelegates()
        setConstraints()
    }
    
    private func setDelegates() {
//        mainMapView.map.delegate = self
        viewModel.delegate = self
        registyView.delegate = self
        registrySearchResult.delegate = self
    }
    
    private func setUpSearchController() {
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Введите адрес..."
        didTapSearchBar = false
    }
    
    private func addTarget() {
        segmentControl.addTarget(self, action: #selector(didSlideSegmentedControl(_:)), for: .valueChanged)
    }
    
    private func addServicesInfo() {
        guard let communalServices = viewModel.communalServices else { return }
        
        for serviceInfo in communalServices.info {
            let icon = UIImage(named: "filter-\(serviceInfo.id)") ?? .add
            let title = serviceInfo.title
            let count = String(serviceInfo.count)
            
            let serviceInfoView = ServiceInfoView(icon: icon, title: title, count: count, serviceType: serviceInfo.id)
            serviceInfoView.delegate = self
            
            mainMapView.servicesInfoStackView.addArrangedSubview(serviceInfoView)
        }
    }
    
    private func didTapSearch() {
        didTapSearchBar.toggle()
        if didTapSearchBar {
            scrollView.isScrollEnabled = false
        } else {
            scrollView.isScrollEnabled = true
        }
    }
    
    private func changeSearchController(withSearchResultsController: Bool = false) {
        let search = UISearchController(searchResultsController: withSearchResultsController ? registrySearchResult : nil)
        search.searchResultsUpdater = self
        search.searchBar.delegate = self
        searchController = search
        setUpSearchController()
    }
    
    private func showSelectedMark(_ mark: MarkDescription) {
        viewModel.resetFilterCommunalServices()
        mainMapView.servicesInfoStackView.arrangedSubviews.forEach { ($0 as? ServiceInfoView)?.isTapAlready = false }
        
        segmentControl.selectedSegmentIndex = 0
        segmentControl.sendActions(for: .valueChanged)
        
//        if let annotation = viewModel.annotations.first(where: { $0.markDescription.address == mark.address } ) {
//            mainMapView.map.showAnnotations([annotation], animated: false)
//            mainMapView.map.selectAnnotation(annotation, animated: true)
//        }
    }
    
}

//MARK: - NotificationCenter

extension CommunalServicesViewController {
    
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

//MARK: - Objc Functions

extension CommunalServicesViewController {
    
    @objc func didSlideSegmentedControl(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        print(index)
        switch index {
            
        case 0:
            scrollView.scrollRectToVisible(mainMapView.frame, animated: true)
            changeSearchController()
        case 1:
            scrollView.scrollRectToVisible(registyView.frame, animated: true)
            changeSearchController(withSearchResultsController: true)
        default:
            return
        }
    }
    
}

//MARK: - UIScrollViewDelegate

extension CommunalServicesViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        segmentLine.frame = CGRect(x: scrollView.contentOffset.x / 2, y: 0, width: 100, height: 1)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        let pageFraction = scrollView.contentOffset.x/pageWidth
        
        if segmentControl.selectedSegmentIndex == Int((round(pageFraction))) {
            return
        } else {
            segmentControl.selectedSegmentIndex = Int((round(pageFraction)))
            segmentControl.sendActions(for: .valueChanged)
        }
    }
    
}

//MARK: - RegistryViewDelegate

extension CommunalServicesViewController: RegistryViewDelegate {
    
    func didGetAddress(_ mark: MarkDescription) {
        showSelectedMark(mark)
    }
    
}

extension CommunalServicesViewController: RegistySearchResultViewControllerDelegate {
    
    func didTapResultAddress(_ mark: MarkDescription) {
        showSelectedMark(mark)
    }
    
}

//MARK: - Search

extension CommunalServicesViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        timer?.invalidate()
        
//        guard let searchText = searchController.searchBar.text else { return mainMapView.map.setDefaultRegion() }
//        guard !searchText.isEmpty else { return mainMapView.map.setDefaultRegion()}
        
        if segmentControl.selectedSegmentIndex == 1 {
//            registrySearchResult.filterSearch(with: searchText)
            return
        }
        
//        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
//            if let annotation = self?.viewModel.findAnnotationByAddressName(searchText) {
//                self?.mainMapView.map.showAnnotations([annotation], animated: false)
//                self?.mainMapView.map.deselectAnnotation(annotation, animated: false)
//                self?.mainMapView.map.selectAnnotation(annotation, animated: true)
//            } else {
//                self?.mainMapView.map.setDefaultRegion()
//            }
//        })
        
        
    }
    
}

extension CommunalServicesViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        didTapSearch()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        didTapSearch()
    }
    
}

//MARK: - ServiceInfoViewDelegate

extension CommunalServicesViewController: ServiceInfoViewDelegate {
    
    func didTapServiceInfoView(_ serviceType: Int, _ view: ServiceInfoView) {
        guard !view.isTapAlready else {
            mainMapView.servicesInfoStackView.arrangedSubviews.forEach { ($0 as? ServiceInfoView)?.isTapAlready = false }
            viewModel.resetFilterCommunalServices()
            return
        }
        
        mainMapView.servicesInfoStackView.arrangedSubviews.forEach { ($0 as? ServiceInfoView)?.isTapAlready = false }
//        viewModel.filterCommunalServices(with: serviceType)
        view.isTapAlready = true
    }
    
}

//MARK: - ViewModelDelegate

extension CommunalServicesViewController: CommunalServicesViewModelDelegate {
    
    func didUpdateAnnotations(_ annotations: [MKItemAnnotation]) {
//        let allAnnotations = mainMapView.map.annotations
//        mainMapView.map.removeAnnotations(allAnnotations)
//
//        mainMapView.map.addAnnotations(annotations)
//        mainMapView.map.fitAllAnnotations()
    }
    
    func didFinishAddingAnnotations(_ annotations: [MKItemAnnotation]) {
//        mainMapView.map.addAnnotations(annotations)
        let collection = mainMapView.map.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
        mainMapView.map.mapWindow.map.mapObjects.addTapListener(with: self)
        mainMapView.map.addAnnotations(annotations, cluster: collection)
       
//        addServicesInfo()
//        registyView.cards = viewModel.communalServicesFormatted
//        registyView.tableView.reloadData()
//        
//        registrySearchResult.configure(communalServicesFormatted: viewModel.communalServicesFormatted)
    }
    
}

//MARK: - MapDelegate

extension CommunalServicesViewController: MKMapViewDelegate, YMKClusterListener {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
            
        case is MKItemAnnotation:
            //fix flickiring, but decrease performance!
            return MKItemAnnotationView(annotation: annotation, reuseIdentifier: MKItemAnnotationView.identifier)
            
        case is MKClusterAnnotation:
            return ClusterAnnotationView(annotation: annotation, reuseIdentifier: ClusterAnnotationView.identifier)
            
        default:
            return nil
        }
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        let sight = view.annotation as! MKItemAnnotation
        print(sight)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let cluster = view.annotation as? MKClusterAnnotation {
            
            let annotations = cluster.memberAnnotations
            annotations.forEach { print($0.coordinate) }
            
        } else if let annotation = view.annotation as? MKItemAnnotation {
            print(annotation.markDescription.address)
        }
    }
    
    func onClusterAdded(with cluster: YMKCluster) {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKItemAnnotation }
        
        cluster.appearance.setPieChart(clusterAnnotations: annotations)
    }

}

extension CommunalServicesViewController: YMKMapObjectTapListener {
    
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let annotation = mapObject.userData as? MKItemAnnotation else { return false }
        print(mapObject.userData)
        let callout = CalloutService()
        callout.configure(annotation: annotation)
        callout.showAlert(in: self)
        return true
    }
    
}

//MARK: - Constraints

extension CommunalServicesViewController {
    
    func setConstraints() {
        mainMapView.translatesAutoresizingMaskIntoConstraints = false
        registyView.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            registyView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            registyView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            scrollView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 5),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.safeAreaInsets.bottom + 10),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
        ])
    }
    
}
