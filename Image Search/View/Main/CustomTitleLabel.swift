//
//  CustomTitleLabel.swift
//  Image Search
//
//  Created by Daniel Husiuk on 05.10.2026.
//

import UIKit

final class CustomTitleLabel: UILabel {
    
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
        textAlignment = .center
        lineBreakMode = .byWordWrapping
        numberOfLines = 3
        backgroundColor = .clear
        textColor = .white
        font = .systemFont(ofSize: 34, weight: .bold)
        text = "Zabierz swoich odbiorców na wizualna przygode"
    }
}
