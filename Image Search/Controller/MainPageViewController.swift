//
//  MainPageViewController.swift
//  Image Search
//
//  Created by Daniel Husiuk on 05.10.2026.
//

import UIKit

final class MainPageViewController: UIViewController {
    
    private let backgroundImage = BackgroundImage(frame: .zero)
    private let mainStackView = MainStackView()
    private let secondaryStackView = SecondaryStackView()
    
    private let titleLabel = CustomTitleLabel()
    private let textField = CustomTextField()
    private let searchButton = CustomButton()
    private let bottomLabel = CustomBottomLabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.setupShadows()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    private func setupLayout() {
        setupBackgroundImage()
        setupStackViews()
        setupBottomLabel()
    }
    
    private func setupShadows() {
        textField.applyShadow(opacity: 0.6, radius: 10)
        searchButton.applyShadow(opacity: 0.6, radius: 10)
    }
    
    // MARK: - Layout Setup
    
    private func setupBackgroundImage() {
        view.addSubview(backgroundImage)
        
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupStackViews() {
        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(secondaryStackView)
        
        textField.delegate = self
        secondaryStackView.addArrangedSubview(textField)
        secondaryStackView.addArrangedSubview(searchButton)
        searchButton.addTarget(self, action: #selector(searchButtonTouchUp), for: .touchUpInside)
        
        let centerYConstraint = mainStackView.centerYAnchor.constraint(
            equalTo: view.centerYAnchor,
            constant: -40
        )
        centerYConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20
            ),
            mainStackView.trailingAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20
            ),
            mainStackView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            centerYConstraint,
            mainStackView.widthAnchor.constraint(
                lessThanOrEqualToConstant: 600
            ),
            mainStackView.bottomAnchor.constraint(
                lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor,
                constant: -16
            ),
            
            textField.heightAnchor.constraint(
                equalToConstant: 54
            ),
            searchButton.heightAnchor.constraint(
                equalToConstant: 54
            )
        ])
    }
    
    private func setupBottomLabel() {
        view.addSubview(bottomLabel)
        
        NSLayoutConstraint.activate([
            bottomLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func searchButtonTouchUp() {
        switch SearchManager.validate(textField.text ?? "") {
        case .success(let searchString):
            let searchPageViewController = SearchPageViewController()
            searchPageViewController.searchString = searchString
            searchPageViewController.onTextChanged = { [weak self] text in
                self?.textField.text = text
            }
            navigationController?.pushViewController(searchPageViewController, animated: true)
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
}

// MARK: - Extensions

extension MainPageViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchButtonTouchUp()
        return true
    }
}
