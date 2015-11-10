//
//  DetailViewController.swift
//  Las Vegas 2
//
//  Created by Chris Archibald on 11/9/15.
//  Copyright © 2015 Chris Archibald. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
    
    var name: String!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        titleLabel.text = name
    }
    
}