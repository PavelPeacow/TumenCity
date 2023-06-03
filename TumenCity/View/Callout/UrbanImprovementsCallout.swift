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
        
        let fullscreenImageView = FullscreenViewController()
        fullscreenImageView.url = "https://info.agt72.ru" + imageURL.url
        present(fullscreenImageView, animated: true)
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


class FullscreenViewController: UIViewController, UIScrollViewDelegate {
    var url: String!
    
    private var scrollView: UIScrollView!
    private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        view.addSubview(scrollView)
        
        imageView = UIImageView(frame: scrollView.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.sd_setImage(with: URL(string: url))
        scrollView.addSubview(imageView)
        
        view.backgroundColor = .systemBackground.withAlphaComponent(0.95)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreen))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissFullscreen() {
        dismiss(animated: true, completion: nil)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            if let image = imageView.image {
                let ratioW = imageView.frame.width / image.size.width
                let ratioH = imageView.frame.height / image.size.height
                
                let ratio = ratioW < ratioH ? ratioW : ratioH
                let newWidth = image.size.width * ratio
                let newHeight = image.size.height * ratio
                let conditionLeft = newWidth*scrollView.zoomScale > imageView.frame.width
                let left = 0.5 * (conditionLeft ? newWidth - imageView.frame.width : (scrollView.frame.width - scrollView.contentSize.width))
                let conditioTop = newHeight*scrollView.zoomScale > imageView.frame.height
                
                let top = 0.5 * (conditioTop ? newHeight - imageView.frame.height : (scrollView.frame.height - scrollView.contentSize.height))
                
                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
                
            }
        } else {
            scrollView.contentInset = .zero
        }
    }
}
