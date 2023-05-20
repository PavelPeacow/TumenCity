//
//  TradeObjectsViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 20.05.2023.
//

import UIKit
import YandexMapsMobile

class TradeObjectsTypeView: UIView {
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [tradeObjectIcon, countLabel])
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var tradeObjectIcon: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    lazy var countLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    init(icon: UIImage, count: String) {
        super.init(frame: .zero)
        
        tradeObjectIcon.image = icon
        countLabel.text = count
        
        backgroundColor = .systemGray6
        
        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TradeObjectsViewController: UIViewController {
    
    let viewModel = TradeObjectsViewModel()
    
    private lazy var collection = map.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    lazy var tradeObjectsFilterTypeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var map = YandexMapMaker.makeYandexMap()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(tradeObjectsFilterTypeStackView)
        view.addSubview(map)

        YandexMapMaker.setYandexMapLayout(map: map, in: view)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .init(named: "filterIcon"), style: .done, target: self, action: #selector(didTapFilterIcon))
    }
    

}

extension TradeObjectsViewController {
    
    @objc func didTapFilterIcon() {
        
    }
    
}

extension TradeObjectsViewController: TradeObjectsViewModelDelegate {
    
    func didFinishAddingAnnotations(_ tradeAnnotations: [MKTradeObjectAnnotation]) {
        map.addAnnotations(tradeAnnotations, cluster: collection)
        map.mapWindow.map.mapObjects.addTapListener(with: self)
    }
    
}

extension TradeObjectsViewController: YMKClusterListener {
    
    func onClusterAdded(with cluster: YMKCluster) {
        cluster.appearance.setStaticImage(inClusterItemsCount: cluster.size, color: .blue)
    }
    
}

extension TradeObjectsViewController: YMKMapObjectTapListener {
    
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let annotation = mapObject.userData as? MKTradeObjectAnnotation else { return false }
        
        Task {
            guard let tradeObject = await viewModel.getTradeObjectById(annotation.id) else { return }
            guard let item = tradeObject.row.first else { return }
            print(tradeObject.row.first)
            let modal = TradeObjectCallout()
            modal.configure(tradeObject: item, image: annotation.image ?? .add, type: annotation.type)
            modal.showAlert(in: self)
        }
        
        return true
    }
    
}
