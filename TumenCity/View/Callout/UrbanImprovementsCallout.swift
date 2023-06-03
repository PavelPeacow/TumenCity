//
//  UrbanImprovementsCallout.swift
//  TumenCity
//
//  Created by Павел Кай on 01.06.2023.
//

import UIKit

final class UrbanImprovementsCalloutCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "UrbanImprovementsCalloutCollectionViewCell"
    
    lazy var image: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(image)
        
        image.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImageByURLForCell(_ imageURL: String) {
        guard let url = URL(string: "https://info.agt72.ru" + imageURL) else { return }
        self.image.sd_setImage(with: url)
    }
    
}

final class UrbanImprovementsCallout: Callout {
    
    var imageURLs = [UrbanImprovementsImg]()
    
    lazy var stackViewContent: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [stackViewTitle])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var stackViewTitle: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [calloutIcon, calloutTitle])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    lazy var calloutIcon: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    lazy var calloutTitle: UILabel = {
        let label = UILabel()
        label.font = . systemFont(ofSize: 17, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var collectionViewTitle: UILabel = {
        let label = UILabel()
        label.font = . systemFont(ofSize: 17, weight: .bold)
        label.numberOfLines = 0
        label.text = "Фото: "
        return label
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = .init(width: 300, height: 150)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(UrbanImprovementsCalloutCollectionViewCell.self,
                                forCellWithReuseIdentifier: UrbanImprovementsCalloutCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.layer.cornerRadius = 8
        collectionView.layer.zPosition = 8
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertBackground.addSubview(stackViewContent)
        
        calloutTapGesture.delegate = self
        
        setConstaints()
    }
    
    func configure(urbanDetailInfo: UrbanImprovementsDetailInfo) {
        calloutIcon.image = UIImage(named: "blackIcon")
        calloutTitle.text = urbanDetailInfo.fields.title
        
        configureSportLabel(with: urbanDetailInfo.fields.stageWork?.value, description: "Стадия работ: ")
        configureSportLabel(with: urbanDetailInfo.fields.dateStart, description: "Период проведения работ: ")
        configureSportLabel(with: urbanDetailInfo.fields.vidWork, description: "Вид работ: ")
        
        if let imgURLs = urbanDetailInfo.fields.img {
            imageURLs = imgURLs
            stackViewContent.addArrangedSubview(collectionViewTitle)
            stackViewContent.addArrangedSubview(collectionView)
            
            collectionView.snp.makeConstraints {
                $0.height.equalTo(150)
            }
        }
        
    }
    
    private func configureSportLabel(with text: String?, description: String) {
        if let text = text {
            let label = CalloutLabelView(label: description + text)
            stackViewContent.addArrangedSubview(label)
        }
    }
    
}

extension UrbanImprovementsCallout: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchLocation = touch.location(in: collectionView)
        return !collectionView.bounds.contains(touchLocation)
    }
    
}

extension UrbanImprovementsCallout: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UrbanImprovementsCalloutCollectionViewCell.identifier,
                                                      for: indexPath) as! UrbanImprovementsCalloutCollectionViewCell
        
        cell.setImageByURLForCell(imageURLs[indexPath.item].url)
        
        return cell
    }
    
}

extension UrbanImprovementsCallout: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageURL = imageURLs[indexPath.item]
        print(imageURL)
    }
    
}

extension UrbanImprovementsCallout {
    
    func setConstaints() {
        alertBackground.snp.makeConstraints {
            $0.topMargin.greaterThanOrEqualToSuperview().inset(10)
            $0.bottomMargin.lessThanOrEqualToSuperview().inset(10)
            $0.width.equalToSuperview().inset(25)
            $0.center.equalToSuperview()
        }
        
        stackViewContent.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(15)
            $0.leading.trailing.equalToSuperview().inset(15)
        }
    }
    
}
