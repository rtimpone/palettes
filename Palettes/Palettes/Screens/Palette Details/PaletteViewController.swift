//
//  PaletteViewController.swift
//  Palettes
//
//  Created by Rob Timpone on 10/26/19.
//  Copyright © 2019 Rob Timpone. All rights reserved.
//

import UIKit

class PaletteViewController: UIViewController {
    
    var palette: Palette!
    
    static func newInstance(for palette: Palette) -> PaletteViewController {
        let vc = PaletteViewController.instantiateFromStoryboard()
        vc.palette = palette
        vc.title = palette.name
        return vc
    }
}
