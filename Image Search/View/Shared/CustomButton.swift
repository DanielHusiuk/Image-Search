//
//  CustomButton.swift
//  Image Search
//
//  Created by Daniel Husiuk on 06.10.2026.
//

import UIKit

enum Style {
    case search
    case icon
    case local
}

final class CustomButton: UIButton {
    
    private let style: Style
    private let gradientView: GradientView
    
    init(style: Style) {
        self.style = style
        self.gradientView = Self.makeGradient(for: style)
        super.init(frame: .zero)
        setupStyle()
        setupGradient()
    }
    
    override init(frame: CGRect) {
        self.style = .search
        self.gradientView = Self.makeGradient(for: style)
        super.init(frame: frame)
        setupStyle()
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        self.style = .search
        self.gradientView = Self.makeGradient(for: style)
        super.init(coder: coder)
        setupStyle()
        setupGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let cornerRadiusValue = bounds.height / 2
        gradientView.layer.cornerRadius = cornerRadiusValue
        layer.cornerRadius = cornerRadiusValue
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                self.alpha = self.isHighlighted ? 0.8 : 1.0
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            })
        }
    }
    
    private static func makeGradient(for style: Style) -> GradientView {
        switch style {
        case .search, .icon:
            return GradientView(
                firstColor: UIColor.customPurple.cgColor,
                secondColor: UIColor.customDarkPurple.cgColor
            )
        case .local:
            return GradientView(
                firstColor: UIColor.gray.cgColor,
                secondColor: UIColor.darkGray.cgColor
            )
        }
    }
    
    private func setupStyle() {
        backgroundColor = .clear
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = .white
        
        switch style {
        case .search:
            configuration.image = UIImage(
                systemName: "magnifyingglass",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 14,
                    weight: .semibold
                )
            )
            configuration.imagePadding = 8
            configuration.title = "Search"
            configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
                var attributes = attributes
                attributes.font = .systemFont(ofSize: 20, weight: .semibold)
                return attributes
            }
            
        case .icon:
            configuration.image = UIImage(
                systemName: "magnifyingglass",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 14,
                    weight: .semibold
                )
            )
            configuration.contentInsets = .zero
            
        case .local:
            configuration.image = UIImage(
                systemName: "photo",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 14,
                    weight: .semibold
                )
            )
            configuration.imagePadding = 8
            configuration.title = "Local gallery"
            configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
                var attributes = attributes
                attributes.font = .systemFont(ofSize: 20, weight: .semibold)
                return attributes
            }
        }
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
