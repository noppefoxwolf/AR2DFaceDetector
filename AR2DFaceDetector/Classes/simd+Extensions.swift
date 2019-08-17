//
//  simd+Extensions.swift
//  AR2DFaceDetector
//
//  Created by beta on 2019/08/17.
//

import UIKit

extension SIMD3 {
  var xy: SIMD2<Scalar> {
    return SIMD2(x: x, y: y)
  }
}


