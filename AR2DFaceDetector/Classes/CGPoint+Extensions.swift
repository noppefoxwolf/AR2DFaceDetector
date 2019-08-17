//
//  CGPoint+Extensions.swift
//  ARFaceLandmarks2D
//
//  Created by beta on 2019/08/17.
//

import CoreGraphics
import simd

extension CGPoint {
  var simd: simd_float2 {
    return simd_float2(x: Float(x), y: Float(y))
  }
}

extension simd_float2 {
  var point: CGPoint {
    return CGPoint(x: CGFloat(x), y: CGFloat(y))
  }
}
