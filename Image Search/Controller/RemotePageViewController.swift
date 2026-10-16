//
//  RemotePageViewController.swift
//  Image Search
//
//  Created by Daniel Husiuk on 06.10.2026.
//

import UIKit

final class RemotePageViewController: UIViewController {
    
    private let textField = CustomTextField()
    private let searchButton = CustomButton(style: .icon)
    
    private let imageLoader: ImageLoaderProtocol
    private let collectionView: ImageCollectionView
    private let imageService: ImageServiceProtocol = ImageService(apiManager: ApiManager())
    
    var onTextChanged: ((String) -> Void)?
    var searchString: String = "" {
        didSet {
            textField.text = searchString
        }
    }
    
    init(imageLoader: ImageLoaderProtocol) {
        self.imageLoader = imageLoader
        self.collectionView = ImageCollectionView(loader: imageLoader)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupTextField()
        setupSearchButton()
        loadImages()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.setupShadows()
        }
    }
    
    // MARK: - Setup
    
    private func setupShadows() {
        if #available(iOS 26.0, *) {
            textField.applyShadow(opacity: 0.1, radius: 10)
        }
    }
    
    private func setupCollectionView() {
        collectionView.onShare = { [weak self] imageURL, sourceView in
            self?.shareImage(urlString: imageURL, sender: sourceView)
        }
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
    
    private func setupTextField() {
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        
        navigationItem.titleView = textField
        let widthConstraint = textField.widthAnchor.constraint(equalToConstant: 300)
        widthConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            widthConstraint,
            textField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupSearchButton() {
        if #available(iOS 26.0, *) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "magnifyingglass"),
                style: .prominent,
                target: self,
                action: #selector(searchButtonTouchUp)
            )
        } else {
            searchButton.addTarget(self, action: #selector(searchButtonTouchUp), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchButton)
            NSLayoutConstraint.activate([
                searchButton.widthAnchor.constraint(equalToConstant: 44),
                searchButton.heightAnchor.constraint(equalToConstant: 44)
            ])
        }
    }
    
    // MARK: - Actions
    
    @objc private func textFieldEditingChanged() {
        onTextChanged?(textField.text ?? "")
    }
    
    private func loadImages() {
        imageService.searchImages(searchText: searchString) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let response):
                self.collectionView.items = response.hits.map { .remote($0) }
                self.collectionView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @objc private func searchButtonTouchUp() {
        switch SearchValidator.validate(textField.text ?? "") {
        case .success(let searchString):
            self.searchString = searchString
            loadImages()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .empty:
            return
        case .invalid:
            showAlert(
                title: "Search Error",
                message: "Your search text must be in English and no longer than 100 characters",
                actionTitle: "Ok"
            )
        }
    }
    
    private func shareImage(urlString: String, sender: Any) {
        guard let url = URL(string: urlString) else { return }
        
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
    
    private func showGallery(startingAt index: Int) {
        view.endEditing(true)
        let gallery = ImageGalleryViewController(images: collectionView.items, startIndex: index, loader: imageLoader)
        navigationController?.pushViewController(gallery, animated: true)
    }
}

// MARK: - Extensions

extension RemotePageViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchButtonTouchUp()
        return true
    }
}
