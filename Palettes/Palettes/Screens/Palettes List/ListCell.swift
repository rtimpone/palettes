//
//  ListCell.swift
//  Palettes
//
//  Created by Rob Timpone on 10/26/19.
//  Copyright © 2019 Rob Timpone. All rights reserved.
//

import UIKit

class ListCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var primaryView: UIView!
    @IBOutlet weak var secondaryView: UIView!
    @IBOutlet weak var tertiaryView: UIView!
    @IBOutlet weak var quaternaryView: UIView!
    
    func configure(for palette: Palette) {
        
        let layer = containerView.layer
        
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: -4, height: 4)
        layer.shadowRadius = 6
        
        primaryView.backgroundColor = palette.primaryColor
        secondaryView.backgroundColor = palette.secondaryColor
        tertiaryView.backgroundColor = palette.tertiaryColor
        quaternaryView.backgroundColor = palette.quaternaryColor
    }
}
