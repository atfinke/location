//
//  ViewController.swift
//  location
//
//  Created by Andrew Finke on 1/24/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Properties -
    
    private let label = UILabel()
    
    // MARK: - View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 88, weight: .medium)
        view.addSubview(label)
        
        animate()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        label.frame = view.bounds
    }
    
    // MARK: - Sign of Life -
    
    func animate() {
        UIView.animate(withDuration: 2.0, animations: {
            self.view.backgroundColor = UIColor(displayP3Red: .random(in: 0..<1),
                                                green: .random(in: 0..<1),
                                                blue: .random(in: 0..<1),
                                                alpha: 1.0)
        }, completion: { _ in
            self.label.text = (UserDefaults.standard.array(forKey: "Locations") ?? []).count.description
            self.animate()
        })
    }

}

