//
//  PaddingTextField.swift
//  currency_converter
//
//  Created by YURY LVOV on 2019/05/27.
//  Copyright © 2019 YURY LVOV. All rights reserved.
//

import UIKit

class PaddingTextField: UITextField {
    
    @IBInspectable var paddingLeft: CGFloat = 0
    @IBInspectable var paddingRight: CGFloat = 0
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + paddingLeft, y: bounds.origin.y,
                      width: bounds.size.width - paddingLeft - paddingRight, height: bounds.size.height);
    }
    
    private var originalRect = CGRect.zero
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        originalRect = super.clearButtonRect(forBounds: bounds)
        clearButtonMode = .whileEditing
        textAlignment = .right
    }
    
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        return originalRect.offsetBy(dx: -originalRect.origin.x + 5, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let bounds = CGRect(x: originalRect.size.width, y: bounds.origin.y, width: bounds.size.width-originalRect.size.width, height: bounds.size.height)
        return bounds.insetBy(dx: 13, dy: 3)
    }
}
