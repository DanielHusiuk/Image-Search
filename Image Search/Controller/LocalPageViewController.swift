//
//  LocalPageViewController.swift
//  Image Search
//
//  Created by Daniel Husiuk on 14.10.2026.
//

import UIKit
import Photos

final class LocalPageViewController: UIViewController {

    private let imageLoader: ImageLoaderProtocol
    private let collectionView: ImageCollectionView
    
    private var fetchResult: PHFetchResult<PHAsset>?
    private var hasPhotoAccess = false
    
    init(imageLoader: ImageLoaderProtocol) {
        self.imageLoader = imageLoader
        self.collectionView = ImageCollectionView(loader: imageLoader)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        loadImages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkPhotoAuthorization()
    }
    
    // MARK: - Setup
    
    private func setupCollectionView() {
        collectionView.onSelect = { [weak self] index in
            self?.showGallery(startingAt: index)
        }
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    private func checkPhotoAuthorization() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            self.hasPhotoAccess = true
            self.fetchAssets()
            
        case .notDetermined:
            loadImages()
            
        default:
            hasPhotoAccess = false
            updateImages(with: [])
        }
    }
    
    private func loadImages() {
        PHPhotoLibrary.shared().register(self)
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch status {
                case .authorized, .limited:
                    self.hasPhotoAccess = true
                    self.fetchAssets()
                    
                case .restricted, .denied:
                    self.hasPhotoAccess = false
                    self.updateImages(with: [])
                    self.showAlert(
                        title: "Photo Access Required",
                        message: "Allow access to your photos in Settings to view your local gallery.",
                        actionTitle: "Ok"
                    )
                case .notDetermined:
                    break
                    
                default:
                    self.hasPhotoAccess = false
                    self.updateImages(with: [])
                }
                
            }
        }
    }
    
    private func fetchAssets() {
        guard hasPhotoAccess else { return }
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        fetchResult = assets
        
        var items = [ImageItem]()
        items.reserveCapacity(assets.count)
        assets.enumerateObjects { asset, _, _ in
            items.append(.local(asset))
        }
        updateImages(with: items)
    }
    
    private func updateImages(with items: [ImageItem]) {
        collectionView.items = items
        collectionView.reloadData()
    }
    
    private func showGallery(startingAt index: Int) {
        view.endEditing(true)
        let gallery = ImageGalleryViewController(
            images: collectionView.items,
            startIndex: index,
            loader: imageLoader
        )
        navigationController?.pushViewController(gallery, animated: true)
    }
}

// MARK: - Extensions

extension LocalPageViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let currentResult = fetchResult,
              let details = changeInstance.changeDetails(for: currentResult) else {
            return
        }
        
        let updatedResult = details.fetchResultAfterChanges
        var items = [ImageItem]()
        items.reserveCapacity(updatedResult.count)
        updatedResult.enumerateObjects { asset, _, _ in
            items.append(.local(asset))
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.fetchResult = updatedResult
            self.updateImages(with: items)
        }
    }
}
