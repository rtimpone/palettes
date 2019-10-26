//
//  ListViewController.swift
//  Palettes
//
//  Created by Rob Timpone on 10/26/19.
//  Copyright © 2019 Rob Timpone. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var palettes: [Palette] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load palettes from database
    }
    
    @IBAction func addAction(_ sender: Any) {
        showCreatePaletteScreen()
    }
}

private extension ListViewController {
    
    func showCreatePaletteScreen() {
        let vc = CreatePaletteViewController.instantiateFromStoryboard()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return palettes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let palette = palettes[indexPath.row]
        let cell = tableView.dequeueReusableCell(ofType: ListCell.self)
        cell.configure(for: palette)
        return cell
    }
}

extension ListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let palette = palettes[indexPath.row]
        let vc = PaletteViewController.newInstance(for: palette)
        navigationController?.pushViewController(vc, animated: true)
    }
}
