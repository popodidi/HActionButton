//
//  CGPoint.swift
//  Pods
//
//  Created by Chang, Hao on 9/2/16.
//
//

import Foundation

extension CGPoint{
    func from(point: CGPoint) -> CGPoint{
        return CGPoint(x: x + point.x, y: y + point.y)
    }
}