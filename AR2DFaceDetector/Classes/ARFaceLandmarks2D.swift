//
//  ARLandmark.swift
//  ARKit-Render
//
//  Created by beta on 2019/08/11.
//  Copyright © 2019 Tomoya Hirano. All rights reserved.
//

import UIKit
import ARKit

public class AR2DFaceDetector {
  public let capturedImage: CIImage
  public let faces: [ARFace]
  
  public init(frame: ARFrame, orientation: CGImagePropertyOrientation = CGImagePropertyOrientation.up) {
    capturedImage = CIImage(cvPixelBuffer: frame.capturedImage).oriented(orientation)
    faces = frame.anchors.compactMap({ $0 as? ARFaceAnchor }).map({ ARFace(faceAnchor: $0, camera: frame.camera, orientation: orientation) })
  }
}

public class ARFace {
  public let landmarks: ARFaceLandmarks2D?
  public let perspectivePoints: ARPerspectivePoints2D?
  
  init(faceAnchor: ARFaceAnchor,
       camera: ARCamera,
       orientation: CGImagePropertyOrientation) {
    landmarks = ARFaceLandmarks2D(faceAnchor: faceAnchor, camera: camera, orientation: orientation)
    perspectivePoints = ARPerspectivePoints2D(landmarks: landmarks)
  }
}

public class ARPerspectivePoints2D {
  public let topLeft: ARPerspectiveRegion2D
  public let topRight: ARPerspectiveRegion2D
  public let bottomRight: ARPerspectiveRegion2D
  public let bottomLeft: ARPerspectiveRegion2D
  
  init?(landmarks: ARFaceLandmarks2D?) {
    if let allPoints = landmarks?.allPoints {
      // ここの計算は適当、横顔とかに弱い
      // 20
      // 1023 13 1029
      // 1047
      let rightTranslationMatrix = allPoints.normalizedPoints[1029].simd - allPoints.normalizedPoints[13].simd
      let leftTranslationMatrix = allPoints.normalizedPoints[1023].simd - allPoints.normalizedPoints[13].simd
      
      topLeft = ARPerspectiveRegion2D(point: (allPoints.normalizedPoints[20].simd + leftTranslationMatrix).point)
      topRight = ARPerspectiveRegion2D(point: (allPoints.normalizedPoints[20].simd + rightTranslationMatrix).point)
      bottomRight = ARPerspectiveRegion2D(point: (allPoints.normalizedPoints[1047].simd + rightTranslationMatrix).point)
      bottomLeft = ARPerspectiveRegion2D(point: (allPoints.normalizedPoints[1047].simd + leftTranslationMatrix).point)
    } else {
      return nil
    }
  }
}

public class ARPerspectiveRegion2D {
  public let point: CGPoint
  
  init(point: CGPoint) {
    self.point = point
  }
  
  func pointInImage(imageSize: CGSize) -> CGPoint {
    return point.applying(.init(scaleX: imageSize.width, y: imageSize.height))
  }
}

public class ARFaceLandmarks2D {
  let textureCoordinates: [simd_float2]
  let orientation: CGImagePropertyOrientation
  
  init?(faceAnchor: ARFaceAnchor, camera: ARCamera, orientation: CGImagePropertyOrientation) {
    guard faceAnchor.isTracked else { return nil }
    let geometry = faceAnchor.geometry
    let vertices = geometry.vertices
    let size = camera.imageResolution
    let viewportSize = CGSize(width: size.height, height: size.width)
    let modelMatrix = faceAnchor.transform
    // https://stackoverflow.com/a/53255370/1131587
    textureCoordinates = vertices.lazy.map { (vertex) -> simd_float2 in
      let vertex4 = simd_float4(vertex.x, vertex.y, vertex.z, 1)
      let world_vertex4 = simd_mul(modelMatrix, vertex4)
      let world_vector3 = simd_float3(x: world_vertex4.x, y: world_vertex4.y, z: world_vertex4.z)
      let pt = camera.projectPoint(world_vector3, orientation: .portrait, viewportSize: viewportSize)
      let v = Float(pt.x) / Float(size.height)
      let u = Float(pt.y) / Float(size.width)
      let normalizedPoints = simd_float2(u, v)
      
      // ARKit default mirrored
      
      
      switch orientation {
      case .up:
        let flipMatrix = simd_float3x3(rows: [
          .init(x: 1, y: 0, z: 0),
          .init(x: 0, y: -1, z: 1),
          .init(x: 0, y: 0, z: 1),
          ])
        let flipped = simd_mul(flipMatrix, simd_float3(normalizedPoints.x, normalizedPoints.y, 1))
        return simd_float2(x: flipped.x, y: flipped.y)
        //return simd_float2(normalizedPoints.x * 2, 1.0) - normalizedPoints
      case .right:
        let flipMatrix = simd_float3x3(rows: [
          .init(x: -1, y: 0, z: 1),
          .init(x: 0, y: 1, z: 0),
          .init(x: 0, y: 0, z: 1),
        ])
        let θ: Float = .pi / 2.0 //90
        let orientationMatrix = simd_float2x2(float2(x: cos(θ), y: sin(θ)), float2(x: -sin(θ), y: cos(θ)))
        let normalizedPoints = simd_mul(orientationMatrix, normalizedPoints) + simd_float2(1.0, 0.0)
        let flipped = simd_mul(flipMatrix, simd_float3(normalizedPoints.x, normalizedPoints.y, 1))
        return simd_float2(x: flipped.x, y: flipped.y)
      default:
        preconditionFailure("not supported")
      }
    }
    self.orientation = orientation
  }
  
  open var allPoints: ARFaceLandmarkRegion2D? {
    return ARFaceLandmarkRegion2D(normalizedPoints: textureCoordinates)
  }
  
  open var faceContour: ARFaceLandmarkRegion2D? {
    let indices: [Int] = [
      940, 939, 938, 937, 936, 935, 934, 933, 932, 989, 988, 987, 986, 985, 984,
      1049,
      983, 982, 944, 992, 991, 990, 1007, 1006, 1005, 1004, 1003, 1002, 1001, 1000, 999
    ]
    return ARFaceLandmarkRegion2D(normalizedPoints: indices.compactMap({ textureCoordinates[$0] }))

  }
  
  open var leftEye: ARFaceLandmarkRegion2D? {
    let indices: [Int] = (1181...1204).map({ $0 })
    return ARFaceLandmarkRegion2D(normalizedPoints: indices.compactMap({ textureCoordinates[$0] }))
  }
  
  open var rightEye: ARFaceLandmarkRegion2D? {
    let indices: [Int] = (1061...1084).map({ $0 })
    return ARFaceLandmarkRegion2D(normalizedPoints: indices.compactMap({ textureCoordinates[$0] }))
  }
  
  open var leftEyebrow: ARFaceLandmarkRegion2D? {
    return nil
  }
  
  open var rightEyebrow: ARFaceLandmarkRegion2D? {
    return nil
  }
  
  open var nose: ARFaceLandmarkRegion2D? {
    return ARFaceLandmarkRegion2D(normalizedPoints: [textureCoordinates[8]] )
  }
  
  open var noseCrest: ARFaceLandmarkRegion2D? {
    let indices: [Int] = [15, 14, 13, 12, 11, 10, 9, 8]
    return ARFaceLandmarkRegion2D(normalizedPoints: indices.compactMap({ textureCoordinates[$0] }))
    // 15 ~ 8
  }
  
  open var medianLine: ARFaceLandmarkRegion2D? {
    return nil
  }
  
  open var outerLips: ARFaceLandmarkRegion2D? {
    let indices: [Int] = [1, 90, 91, 98, 99, 100, 102, 185, 190, 120, 122, 278, 272, 263, 27, 698, 707, 723, 712, 681, 680, 679, 678, 551, 549, 548, 547, 540, 539]
    return ARFaceLandmarkRegion2D(normalizedPoints: indices.compactMap({ textureCoordinates[$0] }))
  }
  
  open var innerLips: ARFaceLandmarkRegion2D? {
    let indices: [Int] = [23, 93, 95, 97, 105, 106, 187, 189, 248, 247, 275, 290, 274, 265, 25, 700, 709, 725, 725, 710, 682, 683, 740, 684, 685, 686, 687, 688, 689, 690, 691]
    return ARFaceLandmarkRegion2D(normalizedPoints: indices.compactMap({ textureCoordinates[$0] }))
  }
  
  open var leftPupil: ARFaceLandmarkRegion2D? {
    return nil
  }
  
  open var rightPupil: ARFaceLandmarkRegion2D? {
    return nil
  }
}

import Vision

public class ARFaceLandmarkRegion2D {
  public let normalizedPoints: [CGPoint]
  
  init(normalizedPoints: [simd_float2]) {
    self.normalizedPoints = normalizedPoints.lazy.map({ CGPoint(x: CGFloat($0.x), y: CGFloat($0.y)) })
  }
  
  public func pointsInImage(imageSize: CGSize) -> [CGPoint] {
    return normalizedPoints.lazy.map({ $0.applying(.init(scaleX: imageSize.width, y: imageSize.height)) })
  }
}
