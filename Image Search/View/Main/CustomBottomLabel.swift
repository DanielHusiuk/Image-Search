//
//  CustomBottomLabel.swift
//  Image Search
//
//  Created by Daniel Husiuk on 06.10.2026.
//

import UIKit

final class CustomBottomLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStyle()
    }
    
    private func setupStyle() {
        translatesAutoresizingMaskIntoConstraints = false
        lineBreakMode = .byWordWrapping
        backgroundColor = .clear
        textColor = .white
        font = .systemFont(ofSize: 16, weight: .semibold)
        text = "© Photos from Pixabay"
    }
}
