//
//  TagAnnotation.swift
//  qixiaofu
//
//  Created by ly on 2017/7/13.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class TagAnnotation: BMKShape {
    ///经纬度
    override var coordinate : CLLocationCoordinate2D{
        get{
            let coor = CLLocationCoordinate2D.init(latitude: self.latitude, longitude: self.longitude)
            return coor
        }
    }
    
    ///是否固定在屏幕一点, 注意，拖动或者手动改变经纬度，都会导致设置失效
    let lockedToScreen = false
    
    ///固定屏幕点的坐标
    let lockedScreenPoint : CGPoint = CGPoint.zero
    
    
    var tag : NSInteger = 0
    var latitude : CLLocationDegrees = 0
    var longitude : CLLocationDegrees = 0
    
    override init() {
        self.latitude = 0
        self.longitude = 0
        super.init()
    }
    
    init(latitude:CLLocationDegrees,longitude:CLLocationDegrees) {
        self.latitude = latitude
        self.longitude = longitude
        super.init()
    }
    

}
