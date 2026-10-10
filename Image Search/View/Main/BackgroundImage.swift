//
//  BackgroundImage.swift
//  Image Search
//
//  Created by Daniel Husiuk on 06.10.2026.
//

import UIKit

final class BackgroundImage: UIImageView {
    
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
        contentMode = .scaleAspectFill
        backgroundColor = .clear
        image = UIImage(named: "backgroundImage")
        alpha = 0.6
    }
}
