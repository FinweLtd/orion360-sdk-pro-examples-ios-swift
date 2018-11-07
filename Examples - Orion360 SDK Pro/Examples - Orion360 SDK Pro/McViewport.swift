
/*
func showHideViewFinders(_ hide: Bool) {
    if !enterView {
        var removeVFS = false
        var alpha: CGFloat = 1.0
        if hide {
            alpha = 0.0
        }
        removeVFS = hide
        if !hide {
            let lineWidht: CGFloat = 2.5
            let lineColor: UIColor? = UIColor.black
            let image = UIImage(named: "viewFinder")
            let h: CGFloat? = image?.size.height
            let w: CGFloat? = image?.size.width
            let newW: CGFloat = 45
            let newH: CGFloat = newW / (w ?? 0.0) * (h ?? 0.0)
            if !leftCursor {
                leftCursor = UIImageView(image: image)
                leftCursor.frame = CGRect(x: 0, y: 0, width: newW, height: newH)
                if viewport.viewportConfig.vrMode == VR_MODE_2D {
                    leftCursor.center = CGPoint(x: view.frame.size.width / 4, y: view.frame.size.height / 2)
                } else {
                    leftCursor.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height / 2)
                }
                leftCursor.alpha = 0.0
                view.addSubview(leftCursor)
            }
            if !leftProgress {
                leftProgress = CircleProgressView(frame: CGRect(x: 0, y: 0, width: leftCursor.frame.width, height: leftCursor.frame.width))
                leftProgress.center = leftCursor.center
                leftProgress.lineWidht = lineWidht
                leftProgress.lineColor = lineColor
                view.insertSubview(leftProgress, belowSubview: leftCursor)
            }
            if !rightCursor && viewport.viewportConfig.vrMode == VR_MODE_2D {
                rightCursor = UIImageView(image: image)
                rightCursor.frame = CGRect(x: 0, y: 0, width: newW, height: newH)
                rightCursor.center = CGPoint(x: 3 * view.frame.size.width / 4, y: view.frame.size.height / 2)
                rightCursor.alpha = 0.0
                view.addSubview(rightCursor)
            }
            if !rightProgress && viewport.viewportConfig.vrMode == VR_MODE_2D {
                rightProgress = CircleProgressView(frame: CGRect(x: 0, y: 0, width: rightCursor.frame.width, height: rightCursor.frame.width))
                rightProgress.center = rightCursor.center
                rightProgress.lineWidht = lineWidht
                rightProgress.lineColor = lineColor
                view.insertSubview(rightProgress, belowSubview: rightCursor)
            }
        }
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .beginFromCurrentState, animations: {(_: Void) -> Void in
            leftCursor.alpha = alpha
            leftProgress.alpha = alpha
            rightCursor.alpha = alpha
            rightProgress.alpha = alpha
        }, completion: {(_ finished: Bool) -> Void in
            if hide && removeVFS {
                selecting = false
                selectionProgress = 0.0
                self.updateProgress()
                leftCursor.removeFromSuperview()
                leftProgress.removeFromSuperview()
                rightCursor.removeFromSuperview()
                rightProgress.removeFromSuperview()
                leftCursor = nil
                leftProgress = nil
                rightCursor = nil
                rightProgress = nil
            }
        })
    }
}
 
 */
