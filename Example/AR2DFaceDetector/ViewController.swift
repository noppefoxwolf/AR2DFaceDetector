//
//  ViewController.swift
//  ARFaceLandmarks2D
//
//  Created by noppefoxwolf on 08/15/2019.
//  Copyright (c) 2019 noppefoxwolf. All rights reserved.
//

import UIKit
import ARKit
import AR2DFaceDetector

class ViewController: UIViewController, ARSCNViewDelegate {
  
  @IBOutlet weak var imageView: UIImageView!
  
  private let session = ARSession()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    session.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let configuration = ARFaceTrackingConfiguration()
    session.run(configuration)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    session.pause()
  }
}

extension ViewController: ARSessionDelegate {
  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    let detector = AR2DFaceDetector(frame: frame, orientation: .right)
    let size = detector.capturedImage.extent.size
    
    UIGraphicsBeginImageContext(size)
    let context = UIGraphicsGetCurrentContext()!
    UIImage(ciImage: detector.capturedImage).draw(at: .zero, blendMode: .overlay, alpha: 0.5)
    
    if let landmarks = detector.faces.first?.landmarks {
      
      context.setStrokeColor(UIColor.red.cgColor)
      context.addLines(between: landmarks.faceContour!.pointsInImage(imageSize: size))
      context.strokePath()
      
      context.setStrokeColor(UIColor.green.cgColor)
      context.addLines(between: landmarks.noseCrest!.pointsInImage(imageSize: size))
      context.strokePath()
      
      context.setStrokeColor(UIColor.blue.cgColor)
      context.addLines(between: landmarks.leftEye!.pointsInImage(imageSize: size))
      context.strokePath()
      
      context.setStrokeColor(UIColor.blue.cgColor)
      context.addLines(between: landmarks.rightEye!.pointsInImage(imageSize: size))
      context.strokePath()
      
      context.setStrokeColor(UIColor.blue.cgColor)
      context.addLines(between: landmarks.innerLips!.pointsInImage(imageSize: size))
      context.strokePath()
      
      context.setStrokeColor(UIColor.blue.cgColor)
      context.addLines(between: landmarks.outerLips!.pointsInImage(imageSize: size))
      context.strokePath()
    }
    
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    DispatchQueue.main.async {
      self.imageView.image = result
    }
  }
}
