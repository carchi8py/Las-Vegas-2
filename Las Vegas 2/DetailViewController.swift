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
    var photoOne: UIImage!
    var photoTwo: UIImage!
    var photoThree: UIImage!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var imageThree: UIImageView!
    
    override func viewDidLoad() {
        titleLabel.text = name
        imageOne.image = photoOne
        imageTwo.image = photoTwo
        imageThree.image = photoThree
    }
    
}