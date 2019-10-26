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
    
    @IBOutlet weak var primaryView: UIView!
    @IBOutlet weak var secondaryView: UIView!
    @IBOutlet weak var tertiaryView: UIView!
    @IBOutlet weak var quaternaryView: UIView!
    
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var tertiaryLabel: UILabel!
    @IBOutlet weak var quaternaryLabel: UILabel!
    
    static func newInstance(for palette: Palette) -> PaletteViewController {
        let vc = PaletteViewController.instantiateFromStoryboard()
        vc.palette = palette
        vc.title = palette.name
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewColors()
        setLabelText()
        setLabelTextColors()
    }
    
    @IBAction func primaryTapped(_ sender: Any) {
        toggleLabelVisibility(primaryLabel)
    }
    
    @IBAction func secondaryTapped(_ sender: Any) {
        toggleLabelVisibility(secondaryLabel)
    }
    
    @IBAction func tertiaryTapped(_ sender: Any) {
        toggleLabelVisibility(tertiaryLabel)
    }
    
    @IBAction func quaternaryTapped(_ sender: Any) {
        toggleLabelVisibility(quaternaryLabel)
    }
}

private extension PaletteViewController {
    
    func setViewColors() {
        primaryView.backgroundColor = palette.primaryColor
        secondaryView.backgroundColor = palette.secondaryColor
        tertiaryView.backgroundColor = palette.tertiaryColor
        quaternaryView.backgroundColor = palette.quaternaryColor
    }
    
    func setLabelText() {
        primaryLabel.text = "#" + palette.primaryColorString.uppercased()
        secondaryLabel.text = "#" + palette.secondaryColorString.uppercased()
        tertiaryLabel.text = "#" + palette.tertiaryColorString.uppercased()
        quaternaryLabel.text = "#" + palette.quaternaryColorString.uppercased()
    }
    
    func setLabelTextColors() {
        primaryLabel.textColor = BrightnessAnalyzer.colorIsLight(palette.primaryColor) ? .darkGray : .white
        secondaryLabel.textColor = BrightnessAnalyzer.colorIsLight(palette.secondaryColor) ? .darkGray : .white
        tertiaryLabel.textColor = BrightnessAnalyzer.colorIsLight(palette.tertiaryColor) ? .darkGray : .white
        quaternaryLabel.textColor = BrightnessAnalyzer.colorIsLight(palette.quaternaryColor) ? .darkGray : .white
    }
    
    func toggleLabelVisibility(_ label: UILabel) {
        let newAlpha: CGFloat = label.alpha == 0 ? 1 : 0
        Animator.animate(view: view, duration: 1, changes: { label.alpha = newAlpha })
    }
}
