//
//  ViewController.swift
//  ExampleImageViewer
//
//  Created by Tewodros Mengesha on 05/03/2018.
//  Copyright © 2018 Finwe Ltd. All rights reserved.
//

/**
 * This is an example of Orion1 image viewer.
 *
 * Features:
 * - Plays one hardcoded 360x180 equirectangular image
 * - Image can be from URL or local repository
 * - Sensor fusion (acc+mag+gyro+touch)
 * - Panning (gyro, swipe)
 * - Zooming (pinch)
 * - Fullscreen view locked to landscape
 */

import UIKit

class ViewController: UIViewController, Orion1ViewDelegate
{
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Create an instance of Orion1View and initialize it as follows
        let orionView = Orion1View(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
        orionView.delegate = self
        
        view.addSubview(orionView)
        
        //Add license URL
        let path: String? = Bundle.main.path(forResource: "Orion360_SDK_Basic_iOS_Trial_finwe.ExampleImageViewer.lic", ofType: nil)
        let licenseUrl = URL(fileURLWithPath: path ?? "")
        
        // Image can be given from URL or local repository
        
        //Image URL
        let photoUrl = URL(string: "https://s3.amazonaws.com/orion360-us/Orion360_example_image_1_4096x2048.jpg")
        
        /* It is possible to display Photo from local repository
         //let photoUrl = UIImage(named: "Orion360_test_image_3840x1920.jpg")
         */
        
        // Set Image and license url
        orionView.initImage(with: photoUrl, licenseFileUrl: licenseUrl)
        
    }
    
}
