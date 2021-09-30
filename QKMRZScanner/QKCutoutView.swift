//
//  QKCutoutView.swift
//  QKMRZScanner
//
//  Created by Matej Dorcak on 05/10/2018.
//

import UIKit

public class QKCutoutView: UIView {
    fileprivate(set) var cutoutRect: CGRect!
    
    public var progress: CGFloat = 0 {
      didSet {
        layer.sublayers?.removeAll()
        drawRectangleCutout(progress)
      }
    }
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.45)
        contentMode = .redraw // Redraws everytime the bounds (orientation) changes
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        cutoutRect = calculateCutoutRect() // Orientation or the view's size could change
        layer.sublayers?.removeAll()
        drawRectangleCutout()
    }
    
    // MARK: Misc
    fileprivate func drawRectangleCutout() {
        guard let cutoutRect = cutoutRect else {
          return
        }
        let maskLayer = CAShapeLayer()
        let path = CGMutablePath()
        let cornerRadius = CGFloat(3)
        
        path.addRoundedRect(in: cutoutRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
        path.addRect(bounds)
        
        maskLayer.path = path
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        
        layer.mask = maskLayer
        
        // Add border around the cutout
        layer.drawTarget(
          bounds: cutoutRect,
          color: .systemGreen,
          width: 12.0,
          percentage: progress
        )
    }
    
    fileprivate func calculateCutoutRect() -> CGRect {
        let documentFrameRatio = CGFloat(1.42) // Passport's size (ISO/IEC 7810 ID-3) is 125mm × 88mm
        let (width, height): (CGFloat, CGFloat)
        
        if bounds.height > bounds.width {
            width = (bounds.width * 0.9) // Fill 90% of the width
            height = (width / documentFrameRatio)
        }
        else {
            height = (bounds.height * 0.75) // Fill 75% of the height
            width = (height * documentFrameRatio)
        }
        
        let topOffset = (bounds.height - height) / 2
        let leftOffset = (bounds.width - width) / 2
        
        return CGRect(x: leftOffset, y: topOffset, width: width, height: height)
    }
}

extension CALayer {
  func drawTarget(
    bounds: CGRect,
    color: UIColor = .green,
    width: CGFloat = 12,
    percentage: CGFloat = 0
  ) {
    let targetLength: CGFloat = 60
    let padding: CGFloat = 6
    
    let targetPath = CGMutablePath()
    let point0 = CGPoint.zero
    let point1 = CGPoint(x: 0, y: targetLength)
    let point2 = CGPoint(x: 0, y: bounds.height - targetLength)
    let point3 = CGPoint(x: 0, y: bounds.height)
    let point4 = CGPoint(x: targetLength, y: bounds.height)
    let point5 = CGPoint(x: bounds.width - targetLength, y: bounds.height)
    let point6 = CGPoint(x: bounds.width, y: bounds.height)
    let point7 = CGPoint(x: bounds.width, y: bounds.height - targetLength)
    let point8 = CGPoint(x: bounds.width, y: targetLength)
    let point9 = CGPoint(x: bounds.width, y: 0)
    let point10 = CGPoint(x: bounds.width - targetLength, y: 0)
    let point11 = CGPoint(x: targetLength, y: 0)
    
    targetPath.addLines(between: [point0, point1])
    if percentage > 0.8 {
      targetPath.addLines(between: [point1, point2])
    }
    targetPath.addLines(between: [point2, point3])
    targetPath.addLines(between: [point3, point4])
    if percentage > 0.6 {
      targetPath.addLines(between: [point4, point5])
    }
    targetPath.addLines(between: [point5, point6])
    targetPath.addLines(between: [point6, point7])
    if percentage > 0.4 {
      targetPath.addLines(between: [point7, point8])
    }
    targetPath.addLines(between: [point8, point9])
    targetPath.addLines(between: [point9, point10])
    if percentage > 0.2 {
      targetPath.addLines(between: [point10, point11])
    }
    targetPath.addLines(between: [point11, point0])
    
    let targetLayer = CAShapeLayer()
    targetLayer.lineCap = .round
    targetLayer.lineJoin = .round
    targetLayer.strokeColor = color.cgColor
    targetLayer.lineWidth = width
    targetLayer.path = targetPath
    
    let rectLayerName = "rectLayer"
    let rectLayer = CAShapeLayer()
    rectLayer.name = rectLayerName
    rectLayer.fillColor = UIColor.white.withAlphaComponent(0.3).cgColor
    let rectPath = CGMutablePath()
    let rect = CGRect(
      x: padding,
      y: padding,
      width: bounds.width - 2 * padding,
      height: bounds.height - 2 * padding
    )
    rectPath.addRect(rect)
    rectLayer.path = rectPath
    rectLayer.addSublayer(targetLayer)
    rectLayer.frame = bounds

    sublayers?.first(where: {
      $0.name == rectLayerName
    })?.removeFromSuperlayer()
    addSublayer(rectLayer)
  }
}
