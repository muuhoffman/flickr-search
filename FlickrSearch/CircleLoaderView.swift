//
//  CircleLoaderView.swift
//  FlickrSearch
//
//  Created by Matthew Hoffman on 6/24/17.
//  Copyright © 2017 Hoffware. All rights reserved.
//

import UIKit

class Circle {
    let circlePathLayer: CAShapeLayer
    let circleRadius: CGFloat
    
    init(circleRadius: CGFloat) {
        self.circlePathLayer = CAShapeLayer()
        self.circleRadius = circleRadius
    }
}

class CircleActivityIndicator: UIView {
    private var circle1: Circle!
    private var circle2: Circle!
    private var circle3: Circle!
    private var radius: CGFloat {
        get {
            return (self.frame.width < self.frame.height ? self.frame.width : self.frame.height)/2.0
        }
    }
    var isAnimating: Bool = false
    
    var color: UIColor? = UIColor.red {
        didSet {
            circle1.circlePathLayer.strokeColor = color?.cgColor
            circle2.circlePathLayer.strokeColor = color?.cgColor
            circle3.circlePathLayer.strokeColor = color?.cgColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isHidden = true
        circle1 = Circle(circleRadius: self.radius)
        circle2 = Circle(circleRadius: self.radius*0.85)
        circle3 = Circle(circleRadius: self.radius*0.70)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isHidden = true
        circle1 = Circle(circleRadius: self.radius)
        circle2 = Circle(circleRadius: self.radius*0.85)
        circle3 = Circle(circleRadius: self.radius*0.70)
        configure()
    }
    
    func configure() {
        backgroundColor = UIColor.clear
        updateCirclePathLayer(circle: circle1)
        layer.addSublayer(circle1.circlePathLayer)
        updateCirclePathLayer(circle: circle2)
        layer.addSublayer(circle2.circlePathLayer)
        updateCirclePathLayer(circle: circle3)
        layer.addSublayer(circle3.circlePathLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circle1.circlePathLayer.frame = bounds
        circle1.circlePathLayer.path = CircleActivityIndicator.circlePath(circle: circle1).cgPath
        
        circle2.circlePathLayer.frame = bounds
        circle2.circlePathLayer.path = CircleActivityIndicator.circlePath(circle: circle2).cgPath
        
        circle3.circlePathLayer.frame = bounds
        circle3.circlePathLayer.path = CircleActivityIndicator.circlePath(circle: circle3).cgPath
    }
    
    func startAnimating() {
        if !isAnimating {
            self.isAnimating = true
            self.isHidden = false
            circle1.circlePathLayer.add(getRotationAnimation(duration: 1.9), forKey: "rotate")
            circle2.circlePathLayer.add(getRotationAnimation(duration: 1.6), forKey: "rotate")
            circle3.circlePathLayer.add(getRotationAnimation(duration: 1.3), forKey: "rotate")
        }
    }
    
    func stopAnimating() {
        self.isHidden = true
        self.isAnimating = false
        circle1.circlePathLayer.removeAllAnimations()
        circle2.circlePathLayer.removeAllAnimations()
        circle3.circlePathLayer.removeAllAnimations()
    }
    
    private func updateCirclePathLayer(circle: Circle) {
        circle.circlePathLayer.frame = bounds
        circle.circlePathLayer.lineWidth = 3
        circle.circlePathLayer.fillColor = UIColor.clear.cgColor
        circle.circlePathLayer.strokeColor = self.color?.cgColor
        circle.circlePathLayer.strokeStart = 0
        circle.circlePathLayer.strokeEnd = 0.25
    }
    
    private func getRotationAnimation(duration: CFTimeInterval) -> CAAnimation {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.byValue = 2.0 * Float.pi
        animation.duration = duration
        animation.repeatCount = Float.infinity
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        return animation
    }
    
    private static func circleFrame(circle: Circle) -> CGRect {
        var circleFrame = CGRect(x: 0, y: 0, width: 2*circle.circleRadius, height: 2*circle.circleRadius)
        circleFrame.origin.x = circle.circlePathLayer.bounds.midX - circleFrame.midX
        circleFrame.origin.y = circle.circlePathLayer.bounds.midY - circleFrame.midY
        return circleFrame
    }
    
    private static func circlePath(circle: Circle) -> UIBezierPath {
        return UIBezierPath(ovalIn: circleFrame(circle: circle))
    }
}
