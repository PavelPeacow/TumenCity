//
//  CityCleaningIndicatorsViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 12.07.2023.
//

import UIKit
import RxSwift

fileprivate enum Section: CaseIterable {
    case city
    case ddit
    case vao
    case kao
    case lao
    case cao
}

fileprivate enum Item: Hashable {
    case item(it: CityCleaningIndicatorItem)
    case subitem(it: Detal)
}

struct CityCleaningIndicatorItem: Hashable {
    static func == (lhs: CityCleaningIndicatorItem, rhs: CityCleaningIndicatorItem) -> Bool {
        lhs.activeDuringDay == rhs.activeDuringDay
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id = UUID()
    let idCouncil: Int?
    let council: String
    let timelinessData, activeDuringDay, countContractor, sumMorning: Int
    let sumNight: Int
    let detal: [Detal]?
    let timelinessDataCount: Int?
}

class CityCleaningIndicatorsViewController: UIViewController {
    
    private let viewModel = CityCleaningIndicatorsViewModel()
    private let bag = DisposeBag()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    lazy var indicatorsCollectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout.list(using: .init(appearance: .plain))
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(IndicatorCollectionViewListCell.self, forCellWithReuseIdentifier: IndicatorCollectionViewListCell.identifier)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(indicatorsCollectionView)
        
        indicatorsCollectionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.bottom.equalToSuperview()
        }
        
        loadIndicators()
    }
    
    private func loadIndicators() {
        viewModel
            .getIndicators()
            .subscribe(onNext: { [unowned self] in
                makeDatasource()
                configureSnapshot()
            })
            .disposed(by: bag)
    }
    
    private func didSelectItemCellDetail(model: CityCleaningIndicatorItem) {
        let callout = CityCleaningIndicatorCallout()
        callout.configureItem(model: model)
        callout.showAlert(in: self.parent ?? self)
    }
    
    private func didSelectSubitemCellDetail(model: Detal) {
        let callout = CityCleaningIndicatorCallout()
        callout.configureSubitem(model: model)
        callout.showAlert(in: self.parent ?? self)
    }
}

extension CityCleaningIndicatorsViewController {
    
    private func makeDatasource() {
        let itemCell = UICollectionView.CellRegistration<IndicatorCollectionViewListCell, CityCleaningIndicatorItem> { cell, indexPath, model in
            cell.configureCell(title: model.council,
                               textStyle: .preferredFont(forTextStyle: .headline),
                               cellIndex: indexPath.row, isSubitem: false,
                               detailAction: UIAction() { [weak self] _ in
                self?.didSelectItemCellDetail(model: model)
            })
        }
        
        let subitemCell = UICollectionView.CellRegistration<IndicatorCollectionViewListCell, Detal> { cell, indexPath, model in
            cell.configureCell(title: model.contractor,
                               textStyle: .preferredFont(forTextStyle: .subheadline),
                               cellIndex: indexPath.row, isSubitem: true,
                               detailAction: UIAction() { [weak self] _ in
                self?.didSelectSubitemCellDetail(model: model)
            })
        }
        
        dataSource = .init(collectionView: indicatorsCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
                
            case .item(let it):
                return collectionView.dequeueConfiguredReusableCell(using: itemCell, for: indexPath, item: it)
            case .subitem(let it):
                return collectionView.dequeueConfiguredReusableCell(using: subitemCell, for: indexPath, item: it)
            }
        })
    }
    
    private func addItemsToSnapshot(item: CityCleaningIndicatorItem,
                                    subitems: [Detal]?,
                                    to snapshot: inout NSDiffableDataSourceSectionSnapshot<Item>) {
        snapshot.append([.item(it: item)])
        subitems?.forEach { subitem in
            snapshot.append([.subitem(it: subitem)], to: .item(it: item))
        }
    }
    
    private func configureSnapshot() {
        var snapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        
        Section.allCases.enumerated().forEach { (index, section) in
            let item = viewModel.getIndicatorItemByIndex(index)
            
            switch section {
                
            case .city:
                snapshot.append([.item(it: item)])
            case .ddit, .vao, .kao, .lao, .cao:
                addItemsToSnapshot(item: item, subitems: item.detal, to: &snapshot)
            }
        }

        dataSource.apply(snapshot, to: .city)
    }
    
}

extension CityCleaningIndicatorsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item {
            
        case .item:
            break
        case .subitem(it: let it):
            didSelectSubitemCellDetail(model: it)
        }
        
    }
}

#Preview {
    CityCleaningIndicatorsViewController()
}
