//
//  ViewController.swift
//  OrionPro_VideoPlayer
//
//  Created by Tewodros Mengesha on 14/03/2018.
//  Copyright © 2018 Finwe Ltd. All rights reserved.
//

/**
 * OrionPro_Player implements a minimal Orion video player. It plays
 * a video file from url using OrionView's default settings.
 *
 * Features:
 * - Plays one hardcoded 360x180 equirectangular video
 * - Auto-starts playback on load
 * - Stops after playback is finished
 * - Sensor fusion (acc+mag+gyro+touch)
 * - Panning (gyro, swipe)
 * - Zooming (pinch)
 * - Fullscreen view locked to landscape
 */

import UIKit
import Foundation

class ViewController: UIViewController, OrionViewDelegate, OrionVideoContentDelegate{
    
    var orionView: OrionView!
    var videoContent: OrionVideoContent!
    var viewPort: OrionViewport!
    
    
    var timerTest : Timer?
    var time = 0
    var alert:UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //view.backgroundColor = UIColor.clear
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    
        if orionView == nil {
            
            //Create an instance of OrionView
            orionView = OrionView()
            orionView.delegate = self
            orionView.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)
            
            // Check if license file exists
            let licenseFile = "Orion360_SDK_Pro_iOS_Trial_fi.finwe.OrionPro-VideoPlayer.lic"
            let path: String? = Bundle.main.path(forResource: licenseFile, ofType: nil)
            var isDir: ObjCBool = false
            let fileManager = FileManager.default
            
            if (path != nil && fileManager.fileExists(atPath: path!, isDirectory:&isDir))
            {
                let licenseUrl = URL(fileURLWithPath: path ?? "")
                //If license file found, assign it to orionView's licenceFileUrll
                orionView.licenseFileUrl = licenseUrl
            }
            else {
                print("No license file found.")
            }
            
            self.view.addSubview(orionView)
            orionView.overrideSilentSwitch = true
            orionView.alpha = 0.0
            
            //Create an instance of OrionVideoContent
            videoContent = OrionVideoContent()
            videoContent.delegate = self
    
            let videoUrl = URL(string: "http://playlisturltest.s3-website-eu-west-1.amazonaws.com/Maysaa-Compressed_Updated.m3u8")

            
            videoContent.uriArray = [videoUrl!]
            orionView.add(videoContent)
            
            viewPort = OrionViewport(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height), lockInPosition: false)
            viewPort.viewportConfig.fullScreenEnabled = true
            
            //viewPort.viewportConfig.vrMode = OrionVrMode(VR_MODE_2D_PORTRAIT)
            //viewPort.viewportConfig.vrMode = OrionVrMode(VR_MODE_2D)
            orionView.add(viewPort, orionContent: videoContent)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            orionView.addGestureRecognizer(tap)
            orionView.isUserInteractionEnabled = true
            
            orionView.addGestureRecognizer(tap)

        }
        
    }
    
    func orionVideoContentReady(toPlayVideo orionVideoContent: OrionVideoContent) {
        
        UIView.animate(withDuration: 0.2, animations: {(_: Void) -> Void in
            self.orionView.alpha = 1.0
        }, completion: {(_ finished: Bool) -> Void in
            orionVideoContent.play(0.0)
            orionVideoContent.volume = 1
            
        })
        print("OrionVideoContentReady")
        
    }
    
    func orionVideoContentDidReachEnd(_ orionVideoContent: OrionVideoContent) {
        orionVideoContent.seek(to: 0.0)
    }
    
    func orionVideoContentDidChangeBufferingStatus(_ orionVideoContent: OrionVideoContent!, buffering: Bool) {
        /*
         /**
         *  Current available seconds (buffered).
         */
         @property (nonatomic, readonly) CGFloat availableTime;
         */
        
        if(buffering)
        {
            print("buffer size: \(orionVideoContent.bufferSize)")
            print("buffer time: \(orionVideoContent.availableTime)")
        }
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer) {

            if (viewPort.viewportConfig.vrMode == OrionVrMode(VR_MODE_NONE))
            {
                viewPort.viewportConfig.vrMode = OrionVrMode(VR_MODE_2D)
                print("VR_MODE_2D")
                showAlert(alerMessage: "Tap the screen for VR 2D Portirait Mode")
            }
            else if(viewPort.viewportConfig.vrMode == OrionVrMode(VR_MODE_2D)){
                viewPort.viewportConfig.vrMode = OrionVrMode(VR_MODE_2D_PORTRAIT)
                print("VR_MODE_2D_PORTRAIT")
                showAlert(alerMessage: "Tap the screen to exit VR Mode")
            }
            else{
                viewPort.viewportConfig.vrMode = OrionVrMode(VR_MODE_NONE)
                print("Playing in normal mode")
            }
    }
    
    func orionContentDidFail(toBecomeReady orionContent: OrionContent!, content: Any!) {
        showAlert(alerMessage: "Orion did Fail to become ready")
    }

    @objc func orionVideoContentDidUpdateProgress(_ orionVideoContent: OrionVideoContent!, currentTime: CGFloat, totalDuration: CGFloat, loadedTimeRanges: [Any]!) {
        print ("\(NSDate()) orionVideoContentDidUpdateProgress, currentTime: \(currentTime), totalDuration \(totalDuration), loadedTimeRanges \(String(describing: loadedTimeRanges))")
        print("\(NSDate()) Current available seconds (buffered): \(orionVideoContent.availableTime)")

        
    }
   
    @objc func showAlert(alerMessage: String) {
        self.alert = UIAlertController(title: "Alert", message: alerMessage, preferredStyle: UIAlertControllerStyle.alert)
        self.present(self.alert, animated: true, completion: nil)
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(ViewController.dismissAlert), userInfo: nil, repeats: false)
    }
    
    @objc func dismissAlert(){
        // Dismiss the alert from here
        self.alert.dismiss(animated: true, completion: nil)
    }

}

