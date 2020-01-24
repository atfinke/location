//
//  ViewController.swift
//  location
//
//  Created by Andrew Finke on 1/24/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animate()
    }
    
    // MARK: - Sign of Life -
    
    func animate() {
        UIView.animate(withDuration: 2.0, animations: {
            self.view.backgroundColor = UIColor(displayP3Red: .random(in: 0..<1),
                                                green: .random(in: 0..<1),
                                                blue: .random(in: 0..<1),
                                                alpha: 1.0)
        }, completion: { _ in
            self.animate()
        })
    }

}

