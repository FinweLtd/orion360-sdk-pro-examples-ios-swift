//
//  CircleProgressView.swift
//  Examples - Orion360 SDK Pro
//
//  Created by Tewodros Mengesha on 26/04/2018.
//  Copyright © 2018 Finwe Ltd. All rights reserved.
//

/*
import Foundation

class CircleProgressView {
    var startAngle: CGFloat = 0.0
    var lineColor: UIColor!
    
    init(frame: CGRect) {
        //super.init(frame: frame)
        super.awakeWithFrame(frame)
        
        // Initialization code
        //backgroundColor = UIColor.clear
        // Determine our start and stop angles for the arc (in radians)
        startAngle = .pi * 1.5
        UnitAngle = startAngle + (.pi * 2)
        glLineWidth = 3.0
        lineColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6)
        
    }
    func draw(_ rect: CGRect) {
        let bezierPath = UIBezierPath()
        bezierPath.lineWidth = glLineWidth
        // Create our arc, with the correct angles
        bezierPath.addArc(withCenter: CGPoint(x: rect.size.width / 2, y: rect.size.height / 2), radius: rect.size.width / 2 - bezierPath.lineWidth / 2, startAngle: startAngle, endAngle: (UnitAngle - startAngle) * Progress + startAngle, clockwise: true)
        // Set the display for the path, and stroke it
        lineColor.setStroke()
        bezierPath.stroke()
    }
}
*/
