//
//  BlurBackgroundView.swift
//  Image Search
//
//  Created by Daniel Husiuk on 07.10.2026.
//

import UIKit

final class BlurBackgroundView: UIView {
    
    private let blurEffectView: UIVisualEffectView
    
    init(style: UIBlurEffect.Style = .systemUltraThinMaterial) {
        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: style))
        super.init(frame: .zero)
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        super.init(coder: coder)
        setupStyle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        layer.masksToBounds = true
    }
    
    private func setupStyle() {
        backgroundColor = .clear
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
    }
    
}
