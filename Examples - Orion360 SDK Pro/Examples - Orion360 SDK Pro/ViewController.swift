//
//  ViewController.swift
//  Examples - Orion360 SDK Pro
//
//  Created by Tewodros Mengesha on 15/03/2018.
//  Copyright © 2018 Finwe Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
      
    var selectedSpeedValue: Float = 1.0
    @IBOutlet weak var orionSlider: UISlider!
    
    @IBOutlet weak var tableView: UITableView!
    

    
    let listOfFeatures = ["Preview Image","Minimal video player", "Minimal video downloaded player", "Advanced video player", "Animation: Cross Fade", "VR mode: 2D", "VR mode: 2D Portrait", "Projection: Little Planet", "Projection: Source Projection", "Hotspot"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNavBarImage()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func addNavBarImage()
    {
        let navController = navigationController!
        let image = #imageLiteral(resourceName: "orionTitle")
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit

        let bannerWidth = navController.navigationBar.frame.size.width
        let bannerHeight = navController.navigationBar.frame.size.height
        
        let bannerX = bannerWidth / 2 - image.size.width / 2
        let bannerY = bannerHeight / 2 - image.size.height / 2
        
        imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
        imageView.contentMode = .scaleAspectFit
        
        navigationItem.titleView = imageView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfFeatures.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell")
        cell?.textLabel?.text = listOfFeatures[indexPath.row]
        cell?.textLabel?.font = UIFont.init(name: "Helvetica", size: 20)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         performSegue(withIdentifier: "showDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? OrionViewController
        {
            destination.selectedFeature = listOfFeatures[(tableView.indexPathForSelectedRow?.row)!]
            destination.sSpeed = selectedSpeedValue
        }
    }

}

