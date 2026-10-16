//
//  ImageGalleryViewController.swift
//  Image Search
//
//  Created by Daniel Husiuk on 08.10.2026.
//

import UIKit
import Photos
import TOCropViewController

final class ImageGalleryViewController: UIPageViewController {
    
    private let imageLoader: ImageLoaderProtocol
    private let editButton = CustomBlurButton(style: .systemUltraThinMaterialDark, imageName: "slider.horizontal.3")
    private let shareButton = CustomBlurButton(style: .systemUltraThinMaterialDark, imageName: "square.and.arrow.up")
    private let downloadButton = DownloadButton()
    
    private var images: [ImageItem]
    private let startIndex: Int
    private var fetchResult: PHFetchResult<PHAsset>?
    
    private var currentImage: (item: ImageItem, image: UIImage)? {
        guard let page = viewControllers?.first as? ImagePageViewController,
              images.indices.contains(page.index),
              let image = page.currentImage
        else {
            return nil
        }
        return (item: images[page.index], image: image)
    }
    
    private var isLocalMode: Bool {
        guard let firstItem = images.first else { return false }
        if case .local = firstItem {
            return true
        }
        return false
    }
    
    init(images: [ImageItem], startIndex: Int, loader: ImageLoaderProtocol) {
        self.imageLoader = loader
        self.images = images
        self.startIndex = startIndex
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: [.interPageSpacing: 16]
        )
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        dataSource = self
        
        if let firstPage = makePage(at: startIndex) {
            setViewControllers(
                [firstPage],
                direction: .forward,
                animated: false
            )
        }
        if isLocalMode {
            PHPhotoLibrary.shared().register(self)
            fetchLocalAssets()
        }
        setupToolbarButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 26.0, *) {
            navigationController?.setToolbarHidden(false, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if #available(iOS 26.0, *) {
            navigationController?.setToolbarHidden(true, animated: false)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.setupShadows()
        }
    }
    
    // MARK: - Setup
    
    private func setupShadows() {
        if #unavailable(iOS 26.0) {
            shareButton.applyShadow(opacity: 0.4, radius: 10)
            downloadButton.applyShadow(opacity: 0.4, radius: 10)
        }
    }
    
    private func setupToolbarButtons() {
        if #available(iOS 26.0, *) {
            if isLocalMode {
                self.navigationItem.rightBarButtonItems = [
                    UIBarButtonItem(
                        image: UIImage(systemName: "slider.horizontal.3"),
                        style: .plain,
                        target: self,
                        action: #selector(editButtonTapped)
                    )
                ]
            } else {
                self.toolbarItems = [
                    UIBarButtonItem(
                        image: UIImage(systemName: "square.and.arrow.up"),
                        style: .plain,
                        target: self,
                        action: #selector(shareButtonTapped)
                    ),
                    UIBarButtonItem.flexibleSpace(),
                    UIBarButtonItem(
                        image: UIImage(systemName: "arrow.down"),
                        style: .prominent,
                        target: self,
                        action: #selector(downloadButtonTapped)
                    )
                ]
            }
        } else {
            if isLocalMode {
                setupEditButton()
            } else {
                setupShareButton()
                setupDownloadButton()
            }
        }
    }
    
    private func setupEditButton() {
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
        view.addSubview(editButton)
        
        NSLayoutConstraint.activate([
            editButton.heightAnchor.constraint(equalToConstant: 44),
            editButton.widthAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupShareButton() {
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        view.addSubview(shareButton)
        
        NSLayoutConstraint.activate([
            shareButton.heightAnchor.constraint(equalToConstant: 44),
            shareButton.widthAnchor.constraint(equalToConstant: 44),
            shareButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupDownloadButton() {
        downloadButton.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
        view.addSubview(downloadButton)
        
        NSLayoutConstraint.activate([
            downloadButton.heightAnchor.constraint(equalToConstant: 44),
            downloadButton.widthAnchor.constraint(equalToConstant: 44),
            downloadButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            downloadButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    private func makePage(at index: Int) -> ImagePageViewController? {
        guard images.indices.contains(index) else { return nil }
        
        switch images[index] {
        case .remote(let imageModel):
            return ImagePageViewController(index: index, imageModel: imageModel, loader: imageLoader)
        case .local(let asset):
            return ImagePageViewController(index: index, asset: asset)
        }
    }
    
    private func fetchLocalAssets() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        guard status == .authorized || status == .limited else {
            images.removeAll()
            dataSource = nil
            setViewControllers(
    [],
    direction: .forward,
    animated: false
            )
            return
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
    }
    
    private func updateLocalAssets(with result: PHFetchResult<PHAsset>) {
        guard isLocalMode else { return }
        let currentAsset: PHAsset? = {
            guard let page = viewControllers?.first as? ImagePageViewController,
                  images.indices.contains(page.index),
                  case .local(let asset) = images[page.index] else {
                return nil
            }
            return asset
        }()
        
        var updatedImages = [ImageItem]()
        updatedImages.reserveCapacity(result.count)
        result.enumerateObjects { asset, _, _ in
            updatedImages.append(.local(asset))
        }
        
        images = updatedImages
        guard !images.isEmpty else {
            setViewControllers(
    [],
    direction: .forward,
    animated: false
            )
            return
        }
        
        let newIndex: Int
        if let currentAsset,
           let matchingIndex = updatedImages.firstIndex(where: { item in
               guard case .local(let asset) = item else { return false }
               return asset.localIdentifier == currentAsset.localIdentifier
           }) {
            newIndex = matchingIndex
        } else {
            newIndex = min(startIndex, images.count - 1)
        }
        
        if let newPage = makePage(at: newIndex) {
            setViewControllers(
                [newPage],
                direction: .forward,
                animated: false
            )
        }
    }
    
    @objc private func editButtonTapped(_ sender: Any) {
        guard let currentImage else { return }
        guard case .local = currentImage.item else { return }
        
        let cropViewController = TOCropViewController(image: currentImage.image)
        cropViewController.delegate = self
        present(cropViewController, animated: true)
    }
    
    @objc private func shareButtonTapped(_ sender: Any) {
        guard
            let currentImage,
            case .remote(let imageModel) = currentImage.item,
            let url = URL(string: imageModel.webformatURL)
        else { return }
        
        let activityViewController = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        if let barButtonItem = sender as? UIBarButtonItem {
            activityViewController.popoverPresentationController?.barButtonItem = barButtonItem
        } else if let sourceView = sender as? UIView {
            activityViewController.popoverPresentationController?.sourceView = sourceView
            activityViewController.popoverPresentationController?.sourceRect = sourceView.bounds
        }
        present(activityViewController, animated: true)
    }
    
    @objc private func downloadButtonTapped(_ sender: Any) {
        guard
            let currentImage,
            case .remote(let imageModel) = currentImage.item,
            let url = URL(string: imageModel.largeImageURL)
        else { return }
        
        imageLoader.loadImage(from: url.absoluteString) { [weak self] downloadedImage in
            guard let self else { return }
            
            guard let downloadedImage else {
                self.showAlert(
                    title: "Download Failed",
                    message: "Could not download the image.",
                    actionTitle: "Ok"
                )
                return
            }
            self.saveImage(downloadedImage)
        }
    }
    
    private func updateOriginalImage(with image: UIImage) {
        guard let currentImage,
              case .local(let asset) = currentImage.item else { return }
        
        asset.requestContentEditingInput(with: nil) { [weak self] input, _ in
            guard let self,
                  let input else {
                return
            }
            
            let output = PHContentEditingOutput(contentEditingInput: input)
            guard let data = image.jpegData(compressionQuality: 1) else {
                return
            }
            
            do {
                try data.write(to: output.renderedContentURL)
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(
                        title: "Save failed",
                        message: error.localizedDescription,
                        actionTitle: "Ok"
                    )
                }
                return
            }
            
            output.adjustmentData = PHAdjustmentData(
                formatIdentifier: "com.danielhusiuk.ImageSearch",
                formatVersion: "1.0",
                data: Data("cropped".utf8)
            )
            
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetChangeRequest(for: asset)
                request.contentEditingOutput = output
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    if !success {
                        self.showAlert(
                            title: "Save failed",
                            message: error?.localizedDescription ?? "Unexpected error",
                            actionTitle: "Ok"
                        )
                    }
                }
            }
            
        }
    }
    
    private func saveImage(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        } completionHandler: { [weak self] success, error in
            
            DispatchQueue.main.async {
                guard let self else { return }
                
                if !success {
                    self.showAlert(
                        title: "Save Failed",
                        message: error?.localizedDescription ?? "Could not save the image.",
                        actionTitle: "Ok"
                    )
                }
            }
        }
    }
    
}

// MARK: - Extensions

extension ImageGalleryViewController: UIPageViewControllerDataSource {
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let page = viewController as? ImagePageViewController else { return nil }
        return makePage(at: page.index - 1)
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let page = viewController as? ImagePageViewController else { return nil }
        return makePage(at: page.index + 1)
    }
    
}

extension ImageGalleryViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let currentResult = fetchResult,
              let details = changeInstance.changeDetails(for: currentResult) else {
            return
        }
        let updatedResult = details.fetchResultAfterChanges
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.fetchResult = updatedResult
            self.updateLocalAssets(with: updatedResult)
        }
    }
}

extension ImageGalleryViewController: TOCropViewControllerDelegate {
    
    func cropViewController(
        _ cropViewController: TOCropViewController,
        didCropTo image: UIImage,
        with cropRect: CGRect,
        angle: Int
    ) {
        cropViewController.dismiss(animated: true) { [weak self] in
            self?.updateOriginalImage(with: image)
        }
    }
    
    func cropViewController(
        _ cropViewController: TOCropViewController,
        didFinishCancelled cancelled: Bool
    ) {
        cropViewController.dismiss(animated: true)
    }
}
