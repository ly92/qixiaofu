//
//  HomeOrderViewModel.swift
//  qixiaofu
//
//  Created by ly on 2017/6/21.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class HomeOrderViewModel: NSObject {
    class func loadHomeMainData( block: @escaping((_ json : JSON)->Swift.Void)) {
        NetTools.requestData(type: .post, urlString: HomeMainApi, succeed: { (resultDict, error) in
            block(resultDict)
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    
}

/**
 {
 "listData" : {
 "class_list" : [
 {
 "gc_id" : "2",
 "gc_name" : "UNIX服务器",
 "gc_image" : "http:\/\/10.216.2.11\/var\/upload\/pic\/2017\/03\/20170307093502_20215.png"
 },
 {
 "gc_id" : "4",
 "gc_name" : "X86服务器",
 "gc_image" : "http:\/\/10.216.2.11\/var\/upload\/pic\/2017\/03\/20170306101416_95056.png"
 },
 {
 "gc_id" : "5",
 "gc_name" : "存储设备",
 "gc_image" : "http:\/\/10.216.2.11\/var\/upload\/pic\/2017\/03\/20170306101525_60125.png"
 },
 {
 "gc_id" : "6",
 "gc_name" : "网络交换设备",
 "gc_image" : "http:\/\/10.216.2.11\/var\/upload\/pic\/2017\/03\/20170306101629_81457.png"
 },
 {
 "gc_id" : "7",
 "gc_name" : "监控设备",
 "gc_image" : "http:\/\/10.216.2.11\/var\/upload\/pic\/2017\/03\/20170306101653_82208.png"
 },
 {
 "gc_id" : "8",
 "gc_name" : "虚拟化",
 "gc_image" : "http:\/\/10.216.2.11\/var\/upload\/pic\/2017\/03\/20170307093534_76905.png"
 },
 {
 "gc_id" : "9",
 "gc_name" : "桌面设备",
 "gc_image" : "http:\/\/10.216.2.11\/var\/upload\/pic\/2017\/03\/20170307093550_46271.png"
 },
 {
 "gc_id" : "10",
 "gc_name" : "数据库",
 "gc_image" : "http:\/\/10.216.2.11\/var\/upload\/pic\/2017\/03\/20170307093605_66340.png"
 },
 {
 "gc_id" : "11",
 "gc_name" : "安全设备",
 "gc_image" : "http:\/\/10.216.2.11\/var\/upload\/pic\/2017\/03\/20170307093704_31097.png"
 },
 {
 "gc_id" : "12",
 "gc_name" : "其他设备",
 "gc_image" : "http:\/\/10.216.2.11\/var\/upload\/pic\/2017\/03\/20170307093735_73137.png"
 }
 ],
 "bill_list" : [
 {
 "title" : "UNIX服务器,X86服务器,监控设备,虚拟化",
 "id" : "603"
 },
 {
 "title" : "UNIX服务器,X86服务器,存储设备,网络交换设备,监控设备,虚拟化",
 "id" : "601"
 },
 {
 "title" : "UNIX服务器,X86服务器,存储设备,监控设备,数据库",
 "id" : "600"
 },
 {
 "title" : "数据库-测试",
 "id" : "565"
 },
 {
 "title" : "数据库-测试",
 "id" : "564"
 },
 {
 "title" : "数据库-贵阳",
 "id" : "554"
 }
 ],
 "member_list" : [
 {
 "title" : "雪姨",
 "id" : "967"
 },
 {
 "title" : "于青林",
 "id" : "974"
 },
 {
 "title" : "张增亮",
 "id" : "975"
 },
 {
 "title" : "测试",
 "id" : "995"
 }
 ],
 "eng_banner_list" : [
 "http:\/\/10.216.2.11\/UPLOAD\/sys\/2017-03-07\/~UPLOAD~sys~2017-03-07@1488850751.jpg",
 "http:\/\/10.216.2.11\/UPLOAD\/sys\/2017-03-07\/~UPLOAD~sys~2017-03-07@1488850772.jpg",
 "http:\/\/10.216.2.11\/UPLOAD\/sys\/2017-03-07\/~UPLOAD~sys~2017-03-07@1488850793.jpg"
 ],
 "banner_list" : [
 "http:\/\/10.216.2.11\/UPLOAD\/sys\/2017-03-07\/~UPLOAD~sys~2017-03-07@1488850694.jpg",
 "http:\/\/10.216.2.11\/UPLOAD\/sys\/2017-03-07\/~UPLOAD~sys~2017-03-07@1488850713.jpg",
 "http:\/\/10.216.2.11\/UPLOAD\/sys\/2017-03-07\/~UPLOAD~sys~2017-03-07@1488850724.jpg"
 ]
 },
 "repMsg" : "",
 "repCode" : "00"
 }

 */
