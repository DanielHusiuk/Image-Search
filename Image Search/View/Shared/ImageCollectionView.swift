//
//  ImageCollectionView.swift
//  Image Search
//
//  Created by Daniel Husiuk on 06.10.2026.
//

import UIKit
import Photos

enum ImageItem {
    case remote(ImageModel)
    case local(PHAsset)
}

final class ImageCollectionView: UICollectionView {
    
    var items = [ImageItem]()
    var onShare: ((String, UIView) -> Void)?
    var onSelect: ((Int) -> Void)?
    private let imageLoader: ImageLoaderProtocol
    
    init(loader: ImageLoaderProtocol) {
        self.imageLoader = loader
        super.init(frame: .zero, collectionViewLayout: ImageCollectionView.makeLayout())
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { _, environment in
            let spacing: CGFloat = 16
            let minItemWidth: CGFloat = 160
            
            let availableWidth = environment.container.effectiveContentSize.width - spacing * 2
            let columns = max(2, Int((availableWidth + spacing) / (minItemWidth + spacing)))
            let itemWidth = (availableWidth - spacing * CGFloat(columns - 1)) / CGFloat(columns)
            
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
            )
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(itemWidth)
                ),
                subitem: item,
                count: columns
            )
            group.interItemSpacing = .fixed(spacing)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(
                top: spacing, leading: spacing, bottom: spacing, trailing: spacing
            )
            return section
        }
    }
    
    private func setupCollectionView() {
        delegate = self
        dataSource = self
        keyboardDismissMode = .interactive
        
        register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.reuseIdentifier)
        backgroundColor = .systemGroupedBackground
        translatesAutoresizingMaskIntoConstraints = false
    }
}

// MARK: - Extensions

extension ImageCollectionView: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: true)
        onSelect?(indexPath.item)
    }
}

extension ImageCollectionView: UICollectionViewDataSource {
    
    func numberOfSections(
        in collectionView: UICollectionView
    ) -> Int {
        1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        items.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageCell.reuseIdentifier,
            for: indexPath
        ) as? ImageCell else {
            return UICollectionViewCell()
        }
        
        switch items[indexPath.item] {
        case .remote(let imageModel):
            cell.configureRemote(imageURL: imageModel.webformatURL, loader: imageLoader)
            
            cell.onShare = { [weak self, weak cell] sourceView in
                guard let self,
                    let cell,
                      let indexPath = self.indexPath(for: cell),
                      case .remote(let imageModel) = self.items[indexPath.item] else {
                    return
                }
                self.onShare?(imageModel.webformatURL, sourceView)
            }
            
        case .local(let galleryImage):
            cell.configureLocal(asset: galleryImage)
            cell.onShare = nil
        }
        return cell
    }
}
