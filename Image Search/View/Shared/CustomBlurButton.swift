//
//  CustomBlurButton.swift
//  Image Search
//
//  Created by Daniel Husiuk on 06.10.2026.
//

import UIKit

final class CustomBlurButton: UIButton {
    
    private let blurStyle: UIBlurEffect.Style
    private let imageName: String
    
    init(style: UIBlurEffect.Style = .systemUltraThinMaterial, imageName: String = "") {
        self.blurStyle = style
        self.imageName = imageName
        super.init(frame: .zero)
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        self.blurStyle = .systemUltraThinMaterial
        self.imageName = ""
        super.init(coder: coder)
        setupStyle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                self.alpha = self.isHighlighted ? 0.8 : 1.0
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            })
        }
    }
    
    private func setupStyle() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        tintAdjustmentMode = .normal
        
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(
            systemName: imageName,
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 14,
                weight: .semibold
            )
        )
        
        configuration.baseForegroundColor = .customPurple
        configuration.background.customView = BlurBackgroundView(style: blurStyle)
        configuration.contentInsets = .zero
        self.configuration = configuration
    }
}
