//
//  IndicatorView.swift
//  Image Search
//
//  Created by Daniel Husiuk on 05.10.2026.
//

import UIKit

final class IndicatorView: UIActivityIndicatorView {
    
    override init(style: UIActivityIndicatorView.Style) {
        super.init(style: style)
        setupStyle()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupStyle()
    }
    
    private func setupStyle() {
        hidesWhenStopped = true
        isUserInteractionEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
    }
}
