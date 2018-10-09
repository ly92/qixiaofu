//
//  MapMatchEngineerViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/7/10.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class MapMatchEngineerViewController: BaseViewController {
    var selectedLocation : ((BMKPoiInfo) -> Void)?
    
    //上个页面加载到的工程师列表
    var engListArray : Array<JSON> = Array<JSON>()
    
    fileprivate var engCountDict : Dictionary<String,String> = [:]
    
    //定位
    fileprivate var locationService = BMKLocationService()
    //记录当前位置
    fileprivate var location : BMKUserLocation?
    fileprivate var localAnno  = BMKPointAnnotation()
    
    //地图
    fileprivate var mapView: BMKMapView!
    

    fileprivate var shouldBeCenter : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //导航栏
        self.navigationItem.title = "工程师分布"
        //初始化地图
        self.initMapView()
        //初始化定位管理
        self.initLocalManager()
        //当前位置设为中心
        self.setUserLocationCenter()
        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mapView.delegate = self
        self.locationService.delegate = self
        
        self.addAnnotations()       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.mapView.delegate = nil
        self.locationService.delegate = nil
    }
    
    func addAnnotations() {
        self.engCountDict.removeAll()
        if self.engListArray.count > 0{
            var annoArr : Array<TagAnnotation> = []
            for i in 0...self.engListArray.count - 1 {
                let subJson = self.engListArray[i]
                var anno = TagAnnotation()
                let lat = subJson["lat"].stringValue.doubleValue
                let lon = subJson["lng"].stringValue.doubleValue
                anno = TagAnnotation.init(latitude: lat, longitude: lon)
                anno.tag = i
                if self.engCountDict.keys.contains(subJson["member_id"].stringValue){
                    let count = self.engCountDict[subJson["member_id"].stringValue]!.intValue + 1
                    self.engCountDict[subJson["member_id"].stringValue] = String.init(format: "%d", count)
                }else{
                    self.engCountDict[subJson["member_id"].stringValue] = "1"
                    annoArr.append(anno)
                }
            }
            mapView.addAnnotations(annoArr)
            mapView.showAnnotations(mapView.annotations, animated: true)
            self.mapView.zoomLevel = self.mapView.zoomLevel - 0.3
        }else{
            self.shouldBeCenter = true
            self.startLocal()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    //回归到当前位置
    func setUserLocationCenter() {
        let btn = UIButton(frame: CGRect.init(x: kScreenW - 37, y: 30, width: 30, height: 30))
        btn.setImage(#imageLiteral(resourceName: "map_location_n"), for: .normal)
        btn.setImage(#imageLiteral(resourceName: "map_location_s"), for: .highlighted)
        btn.addTapActionBlock {
            self.shouldBeCenter = true
            self.startLocal()
        }
        self.view.addSubview(btn)
    }
    
}

//MARK: - BMKLocationServiceDelegate
extension MapMatchEngineerViewController : BMKLocationServiceDelegate{
    //初始化定位管理
    func initLocalManager(){
        self.locationService.startUserLocationService()
    }
    func startLocal() {
        self.locationService.startUserLocationService()
    }
    
    func didUpdate(_ userLocation: BMKUserLocation!) {
        if self.location != nil{
            self.mapView.removeAnnotation(self.localAnno)
        }
        self.location = userLocation
        //添加位置
        self.localAnno.coordinate = userLocation.location.coordinate
        self.mapView.addAnnotation(self.localAnno)
        
        //置中当前位置
        if shouldBeCenter{
            self.shouldBeCenter = false
            self.mapView.setCenter(userLocation.location.coordinate, animated: true)
        }
        //停止定位
        self.locationService.stopUserLocationService()
    }
    
    func didFailToLocateUserWithError(_ error: Error!) {
        LYAlertView.show("提示", "请检查网络或者定位服务是否开启", "取消", "去设置", {
            //打开设置页面
            let url = URL(string:UIApplicationOpenSettingsURLString)
            if UIApplication.shared.canOpenURL(url!){
                UIApplication.shared.openURL(url!)
            }
        })
    }
    
    
}

//MARK: - MAMapViewDelegate
extension MapMatchEngineerViewController : BMKMapViewDelegate{
    //初始化定位管理
    func initMapView() {
        mapView = BMKMapView(frame: self.view.bounds)
        mapView.showsUserLocation = true//是否显示用户位置
        mapView.showMapScaleBar = false// 不显示比例尺
        mapView.zoomLevel = 13.0// 地图缩放等级
        mapView.minZoomLevel = 3// 地图缩放等级
        mapView.maxZoomLevel = 20// 地图缩放等级
        mapView.userTrackingMode = BMKUserTrackingModeNone
        
        self.view.addSubview(mapView)
    }
    
    //自定义大头针
    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        if annotation.isKind(of: TagAnnotation.self){
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: BMKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as! BMKPinAnnotationView?
            if annotationView == nil {
                annotationView = BMKPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            annotationView?.image = #imageLiteral(resourceName: "map_annotation")
            annotationView!.canShowCallout = true
            annotationView!.animatesDrop = false
            annotationView!.isDraggable = true
            let anno = annotation as! TagAnnotation
            let subJson = self.engListArray[anno.tag]
            var title = subJson["call_nik_name"].stringValue
            let countStr = self.engCountDict[subJson["member_id"].stringValue]
            if countStr != nil{
                title = subJson["call_nik_name"].stringValue + "(" + self.engCountDict[subJson["member_id"].stringValue]! + ")"//持有量
            }
            let popView = self.getPaoPaoView(icon: subJson["member_avatar"].stringValue, title: title)
            annotationView!.paopaoView = BMKActionPaopaoView.init(customView: popView)
            return annotationView!
        }else{
            let pointReuseIndetifier = "BMKAnnotationView"
            var annotationView: BMKAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as BMKAnnotationView?
            if annotationView == nil {
                annotationView = BMKAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            annotationView!.image = #imageLiteral(resourceName: "my_location")
            annotationView!.canShowCallout = true
            let lbl = UILabel(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 100, height: 40)))
            lbl.clipsToBounds = true
            lbl.layer.cornerRadius = 5
            lbl.backgroundColor = UIColor.white
            lbl.text = "我的位置"
            lbl.font = UIFont.systemFont(ofSize: 14.0)
            lbl.textColor = Text_Color
            lbl.textAlignment = .center
            annotationView!.paopaoView = BMKActionPaopaoView.init(customView: lbl)
            return annotationView!
        }
    }
    
    
    func mapView(_ mapView: BMKMapView!, annotationViewForBubble view: BMKAnnotationView!) {
        if view.isKind(of: BMKPinAnnotationView.self){
            //登录环信
            esmobLogin()
            let anno = view.annotation as! TagAnnotation
            let subJson = self.engListArray[anno.tag]
            let chatVC = EaseMessageViewController.init(conversationChatter: subJson["call_name"].stringValue, conversationType: EMConversationType.init(0))
            //保存聊天页面数据
            LocalData.saveChatUserInfo(name: subJson["call_nik_name"].stringValue, icon: subJson["duifangtouxiang"].stringValue, key: subJson["call_name"].stringValue)
            chatVC?.title = subJson["call_nik_name"].stringValue
            self.navigationController?.pushViewController(chatVC!, animated: true)
        }
    }
    
    func getPaoPaoView(icon:String, title:String) -> UIView {
        let titleW = title.sizeFit(width: CGFloat(MAXFLOAT), height: 17, fontSize: 14.5).width
        var viewW : CGFloat = 250
        if titleW < 160{
            viewW = titleW + 90
        }
        let paoPaoView = UIView(frame:CGRect.init(x: 0, y: 0, width: viewW, height: 40))
        paoPaoView.backgroundColor = UIColor.white
        paoPaoView.layer.cornerRadius = 3
        
        let imgV = UIImageView(frame:CGRect.init(x: 5, y: 5, width: 30, height: 30))
        imgV.clipsToBounds = true
        imgV.layer.cornerRadius = 15
        imgV.setImageUrlStrAndPlaceholderImg(icon, #imageLiteral(resourceName: "head_placeholder"))
        
        let lbl = UILabel(frame:CGRect.init(x: 35, y: 5, width: viewW - 70, height: 30))
        lbl.font = UIFont.systemFont(ofSize: 14.0)
        lbl.minimumScaleFactor = 0.7
        lbl.textColor = Text_Color
        lbl.text = title
        lbl.numberOfLines = 0
        let chatImgV = UIImageView(frame:CGRect.init(x: viewW - 35, y: 5, width: 30, height: 30))
        chatImgV.clipsToBounds = true
        chatImgV.layer.cornerRadius = 15
        chatImgV.image = #imageLiteral(resourceName: "icon_chat_n")
        
        paoPaoView.addSubview(imgV)
        paoPaoView.addSubview(lbl)
        paoPaoView.addSubview(chatImgV)
        
        return paoPaoView
    }
    
}

