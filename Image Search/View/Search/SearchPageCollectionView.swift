//
//  SearchPageCollectionView.swift
//  Image Search
//
//  Created by Daniel Husiuk on 06.10.2026.
//

import UIKit

final class SearchPageCollectionView: UICollectionView {
    
    var model = [ImageModel]()
    var onShare: ((String, UIView) -> Void)?
    var onSelect: ((Int) -> Void)?
    
    init() {
        super.init(frame: .zero, collectionViewLayout: SearchPageCollectionView.makeLayout())
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero, collectionViewLayout: SearchPageCollectionView.makeLayout())
        setupCollectionView()
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

extension SearchPageCollectionView: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: true)
        onSelect?(indexPath.item)
    }
}

extension SearchPageCollectionView: UICollectionViewDataSource {
    
    func numberOfSections(
        in collectionView: UICollectionView
    ) -> Int {
        1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        model.count
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
        
        let imageModel = model[indexPath.item]
        cell.configure(imageURL: imageModel.webformatURL, loader: ImageLoader.shared)
        
        cell.onShare = { [weak self, weak cell] sourceView in
            guard let self, let cell, let indexPath = self.indexPath(for: cell) else { return }
            let imageURL = self.model[indexPath.item].webformatURL
            self.onShare?(imageURL, sourceView)
        }
        return cell
    }
}
