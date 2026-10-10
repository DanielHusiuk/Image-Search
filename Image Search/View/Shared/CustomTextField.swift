//
//  CustomTextField.swift
//  Image Search
//
//  Created by Daniel Husiuk on 05.10.2026.
//

import UIKit

final class CustomTextField: UITextField {
    
    private let sizeConstant: CGFloat = 18
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStyle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
    
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.clearButtonRect(forBounds: bounds)
        rect.origin.x -= 10
        return rect
    }
    
    private func setupStyle() {
        autocapitalizationType = .none
        keyboardType = .default
        clearButtonMode = .whileEditing
        
        let leadingView = UIView(frame: CGRect(x: 0, y: 0, width: sizeConstant, height: bounds.height))
        leadingView.backgroundColor = .clear
        leftView = leadingView
        leftViewMode = .always
        
        backgroundColor = .customWhite
        translatesAutoresizingMaskIntoConstraints = false
        setupPlaceholder()
    }
    
    private func setupPlaceholder() {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(
            systemName: "magnifyingglass",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: sizeConstant,
                weight: .medium
            )
        )?.withTintColor(.systemGray2, renderingMode: .alwaysOriginal)
        
        let imageString = NSAttributedString(attachment: imageAttachment)
        let textString = NSAttributedString(
            string: "  Search images",
            attributes: [
                .font: UIFont.systemFont(ofSize: sizeConstant, weight: .medium),
                .foregroundColor: UIColor.systemGray2
            ]
        )
        
        let placeholder = NSMutableAttributedString()
        placeholder.append(imageString)
        placeholder.append(textString)
        
        attributedPlaceholder = placeholder
    }
    
}
