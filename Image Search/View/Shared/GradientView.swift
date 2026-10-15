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
    
    init(firstColor: CGColor, secondColor: CGColor) {
        super.init(frame: .zero)
        setup(firstColor: firstColor, secondColor: secondColor)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
    }
    
    private func setup(firstColor: CGColor, secondColor: CGColor) {
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        
        gradientLayer?.colors = [ firstColor, secondColor ]
        gradientLayer?.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer?.endPoint = CGPoint(x: 0.5, y: 1)
    }
}
