//
//  ImageGalleryViewController.swift
//  Image Search
//
//  Created by Daniel Husiuk on 08.10.2026.
//

import UIKit
import Photos

final class ImageGalleryViewController: UIPageViewController {
    
    private let imageLoader: ImageLoaderProtocol
    private let shareButton = ShareButton(style: .systemUltraThinMaterialDark)
    private let downloadButton = DownloadButton()
    
    private let images: [ImageModel]
    private let startIndex: Int
    
    private var currentImage: ImageModel? {
        guard let page = viewControllers?.first as? ImagePageViewController,
              images.indices.contains(page.index) else { return nil }
        return images[page.index]
    }
    
    init(images: [ImageModel], startIndex: Int, loader: ImageLoaderProtocol) {
        self.imageLoader = loader
        self.images = images
        self.startIndex = startIndex
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: [.interPageSpacing: 16]
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        dataSource = self
        
        if let firstPage = makePage(at: startIndex) {
            setViewControllers([firstPage], direction: .forward, animated: false)
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
        } else {
            setupShareButton()
            setupDownloadButton()
        }
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
        return ImagePageViewController(index: index, imageModel: images[index], loader: imageLoader)
    }
    
    @objc private func downloadButtonTapped(_ sender: Any) {
        guard
            let image = currentImage,
            let url = URL(string: image.largeImageURL)
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
    
    private func saveImage(_ image: UIImage) {
        
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        } completionHandler: { [weak self] success, error in
            
            DispatchQueue.main.async {
                guard let self else { return }
                
                if success {
                    self.showAlert(
                        title: "Saved",
                        message: "The image was saved to your photo library.",
                        actionTitle: "Ok"
                    )
                } else {
                    self.showAlert(
                        title: "Save Failed",
                        message: error?.localizedDescription ?? "Could not save the image.",
                        actionTitle: "Ok"
                    )
                }
            }
        }
    }
    
    @objc private func shareButtonTapped(_ sender: Any) {
        guard
            let image = currentImage,
            let url = URL(string: image.webformatURL)
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
