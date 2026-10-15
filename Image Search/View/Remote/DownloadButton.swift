//
//  DownloadButton.swift
//  Image Search
//
//  Created by Daniel Husiuk on 09.10.2026.
//

import UIKit

final class DownloadButton: UIButton {
    
    private let gradientView = GradientView(
        firstColor: UIColor.customPurple.cgColor,
        secondColor: UIColor.customDarkPurple.cgColor
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStyle()
        setupGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let cornerRadius = bounds.height / 2
        gradientView.layer.cornerRadius = cornerRadius
        layer.cornerRadius = cornerRadius
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
                self.alpha = self.isHighlighted ? 0.8 : 1.0
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            }
        }
    }
    
    private func setupStyle() {
        backgroundColor = .clear
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(
            systemName: "arrow.down",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 14,
                weight: .semibold
            )
        )
        configuration.baseForegroundColor = .white
        configuration.contentInsets = .zero
        self.configuration = configuration
    }
    
    private func setupGradient() {
        insertSubview(gradientView, at: 0)
        
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
