//
//  ViewController.swift
//  ExampleAdvancedPlayer
//
//  Created by Tewodros Mengesha on 23/02/2018.
//  Copyright © 2018 Finwe Ltd. All rights reserved.
//

/**
 * ExampleAdvancedPlayer implements an advanced Orion1 video player. It plays
 * a video file from url using Orion1View with selected settings.
 *
 * Features:
 * - Plays one hardcoded 360x180 equirectangular video
 * - Auto-starts playback on load
 * - Restarts after playback is finished (loop)
 * - Remembers player position and state
 * - Playback can be controlled (play, pause, scrubbing)
 * - Media controller can be shown/hidden by tapping
 * - Sensor fusion type can be selected from menu
 * - Panning (gyro, swipe)
 * - Zooming (pinch)
 * - Mute / unmute
 * - Fullscreen, landscape
 */

import UIKit

let MARGIN = 10
let BUTTON_SIZE = 50

enum myEnum:Int
{
    case sensors = 0
    case vr
    case touch
}

typealias ControlMode = Int

class ViewController: UIViewController, Orion1ViewDelegate, UIGestureRecognizerDelegate
{
    
    private var isSeeking = false
    private var controlsHidden = false
    private var controlMode = ControlMode()
    private var scale: Int = 0
    
    var orionView: Orion1View!
    var timeSlider: UISlider!
    var playPauseButton: UIButton!
    var muteButton: UIButton!
    var vrButton: UIButton!
    var timeLeftLabel: UILabel!
    var bottomBar: UIView!
    var bufferIndicator: UIActivityIndicatorView!
    var timer: Timer!
    var tagSelectedLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        
        //Create OrionView
        orionView = Orion1View(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
        orionView.delegate = self
        orionView.overrideSilentSwitch = true
        
        view.addSubview(orionView)
        
        //License URL
        let path: String? = Bundle.main.path(forResource: "Orion360_SDK_Basic_iOS_Trial_finwe.ExampleAdvancedPlayer.lic", ofType: nil)
        let licenseUrl = URL(fileURLWithPath: path ?? "")
        
        //Video URL
        let videoUrl = URL(string: "https://fpdl.vimeocdn.com/vimeo-prod-skyfire-std-us/01/2529/7/187645100/620120791.mp4?token=1520248711-0x55c2f0e9ecddf5b9e76ed1b57c5618832b1de7b6")
        
        //Set video and license url
        orionView.initVideo(with: videoUrl, previewImageUrl: nil, licenseFileUrl: licenseUrl)
        
        
        /* Video from local directory */
        //let filePath = Bundle.main.path(forResource: "HLS-Streaming-adaptive-on-net-speed", ofType: ".mov")
        //let videoUrl = NSURL(fileURLWithPath: filePath!)
        //orionView.initVideo(with: videoUrl as URL!, previewImageUrl: nil, licenseFileUrl: licenseUrl)
        
        
        controlMode = myEnum.sensors.rawValue
        prepareView()
    }
    
    
    func prepareView()
    {
        // Bottom bar
        let bottomBarH: CGFloat = CGFloat(BUTTON_SIZE + 2 * MARGIN)
        bottomBar = UIView(frame: CGRect(x: 0, y: view.bounds.size.height - bottomBarH, width: view.bounds.size.width, height: bottomBarH))
        bottomBar.backgroundColor = UIColor.clear
        view.addSubview(bottomBar)
        
        // Play/Pause button
        playPauseButton = UIButton(type: .custom) as UIButton
        playPauseButton.frame = CGRect(x: 0, y: MARGIN, width: BUTTON_SIZE, height: BUTTON_SIZE)
        playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        playPauseButton.addTarget(self, action: #selector(ViewController.playPause(_:)), for: .touchUpInside)
        playPauseButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        bottomBar.addSubview(playPauseButton)
        
        // Time left label
        timeLeftLabel = UILabel(frame: CGRect(x: Int((bottomBar.frame.width) - CGFloat(BUTTON_SIZE * 4 - MARGIN)), y: MARGIN, width: BUTTON_SIZE * 2, height: BUTTON_SIZE))
        timeLeftLabel.text = "0:00 | 0:00"
        timeLeftLabel.textColor = UIColor.white
        timeLeftLabel.textAlignment = .center
        bottomBar.addSubview(timeLeftLabel)
        
        
        // Time slider
        let sliderX = Int(playPauseButton.frame.maxX)
        let sliderY = MARGIN
        let sliderH = BUTTON_SIZE
        let sliderW = Int(timeLeftLabel.frame.minX) - sliderX
        
        timeSlider = UISlider(frame: CGRect(x: sliderX, y: sliderY, width: sliderW, height: sliderH))
        
        timeSlider.addTarget(self, action: #selector(ViewController.timeSliderDragExit(sender:)), for: .touchUpInside)
        timeSlider.addTarget(self, action: #selector(ViewController.timeSliderDragExit(sender:)), for: .touchUpOutside)
        timeSlider.addTarget(self, action: #selector(ViewController.timeSliderDragEnter(sender:)), for: .touchDown)
        timeSlider.addTarget(self, action: #selector(ViewController.timeSliderValueChanged(sender:)), for: .valueChanged)
        
        timeSlider.backgroundColor = UIColor.clear
        timeSlider.minimumValue = Float(truncating: 0.0 as NSNumber)
        timeSlider.maximumValue = Float(truncating: 0.0 as NSNumber)
        bottomBar.addSubview(timeSlider!)
        
        let sliderTapGr = UITapGestureRecognizer(target: self, action: #selector(ViewController.sliderTapped(_:)))
        timeSlider.addGestureRecognizer(sliderTapGr)
        
        // VR button
        vrButton = UIButton(type: .custom)
        vrButton.frame = CGRect(x: Int((bottomBar.frame.width) - CGFloat(2 * BUTTON_SIZE - MARGIN)), y: MARGIN, width: BUTTON_SIZE, height: BUTTON_SIZE)
        vrButton.setImage(UIImage(named: "sensors"), for: .normal)
        vrButton.addTarget(self, action: #selector(ViewController.controlMode(_:)), for: .touchUpInside)
        vrButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        bottomBar.addSubview(vrButton!)
        
        // Mute button
        muteButton = UIButton(type: .custom)
        muteButton.frame = CGRect(x: Int((bottomBar.frame.width) - CGFloat(BUTTON_SIZE - MARGIN)), y: MARGIN, width: BUTTON_SIZE, height: BUTTON_SIZE)
        muteButton.setImage(UIImage(named: "sound_on"), for: .normal)
        muteButton.addTarget(self, action: #selector(ViewController.mute(_:)), for: .touchUpInside)
        bottomBar.addSubview(muteButton!)
        
        // Tap gesture regocnizer
        let tapGr = UITapGestureRecognizer(target: self, action: #selector(self.tapDetected(_:)))
        tapGr.delegate = self
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
    
    @objc func playPause(_ button: UIButton)
    {
        
        if (orionView.isPaused())
        {
            orionView.play()
            playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        }
        else
        {
            orionView.pause()
            playPauseButton.setImage(UIImage(named: "play"), for: .normal)
        }
        
    }
    
    /**
     *  Function called when mute button selected.
     */
    
    @objc func mute(_ button: UIButton)
    {
        if orionView.volume == 0.0
        {
            orionView.volume = 1.0
            muteButton.setImage(UIImage(named: "sound_on"), for: .normal)
        }
        else
        {
            orionView.volume = 0.0
            muteButton.setImage(UIImage(named: "sound_off"), for: .normal)
        }
    }
    
    /**
     *  Function called when VR button selected.
     */
    
    @objc func controlMode(_ button: UIButton)
    {
        if controlMode == myEnum.sensors.rawValue
        {
            vrButton.setImage(UIImage(named: "vr"), for: .normal)
            orionView.vrModeEnabled = true
            controlMode = myEnum.vr.rawValue
        }
        else if controlMode == myEnum.vr.rawValue
        {
            vrButton.setImage(UIImage(named: "touch"), for: .normal)
            orionView.vrModeEnabled = false
            orionView.sensorsDisabled = true
            controlMode = myEnum.touch.rawValue
        }
        else if controlMode == myEnum.touch.rawValue
        {
            vrButton.setImage(UIImage(named: "sensors"), for: .normal)
            orionView.sensorsDisabled = false
            controlMode = myEnum.sensors.rawValue
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
        orionView.seek(to: CGFloat(sender.value))
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
        orionView.seek(to: value)
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
    
    //- Orino1View delegate functions
    func orion1ViewVideoDidReachEnd(_ orion1View: Orion1View)
    {
        orion1View.play(0.0)
    }
    
    func orion1ViewReady(toPlayVideo orion1View: Orion1View)
    {
        orion1View.play(0.0)
        timeSlider.maximumValue = Float(orion1View.totalDuration)
    }
    
    func orion1ViewDidUpdateProgress(_ orion1View: Orion1View, currentTime: CGFloat, availableTime: CGFloat, totalDuration: CGFloat)
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
        // Move the tag
        orionView.setTagLocation(1, yawAngle: currentTime, pitchAngle: 0.0)
    }
    
    func orion1ViewDidChangeBufferingStatus(_ orion1View: Orion1View, buffering: Bool) {
        if buffering && !bufferIndicator!.isAnimating
        {
            bufferIndicator.startAnimating()
        }
        else if !buffering && bufferIndicator!.isAnimating
        {
            bufferIndicator.stopAnimating()
        }
    }
    
    private func orion1ViewTagDidSelect(_ orion1View: Orion1View, tagIndex: Int)
    {
        // Change the tag image to indicate that it was selected
        let path: String? = Bundle.main.path(forResource: "finwe", ofType: "png")
        let url = URL(fileURLWithPath: path ?? "")
        orionView.setTagAssetURL(1, tagAssetURL: url)
        // Create timer to change the tag image back to original
        createTimer()
    }
    
    private func orion1ViewTagDidChangeVRControlState(_ orion1View: Orion1View, state: TagVRControlState, tagIndex: Int)
    {
        // VR mode states for tag selection
        switch state {
        case .VR_CONTROL_STATE_TAG_INITIALIZED: break
            // tag selection initiated
            
        case .VR_CONTROL_STATE_TAG_SELECTING:
            // tag selection ongoing
            // Set the tag scale bigger to indicate that the selection is ongoing
            scale += 1
            orionView.setTagScale(1, scale: CGFloat(scale))
            createTimer()
        case .VR_CONTROL_STATE_TAG_UNSELECTING:
            // tag unselection ongoing
            // Set the tag scale smaller to indicate that the unselection is ongoing
            scale -= 1
            orionView.setTagScale(1, scale: CGFloat(scale))
            createTimer()
        case .VR_CONTROL_STATE_TAG_SELECTED:
            // tag selected
            // Change the tag image to indicate that it was selected
            scale = 2
            orionView.setTagScale(1, scale: CGFloat(scale))
            let path: String? = Bundle.main.path(forResource: "finwe", ofType: "png")
            let url = URL(fileURLWithPath: path ?? "")
            orionView.setTagAssetURL(1, tagAssetURL: url)
            createTimer()
        default:
            // case VR_CONTROL_STATE_TAG_OFF
            scale = 2
            orionView.setTagScale(1, scale: CGFloat(scale))
        }
        return
    }
    
    /**
     * Function to create timer
     **/
    
    func createTimer()
    {
        if (timer != nil)
        {
            timer.invalidate()
            timer = nil
        }
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: Selector(("onTick:")), userInfo: nil, repeats: false)
    }
    
    /**
     * Timer selector function
     **/
    
    func onTick(_ timer: Timer)
    {
        // Set tag scale and image back to original
        scale = 2
        orionView.setTagScale(1, scale: CGFloat(scale))
        let path: String? = Bundle.main.path(forResource: "tag", ofType: "png")
        let url = URL(fileURLWithPath: path ?? "")
        orionView.setTagAssetURL(1, tagAssetURL: url)
    }
    
    
}


