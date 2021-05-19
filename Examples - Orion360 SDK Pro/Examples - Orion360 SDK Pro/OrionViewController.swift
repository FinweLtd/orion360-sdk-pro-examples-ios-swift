//
//  OrionViewController.swift
//  Examples - Orion360 SDK Pro
//
//  Created by Tewodros Mengesha on 15/03/2018.
//  Copyright © 2018 Finwe Ltd. All rights reserved.
//

import UIKit
import Photos

let MARGIN = 0
let BUTTON_SIZE = 50



class OrionViewController: UIViewController, OrionViewDelegate, OrionVideoContentDelegate {
   
    //Segue Value
    var selectedFeature = ""
    var sSpeed: Float = 1.0  //Scrolling speed factor, 0.0f - 1.0f, default: 1.0f
    var alphaValue : Float = 1.0 // OrionViewport transparency. Default alpha value is Default 1.0f.
    
    private var isSeeking = false
    private var controlsHidden = false
    private var scale: Int = 0
    
    var selectedVrAction: Int = 0
    var startItems: NSMutableArray = []
    
    var orionView: OrionView!
    var videoContent: OrionVideoContent!
    var downloadedVideoContent: OrionVideoContent!
    var viewPort: OrionViewport!
    var fadeViewPort: OrionViewport!
    var startContent: OrionContent!
    
    
    var rotation : OrionViewRotation!
    var orionContent: OrionContent!
    
    var bottomBar: UIView!
    var timeSlider: UISlider!
    
    var playPauseButton: UIButton!
    var muteButton: UIButton!
    var timeLeftLabel: UILabel!
    var bufferIndicator: UIActivityIndicatorView!
    var timer: Timer!
    var tagSelectedLabel: UILabel!
    
    var leftCursor: UIImageView!
    var rightCursor: UIImageView!
    
    //var leftProgress = CircleProgressView(frame: <#CGRect#>)
    //var rightProgress = CircleProgressView(frame: <#CGRect#>)


    
    var hoverAudioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedVrAction = -1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if orionView == nil {
            
            //Create an instance of OrionView
            orionView = OrionView()
            orionView.scrollSpeed = CGFloat(sSpeed)
            orionView.delegate = self
            orionView.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)
            
            // Check if license file exists
            let licenseFile = "Orion360_SDK_Pro_iOS_Trial_fi.finwe.Examples---Orion360-SDK-Pro.lic"
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
                let alert = UIAlertController(title: "License Alert", message: "No license file found for Orion SDK pro.", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                let imgTitle = UIImage(named:"stop")
                let imgViewTitle = UIImageView(frame: CGRect(x: 10, y: 60, width: 50, height: 50))
                imgViewTitle.image = imgTitle
                
                alert.view.addSubview(imgViewTitle)
                alert.addAction(action)
                
                self.present(alert, animated: true, completion: nil)
            }
            
            self.view.addSubview(orionView)
            orionView.overrideSilentSwitch = true
            orionView.alpha = 0.0
            
            //Create an instance of OrionVideoContent
            videoContent = OrionVideoContent()
            videoContent.delegate = self
            
            let videoUrl = URL(string: "https://player.vimeo.com/external/187645100.m3u8?s=2fb48fc8005cebe2f10255fdc2fa1ed6da59ea53")
            //let videoUrl = URL(string: "http://yletv-lh.akamaihd.net/i/yletv2hls_1@103189/master.m3u8")
            //http://yletv-lh.akamaihd.net/i/yletv2hls_1@103189/master.m3u8
            videoContent.uriArray = [videoUrl!]
            orionView.add(videoContent)
            
            viewPort = OrionViewport(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height), lockInPosition: false)
            viewPort.viewportConfig.fullScreenEnabled = true
            
            orionView.add(viewPort, orionContent: videoContent)
            
            let alphaSlider = UISlider()
            let w = view.bounds.width
            alphaSlider.bounds.size.width = w
            alphaSlider.center = CGPoint(x: w/2, y: w/12)
            
            // Set Maximum and Minimum values
            alphaSlider.isUserInteractionEnabled = true
            alphaSlider.value = 1.0
            alphaSlider.minimumValue = 0.0
            alphaSlider.maximumValue = 1.0
            alphaSlider.minimumValueImage = UIImage(named:"minus")!
            alphaSlider.maximumValueImage = UIImage(named:"plus")!
            alphaSlider.addTarget(self, action: #selector (alphaSliderValueDidChange) ,for: .valueChanged)
            view.addSubview(alphaSlider)
            
            
            switch selectedFeature
            {
                //Preview Image
                case "Preview Image":
                    //Preview Image from asset
                    previewImage()
                case "Minimal video player":
                    //Minimal video player
                    minimalVideoPlayer()
                case "Advanced video player":
                    //Advanced video player
                    advancedVideoPlayer()
                case "Minimal video downloaded player":
                    //Minimal video downloaded player
                    minimalVideoDownloadedPlayer()
                case "Animation: Cross Fade":
                    //Cross Fade animation
                    crossFadeAnimation()
                case "VR mode: 2D":
                    //Vr mode: 2D
                    VrMode2D()
                case "VR mode: 2D Portrait":
                    //Vr mode: 2D Portrait
                    VrMode2DPortrait()
                case "Projection: Little Planet":
                    //Possible projection type: Little Planet
                    projectionLittlePlanet()
                case "Projection: Source Projection":
                    //Possible projection type: projecting the source
                    projectionSource()
                case "Hotspot":
                    //Hotspot
                    hotSpot()
                case "Heat map(log currentTime, pitch,yaw & roll)":
                   logCurrentRotation()
                default:
                    print("Some other feature")
            }
            
        }
        
    }
    @objc func alphaSliderValueDidChange(sender: UISlider!)
    {
        //print("Slider Value: \(sender.value)")
        alphaValue = sender.value
        self.orionView.alpha = CGFloat(self.alphaValue)
    }
    func orionVideoContentReady(toPlayVideo orionVideoContent: OrionVideoContent) {
        
        UIView.animate(withDuration: 0.2, animations: {
            //self.orionView.alpha = 1.0
            self.orionView.alpha = CGFloat(self.alphaValue)
        }, completion: {(_ finished: Bool) -> Void in
            orionVideoContent.play(0.0)
            if (self.selectedFeature == "Advanced video player")
            {self.timeSlider.maximumValue = Float(self.videoContent.totalDuration)}
            
        })
        print("OrionVideoContentReady")
        
    }
    func orionVideoContentDidUpdateProgress(_ orionVideoContent: OrionVideoContent!, currentTime: CGFloat, totalDuration: CGFloat, loadedTimeRanges: [Any]!) {
        //self.orionView.alpha = CGFloat(self.alphaValue)
    }
    func orionVideoContentDidUpdateProgress(_ orionVideoContent: OrionVideoContent!, currentTime: CGFloat, availableTime: CGFloat, totalDuration: CGFloat) {
        if (selectedFeature == "Advanced video player")
        {
            if CGFloat(timeSlider.maximumValue) != totalDuration
            {
                timeSlider.maximumValue = Float(totalDuration)
            }
            if !isSeeking
            {
                timeSlider.value = Float(currentTime)
                updateTimeLabel(Int(currentTime))
            }
        }
        if(selectedFeature == "Heat map(log currentTime, pitch,yaw & roll)")
        {
            print("Current time:\(currentTime), Pitch: \(viewPort.presentationConfig.currentRotation.pitch), Yaw: \(viewPort.presentationConfig.currentRotation.yaw) Roll: \(viewPort.presentationConfig.currentRotation.roll)")
        }

    }

    func orionVideoContentDidChangeBufferingStatus(_ orionVideoContent: OrionVideoContent!, buffering: Bool) {
        if (selectedFeature == "Advanced video player")
        {
            if buffering && !bufferIndicator!.isAnimating
            {
                bufferIndicator.startAnimating()
            }
            else if !buffering && bufferIndicator!.isAnimating
            {
                bufferIndicator.stopAnimating()
            }
        }

    }
    
    func orionVideoContentDidReachEnd(_ orionVideoContent: OrionVideoContent) {
        orionVideoContent.seek(to: 0.0)
    }
    
    /**
     * Log currentTime, Pitch, Yaw and roll
     */
    
    func logCurrentRotation() {
        videoContent.play()
       orionVideoContentDidUpdateProgress(videoContent, currentTime: videoContent.currentTime, availableTime: videoContent.availableTime, totalDuration: videoContent.totalDuration)
        
    }

    /**
     * Preview Image from asset
     */
    func previewImage()
    {
        print("Preview Image from asset")

        orionView.orionContentArray.removeAllObjects()
        let imageName = "olos.jpg"
        let image = UIImage(named: imageName)
        let stereo: OrionStereoScopic = OrionStereoScopic(STEREOSCOPIC_NONE)
        let photoContent = OrionContent()
        photoContent.stereoScopic = stereo
        photoContent.delegate = self
        photoContent.imageArray = [image!]
        orionView.add(photoContent)
        orionView.add(viewPort, orionContent: photoContent)
    }
    /**
     * Minimal Video player
     */
    func minimalVideoPlayer()
    {
        //viewPort.viewportConfig.projection = OrionProjection(PROJECTION_EQUIRECT) //Default projection
        videoContent.projection = OrionProjection(PROJECTION_EQUIRECT) //Default projection
        print("Minimal video player")
    }
    
    /**
     * Minimal video downloaded player
     */
    func minimalVideoDownloadedPlayer()
    {
        print("Minimal video downloaded player")
        orionView.orionContentArray.removeAllObjects()
        let urlString = "https://s3.amazonaws.com/orion360-us/Orion360_test_video_2d_equi_360x135deg_960x360pix_30fps_30sec_x264.mp4"

        // use guard to make sure you have a valid url
        
        guard let videoURL = URL(string: urlString) else { return }
        
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        // check if the file already exist at the destination folder if you don't want to download it twice
        if !FileManager.default.fileExists(atPath: documentsDirectoryURL.appendingPathComponent(videoURL.lastPathComponent).path) {
            
            // set up your download task
            URLSession.shared.downloadTask(with: videoURL) { (location, response, error) -> Void in
                
                // use guard to unwrap your optional url
                guard let location = location else { return }
                
                // create a deatination url with the server response suggested file name
                let destinationURL = documentsDirectoryURL.appendingPathComponent(response?.suggestedFilename ?? videoURL.lastPathComponent)
                
                do {
                    
                    try FileManager.default.moveItem(at: location, to: destinationURL)
                    
                    PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in
                        
                        // check if user authorized access photos for your app
                        if authorizationStatus == .authorized {
                            PHPhotoLibrary.shared().performChanges({
                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destinationURL)}) { completed, error in
                                    if completed {
                                        print("Video asset created")
                                        self.downloadedVideoContent = OrionVideoContent()
                                        self.downloadedVideoContent.delegate = self
                                        let fileUrl = URL(fileURLWithPath :  destinationURL.path)
                                        self.downloadedVideoContent.uriArray = [fileUrl]
                                        
                                        
                                        print("File Path: \(fileUrl)")
                                        
                                        self.orionView.add(self.downloadedVideoContent)
                                        self.orionView.add(self.viewPort, orionContent: self.downloadedVideoContent)
                                        
                                        self.viewPort.viewportConfig.projection = OrionProjection(PROJECTION_EQUIRECT)
                                    } else {
                                        print(error!)
                                    }
                            }
                        }
                    })
                    
                } catch { print(error) }
                
                }.resume()
            
        } else {
            print("File already exists at destination url")
            let testURL = documentsDirectoryURL.appendingPathComponent(videoURL.lastPathComponent).path
            print("File Path: \(testURL)")
            self.downloadedVideoContent = OrionVideoContent()
            self.downloadedVideoContent.delegate = self
            let fileUrl = URL(fileURLWithPath :  testURL)
            self.downloadedVideoContent.uriArray = [fileUrl]
            self.orionView.add(self.downloadedVideoContent)
            self.orionView.add(self.viewPort, orionContent: self.downloadedVideoContent)
            self.viewPort.viewportConfig.projection = OrionProjection(PROJECTION_EQUIRECT)
        }
        
   }

    /**
     * Cross fade animation
     */
    func crossFadeAnimation()
    {        
        //orionView.orionContentArray.removeAllObjects()
        fadeViewPort = OrionViewport(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height), lockInPosition: false)
        fadeViewPort.viewportConfig.fullScreenEnabled = true
        viewPort.viewportConfig.alpha = 1
        self.orionView.alpha = 1
        print("Cross fade animation")
        
        let imageName = "Orion360_preview_image_1920x960.jpg"
        //let imageName = "splash.png"

        let image = UIImage(named: imageName)
        
        let stereo: OrionStereoScopic = OrionStereoScopic(STEREOSCOPIC_NONE)

        let photoContent = OrionContent()
        photoContent.stereoScopic = stereo
        photoContent.delegate = self
        photoContent.imageArray = [image!]
        print(photoContent.imageArray)
        orionView.add(photoContent)
        photoContent.projection = OrionProjection(PROJECTION_EQUIRECT) //Test projection
        
        orionView.add(fadeViewPort, orionContent: photoContent)
        
        
        fadeViewPort.viewportConfig.animateFullScreenInFrames = 0
        //self.orionView.alpha = 1.0
        
       //self.orionView.crossFadeViewports(self.viewPort, outViewport: self.fadeViewPort)
        
//        let deadlineTime = DispatchTime.now() + .seconds(5)
//        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
////            self.viewPort.viewportConfig.alpha = 1.0
////            self.fadeViewPort.viewportConfig.alpha = 0.0
//            self.orionView.crossFadeViewports(self.viewPort, outViewport: self.fadeViewPort)
//
//        })
        
       Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { (timer) in
                        self.viewPort.viewportConfig.alpha = 1.0
                        self.fadeViewPort.viewportConfig.alpha = 0.0
                        self.orionView.crossFadeViewports(self.viewPort, outViewport: self.fadeViewPort)
        }
    }

    /**
     * Projection: Little planet
     */
    func projectionLittlePlanet()
    {
        viewPort.viewportConfig.projection = OrionProjection(PROJECTION_LITTLE_PLANET)
        print("Projection: LITTLE_PLANET")
    }
    
    /**
     * Projection: Projecting the entire source / Overview
     */
    func projectionSource()
    {
        viewPort.viewportConfig.projection = OrionProjection(PROJECTION_SOURCE)
        print("Projection: PROJECTION_SOURCE")
    }
    
    /**
     * VR Mode: VR_MODE_2D
     */

    func VrMode2D()
    {
        viewPort.viewportConfig.vrMode = OrionVrMode(VR_MODE_2D)
        print("VR_MODE_2D")
    }
    
    /**
     * VR Mode: VR_MODE_2D_PORTRAIT
     */
    func VrMode2DPortrait()
    {
        viewPort.viewportConfig.vrMode = OrionVrMode(VR_MODE_2D_PORTRAIT)
        
        print("VR_MODE_2D_PORTRAIT")
    }
    
    /**
     * Hotspot
     */
    func hotSpot()
    {
        print("Hotspot test")
        let startContent = OrionContent()
        startContent.imageArray = [UIImage(named: "hsPlayPause")!]
        orionView.add(startContent)
        
        videoContent.delegate = self
        orionView.add(videoContent)
        let orionViewPortItem = OrionViewportItem()
        
        viewPort.presentationConfig.minFov = 60.0 * 3.14 / 180.0
        viewPort.presentationConfig.maxFov = 140.0 * 3.14 / 180.0
        viewPort.presentationConfig.currentFov = 140.0 * 3.14 / 180.0
        viewPort.viewportConfig.vrControlsInitializationDistance = 30.0
        
        let selectionContent = OrionContent()
        selectionContent.imageArray = [UIImage(named: "selectionCircle1")!]
        orionView.add(selectionContent)
        orionViewPortItem.orionSelectionContent = selectionContent;
        orionViewPortItem.visibleInModes = UInt(OrionViewportItemVisibleVRMode2D) | UInt(OrionViewportItemVisibleVRMode2DPortrait)
        
        orionViewPortItem.pulsingSpeed = 7
        orionViewPortItem.alpha = 1.0
        orionViewPortItem.visible = true
        orionViewPortItem.scale = 1.0
        orionViewPortItem.rotation = OrionViewRotation()
        orionViewPortItem.rotation.pitch = -20 //Rotation around x-axis in degrees (0-360)
        orionViewPortItem.rotation.yaw = 200 //Rotation around Y-axis in degrees (0-360)
        orionViewPortItem.rotation.roll = -10 // Rotation around z-axis in degrees (0-360)
        orionViewPortItem.bgScaleFactor = 1.4
        orionViewPortItem.actionIndex = 100
        orionViewPortItem.orionContent = startContent
        orionViewPortItem.selectionInFrames = 160
        orionViewPortItem.selectionZoomScale = 1.5
        orionView.add(orionViewPortItem)
        orionView.attachOrionViewportItemtoViewport(orionViewPortItem, orionViewport: viewPort)
        
        viewPort.viewportConfig.fullScreenEnabled = true
        viewPort.viewportConfig.vrMode = OrionVrMode(VR_MODE_2D)
        viewPort.viewportConfig.vrModeControls = true
    }
    
   
    /**
     *  Hotspot action method
     */
    func orionViewportSingleTap(toViewportItem view: OrionView!, viewport: OrionViewport!, viewportItem: OrionViewportItem!, point: CGPoint) {
        /*
        let alert = UIAlertController(title: "Hotspot Action Alert", message: "Greetings from SDK Pro, hotspot action example 😀.", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        let imgTitle = UIImage(named:"signal")
        let imgViewTitle = UIImageView(frame: CGRect(x: 10, y: 60, width: 50, height: 50))
        imgViewTitle.image = imgTitle
        
        alert.view.addSubview(imgViewTitle)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
         
         */
        
        //showHideViewFinders (true)

        if (videoContent.isPaused())
        {
            videoContent.play()
            print ("viewPort clicked, to play")
        }
        else
        {
            videoContent.pause()
            print ("viewPort clicked, to pause")
        }
    }
    
    //Test showHide finders
    func showViewFinders() {
        print("Show finder")
        
        let image = UIImage(named: "viewFinder")
        
        let h: CGFloat? = image?.size.height
        let w: CGFloat? = image?.size.width
        let newW: CGFloat = 45
        let newH: CGFloat = newW / (w ?? 0.0) * (h ?? 0.0)
        
        if leftCursor == nil {
            leftCursor = UIImageView(image: image)
            leftCursor.frame = CGRect(x: 0, y: 0, width: newW, height: newH)
            leftCursor.center = CGPoint(x:  orionView.bounds.size.width / 4, y: orionView.center.y)
            view.addSubview(leftCursor)
        }
        if rightCursor == nil
        {
            rightCursor = UIImageView(image: image)
            rightCursor.frame = CGRect(x: 0, y: 0, width: newW, height: newH)
            rightCursor.center = CGPoint(x:  orionView.bounds.size.width / 4 * 3, y: orionView.center.y)
            view.addSubview(rightCursor)
        }
        
        leftCursor.alpha = 1.0
        rightCursor.alpha = 1.0
    }
    
    func hideViewFinders() {
        leftCursor.alpha = 0.0
        rightCursor.alpha = 0.0
    }
    
    func orionViewportDidChangeVrControlState(_ view: OrionView!, actionIndex: UInt, viewport: OrionViewport!, state: UInt) {
        if(view.orionViewportItemArray.count == 0)
         {
             return;
         }
        
        print(state)
        
        switch (state){
        case UInt(VR_CONTROL_STATE_OFF):
            print ("VR_CONTROL_STATE_OFF, \(actionIndex)")
            hideViewFinders()
        case UInt(VR_CONTROL_STATE_INITIALIZED):
            print ("VR_CONTROL_STATE_INITIALIZED, \(actionIndex)")
            showViewFinders()
        case UInt(VR_CONTROL_STATE_VIEWPORTITEM_SELECTING):
            print ("VR_CONTROL_STATE_VIEWPORTITEM_SELECTING , \(actionIndex)")
        case UInt(VR_CONTROL_STATE_VIEWPORTITEM_UNSELECTING):
            print ("VR_CONTROL_STATE_VIEWPORTITEM_UNSELECTING , \(actionIndex)")
        case UInt(VR_CONTROL_STATE_SELECTED):
            print ("VR_CONTROL_STATE_SELECTED , \(actionIndex)")
            videoContent.isPaused() ? videoContent.play() : videoContent.pause()
            hideViewFinders()
        default:
            print("something else")
        }
    }
    /**
     * Advanced video player, with pause/play, mute/unmute, slidder features.
     */
    func advancedVideoPlayer()
    {
        print("Advanced video player")
        
        // Bottom bar
        let bottomBarH: CGFloat = CGFloat(BUTTON_SIZE + 2 * MARGIN)
        bottomBar = UIView(frame: CGRect(x: 0, y: view.bounds.size.height - bottomBarH, width: view.bounds.size.width, height: bottomBarH))
        bottomBar.backgroundColor = UIColor.clear
        view.addSubview(bottomBar)
        
        // Play/Pause button
        playPauseButton = UIButton(type: .custom) as UIButton
        playPauseButton.frame = CGRect(x: MARGIN, y: MARGIN, width: BUTTON_SIZE, height: BUTTON_SIZE)
        playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        playPauseButton.addTarget(self, action: #selector(OrionViewController.playPause(_:)), for: .touchUpInside)
        playPauseButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        bottomBar.addSubview(playPauseButton)
        
        // Time left label
        timeLeftLabel = UILabel(frame: CGRect(x: Int((bottomBar.frame.width) - CGFloat(BUTTON_SIZE * 4 - MARGIN)), y: MARGIN, width: BUTTON_SIZE * 4, height: BUTTON_SIZE))
        timeLeftLabel.text = "0:00 | 0:00"
        timeLeftLabel.textColor = UIColor.white
        timeLeftLabel.textAlignment = .center
        bottomBar.addSubview(timeLeftLabel)
        
        // Time slider
        let sliderX = Int(playPauseButton.frame.maxX) * 2
        let sliderY = MARGIN
        let sliderH = BUTTON_SIZE
        let sliderW = Int(timeLeftLabel.frame.minX) - sliderX
        
        timeSlider = UISlider(frame: CGRect(x: sliderX, y: sliderY, width: sliderW, height: sliderH))
        
        timeSlider.addTarget(self, action: #selector(OrionViewController.timeSliderDragExit(sender:)), for: .touchUpInside)
        timeSlider.addTarget(self, action: #selector(OrionViewController.timeSliderDragExit(sender:)), for: .touchUpOutside)
        timeSlider.addTarget(self, action: #selector(OrionViewController.timeSliderDragEnter(sender:)), for: .touchDown)
        timeSlider.addTarget(self, action: #selector(OrionViewController.timeSliderValueChanged(sender:)), for: .valueChanged)
        
        timeSlider.backgroundColor = UIColor.clear
        timeSlider.minimumValue = Float(truncating: 0.0 as NSNumber)
        timeSlider.maximumValue = Float(truncating: 0.0 as NSNumber)
        bottomBar.addSubview(timeSlider!)
        
        let sliderTapGr = UITapGestureRecognizer(target: self, action: #selector(OrionViewController.sliderTapped(_:)))
        timeSlider.addGestureRecognizer(sliderTapGr)
    
        // Mute button
        muteButton = UIButton(type: .custom)
        muteButton.frame = CGRect(x: Int((bottomBar.frame.width) - CGFloat(BUTTON_SIZE - MARGIN)), y: MARGIN, width: BUTTON_SIZE, height: BUTTON_SIZE)
    
        muteButton.setImage(UIImage(named: "sound_on"), for: .normal)
        muteButton.addTarget(self, action: #selector(OrionViewController.mute(_:)), for: .touchUpInside)
        bottomBar.addSubview(muteButton!)
        
        // Tap gesture Recognizer
        let tapGr = UITapGestureRecognizer(target: self, action: #selector(self.tapDetected(_:)))
        tapGr.delegate = self as? UIGestureRecognizerDelegate
        view.addGestureRecognizer(tapGr)
        
        // Indicator for buffering state
        bufferIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        bufferIndicator.center = CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2)
        view.addSubview(bufferIndicator!)
        bufferIndicator.startAnimating()
        
    }
    
    /**
     *  Function called when Play/Pause button is selected.
     */
    @objc func playPause(_ button: UIButton?)
    {
        
        if (videoContent.isPaused())
        {
            videoContent.play()
            playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        }
        else
        {
            videoContent.pause()
            playPauseButton.setImage(UIImage(named: "play"), for: .normal)
        }
        
    }
    
    /**
     *  Function called when mute button selected.
     */
    @objc func mute(_ button: UIButton)
    {
        if videoContent.volume == 0.0
        {
            videoContent.volume = 1.0
            muteButton.setImage(UIImage(named: "sound_on"), for: .normal)
        }
        else
        {
            videoContent.volume = 0.0
            muteButton.setImage(UIImage(named: "sound_off"), for: .normal)
        }
    }
    
    /**
     *  Function called when time slider dragged.
     */
    
    @IBAction func timeSliderDragEnter(sender: UISlider)
    {
        isSeeking = true
    }
    
    /**
     *  Function called when time slider value changed (dragging).
     */
    
    @IBAction func timeSliderValueChanged(sender: UISlider)
    {
        updateTimeLabel(Int(sender.value))
    }
    
    /**
     *  Function called when time slider dragging ended.
     */
    
    @IBAction func timeSliderDragExit(sender: UISlider)
    {
        videoContent.seek(to: CGFloat(sender.value))
        isSeeking = false
    }
    
    /**
     *  Function called when time slider has been tapped.
     */
    
    @IBAction func sliderTapped(_ g: UIGestureRecognizer)
    {
        let s = g.view as! UISlider
        let pt: CGPoint = g.location(in: s)
        let percentage: CGFloat = pt.x / (s.bounds.size.width)
        let delta: CGFloat = percentage * CGFloat((s.maximumValue) - (s.minimumValue))
        let value: CGFloat = CGFloat (s.minimumValue) + (delta)
        s.setValue(Float(value), animated: true)
        videoContent.seek(to: value)
        isSeeking = false
        updateTimeLabel(Int(value))
    }
    
    /**
     *  Function to update time label.
     */
    
    func updateTimeLabel(_ totalSeconds: Int)
    {
        let seconds:Int = totalSeconds % 60
        let minutes:Int = (totalSeconds / 60) % 60
        let durationSeconds = Int((timeSlider.maximumValue)) % 60
        let durationMinutes = (Int((timeSlider.maximumValue)) / 60) % 60
        timeLeftLabel.font = UIFont.systemFont(ofSize: 16)
        timeLeftLabel.text = "\(String(format: "%0.2d:%0.2d", minutes, seconds))" + " | " + "\(String(format: "%0.2d:%0.2d", durationMinutes, durationSeconds))"
    }
    
    
    /**
     *  Function called when tap detected on the screen.
     */
    
    @objc func tapDetected(_ gr: UITapGestureRecognizer)
    {
        showHideControlBars(!controlsHidden)
    }
    
    /**
     *  Function to show or hide control bars.
     */
    
    func showHideControlBars(_ hide: Bool)
    {
        if hide == controlsHidden
        {
            return
        }
        var bottomFrame: CGRect = bottomBar!.frame
        if hide
        {
            bottomFrame.origin.y = view.bounds.size.height
            
        }
        else
        {
            bottomFrame.origin.y = view.bounds.size.height - bottomFrame.size.height
            
        }
        controlsHidden = hide
        UIView.animate(withDuration: 0.3, animations: {(_: Void) -> Void in
            self.bottomBar.frame = bottomFrame
        })
    }
    



}
