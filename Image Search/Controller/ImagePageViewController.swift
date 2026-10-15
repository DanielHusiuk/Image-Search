//
//  ImagePageViewController.swift
//  Image Search
//
//  Created by Daniel Husiuk on 06.10.2026.
//

import UIKit

final class ImagePageViewController: UIViewController {
    
    let index: Int
    private let imageModel: ImageModel
    private let loader: ImageLoaderProtocol
    
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private let activityIndicator = IndicatorView(style: .large)
    
    private var largeImageTask: URLSessionDataTask?
    private var laidOutSize: CGSize = .zero
    private let fitZoomScale: CGFloat = 1
    
    init(index: Int, imageModel: ImageModel, loader: ImageLoaderProtocol) {
        self.index = index
        self.imageModel = imageModel
        self.loader = loader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init has not been implemented")
    }
    
    deinit {
        largeImageTask?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupScrollView()
        setupActivityIndicator()
        loadImages()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard scrollView.bounds.size != laidOutSize else { return }
        laidOutSize = scrollView.bounds.size
        layoutImage()
    }
    
    // MARK: - Setup
    
    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 10
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Loading
    
    private func loadImages() {
        activityIndicator.startAnimating()
        
        _ = loader.loadImage(from: imageModel.webformatURL) { [weak self] image in
            guard let self, let image, self.imageView.image == nil else { return }
            self.display(image)
        }
        
        largeImageTask = loader.loadImage(from: imageModel.largeImageURL) { [weak self] image in
            guard let self else { return }
            self.activityIndicator.stopAnimating()
            guard let image else { return }
            self.display(image)
        }
    }
    
    private func display(_ image: UIImage) {
        let isFirstImage = imageView.image == nil
        imageView.image = image
        activityIndicator.stopAnimating()
        if isFirstImage {
            layoutImage()
        }
    }
    
    // MARK: - Layout and Zoom
    
    private func layoutImage() {
        guard let image = imageView.image,
              image.size.width > 0, image.size.height > 0 else { return }
        
        let boundsSize = scrollView.bounds.size
        guard boundsSize.width > 0, boundsSize.height > 0 else { return }
        
        let scale = min(boundsSize.width / image.size.width, boundsSize.height / image.size.height)
        let fittedSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        
        scrollView.zoomScale = 1
        imageView.frame = CGRect(origin: .zero, size: fittedSize)
        scrollView.contentSize = fittedSize
        centerContent()
        scrollView.contentOffset = CGPoint(x: -scrollView.contentInset.left, y: -scrollView.contentInset.top)
    }
    
    private func centerContent() {
        let horizontalInset = max(0, (scrollView.bounds.width - scrollView.contentSize.width) / 2)
        let verticalInset = max(0, (scrollView.bounds.height - scrollView.contentSize.height) / 2)
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset, left: horizontalInset,
            bottom: verticalInset, right: horizontalInset
        )
    }
    
    // MARK: - Actions
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > fitZoomScale {
            scrollView.setZoomScale(fitZoomScale, animated: true)
        } else {
            let point = gesture.location(in: imageView)
            let targetScale: CGFloat = 3
            let size = CGSize(
                width: scrollView.bounds.width / targetScale,
                height: scrollView.bounds.height / targetScale
            )
            let origin = CGPoint(x: point.x - size.width / 2, y: point.y - size.height / 2)
            scrollView.zoom(to: CGRect(origin: origin, size: size), animated: true)
        }
    }
}

// MARK: - Extensions

extension ImagePageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerContent()
    }
}
