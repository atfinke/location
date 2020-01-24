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
    private var isOpen = false
    
    // MARK: - View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 64, weight: .medium)
        view.addSubview(label)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateLabel()
        label.frame = view.bounds
    }
    
    // MARK: - Sign of Life -
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        updateLabel()
        UIView.animate(withDuration: 2.0, animations: {
            self.view.backgroundColor = UIColor(displayP3Red: .random(in: 0..<1),
                                                green: .random(in: 0..<1),
                                                blue: .random(in: 0..<1),
                                                alpha: 1.0)
        })
    }
    
    private func updateLabel() {
        let queueCountKey = "queueCount"
        let totalCountKey = "totalCount"
        let queueCount = UserDefaults.standard.integer(forKey: queueCountKey)
        let totalCount = UserDefaults.standard.integer(forKey: totalCountKey)
        label.text = "\(queueCount)/\(totalCount)"
    }

}

