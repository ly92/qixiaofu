//
//  WorkTrackViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/6/11.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class WorkTrackViewController: BaseViewController {

    
    //地图
    fileprivate var mapView: BMKMapView!
    fileprivate var polyLine : BMKPolyline?
    
    var startTime : UInt = 0
    var endTime : UInt = 0
    var engPhone = ""
    
    //记录轨迹点数组
    fileprivate var points : Array<JSON> = []
    fileprivate var page : UInt = 1

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "工作轨迹"
        
        //初始化地图
        self.initMapView()
        self.trackHistory()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "refresh"), target: self, action: #selector(WorkTrackViewController.rightItemAction))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mapView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.mapView.delegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func rightItemAction() {
        self.points.removeAll()
        self.page = 1
        self.trackHistory()
    }
    
    //请求一段时间内的轨迹
    @objc func trackHistory() {
        let sop = BTKServiceOption.init(ak: KBmapKey, mcode: "com.qixiaofu.7xf", serviceID: 201147, keepAlive: false)
        BTKAction.sharedInstance().initInfo(sop)
        let op = BTKStartServiceOption.init(entityName: LocalData.getUserPhone())
        BTKAction.sharedInstance().startService(op, delegate: self)
        let request = BTKQueryHistoryTrackRequest.init(entityName: self.engPhone, startTime: self.startTime, endTime: self.endTime, isProcessed: true, processOption: nil, supplementMode: BTKTrackProcessOptionSupplementMode.init(rawValue: 5)!, outputCoordType: BTKCoordType.init(rawValue: 3)!, sortType: BTKTrackSortType.init(rawValue: 2)!, pageIndex: 1, pageSize: 1000, serviceID: 201147, tag: 13)

//        let endTime = UInt(1528428860.4206362)
//        let request = BTKQueryHistoryTrackRequest.init(entityName: "勇", startTime: UInt(endTime - 86400), endTime: UInt(endTime), isProcessed: true, processOption: nil, supplementMode: BTKTrackProcessOptionSupplementMode.init(rawValue: 5)!, outputCoordType: BTKCoordType.init(rawValue: 3)!, sortType: BTKTrackSortType.init(rawValue: 2)!, pageIndex: self.page, pageSize: 1000, serviceID: 201147, tag: 13)
        BTKTrackAction.sharedInstance().queryHistoryTrack(with: request, delegate: self)
    }
}


extension WorkTrackViewController : BTKTrackDelegate{
    func onQueryHistoryTrack(_ response: Data!) {
        //查询到的轨迹点
        let json = try! JSON.init(data: response)
        if json["status"].stringValue.intValue == 0{
            for pointJson in json["points"].arrayValue{
                self.points.append(pointJson)
            }
            
            if json["total"].stringValue.intValue > json["size"].stringValue.intValue{
                self.page += 1
                self.trackHistory()
            }else{
                self.drawTrackPoints()
            }
        }else{
            LYProgressHUD.showError("未记录工程师的工作路径")
        }
        print(json)
        
    }
    
    
}


//MARK: - MAMapViewDelegate
extension WorkTrackViewController : BMKMapViewDelegate,BTKTraceDelegate{
    //初始化定位管理
    func initMapView() {
        self.mapView = BMKMapView(frame: self.view.bounds)
        self.mapView.showsUserLocation = true//是否显示用户位置
        self.mapView.showMapScaleBar = false// 不显示比例尺
        self.mapView.zoomLevel = 17.0// 地图缩放等级
        self.mapView.minZoomLevel = 3// 地图缩放等级
        self.mapView.maxZoomLevel = 25// 地图缩放等级
        self.mapView.userTrackingMode = BMKUserTrackingModeFollow
        
        self.view.addSubview(self.mapView)
    }
    
    //绘制轨迹
    func drawTrackPoints() {
        if self.polyLine != nil{
            DispatchQueue.main.async {
                self.mapView.remove(self.polyLine!)
            }
        }
        
        let count = self.points.count
        if count == 0{
            LYProgressHUD.showError("未记录工程师的工作路径")
        }else{
            LYProgressHUD.dismiss()
            let coor = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: count)
            var i = 0
            for pointJson in self.points{
                coor[i].latitude = pointJson["latitude"].stringValue.doubleValue
                coor[i].longitude = pointJson["longitude"].stringValue.doubleValue
                i += 1
            }
            self.polyLine = BMKPolyline.init(coordinates: coor, count: UInt(count))
            self.mapView.add(self.polyLine)
            self.mapViewFitPolyLine()
        }
    }
    
    func mapViewFitPolyLine(){
        var ltX : Double = 0
        var ltY : Double = 0
        var rbX : Double = 0
        var rbY : Double = 0
        if self.polyLine == nil{
            return
        }
        
        if self.polyLine!.pointCount < 1{
            return
        }
        
        let pt = self.polyLine!.points[0]
        ltX = pt.x
        ltY = pt.y
        rbX = pt.x
        rbY = pt.y
        for i in 0...self.polyLine!.pointCount - 1{
            let pt = self.polyLine!.points[Int(i)]
            if pt.x < ltX{
                ltX = pt.x
            }
            if pt.x > rbX{
                rbX = pt.x
            }
            if pt.y > ltY{
                ltY = pt.y
            }
            if pt.y < rbY{
                rbY = pt.y
            }
        }
        
        let rect = BMKMapRect.init(origin: BMKMapPoint.init(x: ltX, y: ltY), size: BMKMapSize.init(width: rbX-ltX, height: rbY-ltY))
        self.mapView.setVisibleMapRect(rect, animated: true)
        self.mapView.zoomLevel = self.mapView.zoomLevel - 0.3
    }
    
    
    
    func mapView(_ mapView: BMKMapView!, viewFor overlay: BMKOverlay!) -> BMKOverlayView! {
        if overlay.isKind(of: BMKPolyline.self){
            let polylineView = BMKPolylineView.init(overlay: overlay)
            polylineView?.lineWidth = 2
            polylineView?.strokeColor = Normal_Color
            return polylineView
        }
        return nil
    }
}
