//
//  GradientView.swift
//  Image Search
//
//  Created by Daniel Husiuk on 06.10.2026.
//

import UIKit

final class GradientView: UIView {
    
    override static var layerClass: AnyClass { CAGradientLayer.self }
    private var gradientLayer: CAGradientLayer? { layer as? CAGradientLayer }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        
        gradientLayer?.colors = [
            UIColor.customPurple.cgColor,
            UIColor.customDarkPurple.cgColor
        ]
        gradientLayer?.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer?.endPoint = CGPoint(x: 0.5, y: 1)
    }
}
