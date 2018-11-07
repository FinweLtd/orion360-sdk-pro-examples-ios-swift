//
//  testAPlayer.swift
//  Examples - Orion360 SDK Pro
//
//  Created by Tewodros Mengesha on 23/04/2018.
//  Copyright © 2018 Finwe Ltd. All rights reserved.
//

import Foundation
class OrionViewController: UIViewController, OrionViewDelegate, OrionVideoContentDelegate {
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
}
