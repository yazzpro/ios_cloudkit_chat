//
//  ProfileImageController.swift
//  CloudKit_Chat
//
//  Created by Jarosław Pawlak on 17.03.2017.
//  Copyright © 2017 Jarosław Pawlak. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class ProfileImageController: UIViewController
{
    var image: UIImage?
    @IBOutlet weak var imageView: UIImageView!
    func setImage(image: UIImage?)
    {
        self.image = image
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.imageView.image = self.image
    }
}
