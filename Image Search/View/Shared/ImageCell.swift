//
//  ImageCell.swift
//  Image Search
//
//  Created by Daniel Husiuk on 06.10.2026.
//

import UIKit
import Photos

final class ImageCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    private let shareButton = CustomBlurButton(style: .systemUltraThinMaterialDark, imageName: "square.and.arrow.up")
    
    private var imageURL: String?
    private var imageTask: URLSessionDataTask?
    
    private var assetIdentifier: String?
    private var assetRequestID: PHImageRequestID?
    private static let assetTargetSize = CGSize(width: 400, height: 400)
    
    static let reuseIdentifier = "ImageCell"
    var onShare: ((UIView) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
        setupImageView()
        setupShareButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupContentView()
        setupImageView()
        setupShareButton()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        imageURL = nil
        
        cancelLocalAssetRequest()
        assetIdentifier = nil
        imageView.image = nil
        shareButton.isHidden = false
        onShare = nil
    }
    
    func configureRemote(imageURL: String, loader: ImageLoaderProtocol) {
        cancelImageRequests()
        shareButton.isHidden = false
        self.imageURL = imageURL
        imageView.image = nil
        
        imageTask = loader.loadImage(from: imageURL) { [weak self] image in
            guard let self, self.imageURL == imageURL else { return }
            self.imageView.image = image
        }
    }
    
    func configureLocal(asset: PHAsset) {
        cancelImageRequests()
        shareButton.isHidden = true
        assetIdentifier = asset.localIdentifier
        imageView.image = nil
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        
        assetRequestID = PHImageManager.default().requestImage(
            for: asset,
            targetSize: ImageCell.assetTargetSize,
            contentMode: .aspectFill,
            options: options
        ) { [weak self] image, _ in
            guard let self, self.assetIdentifier == asset.localIdentifier else { return }
            self.imageView.image = image
        }
    }
    
    // MARK: - Setup
    
    private func setupContentView() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.cornerCurve = .continuous
        contentView.clipsToBounds = true
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func setupShareButton() {
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        contentView.addSubview(shareButton)
        
        NSLayoutConstraint.activate([
            shareButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            shareButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            shareButton.widthAnchor.constraint(equalToConstant: 34),
            shareButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    @objc private func shareButtonTapped() {
        onShare?(shareButton)
    }
    
    private func cancelLocalAssetRequest() {
        if let requestID = assetRequestID {
            PHImageManager.default().cancelImageRequest(requestID)
        }
        assetRequestID = nil
    }
    
    private func cancelImageRequests() {
        imageTask?.cancel()
        imageTask = nil
        cancelLocalAssetRequest()
    }
}
