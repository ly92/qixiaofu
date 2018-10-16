//
//  ExpatriatesViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/10/16.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class ExpatriatesViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "驻场招聘"
        self.prepareMainUI()
    }
    

    func prepareMainUI(){
        
        self.view.backgroundColor = BG_Color
        
        //subview
        let subView = UIView()
        subView.backgroundColor = UIColor.white
        subView.clipsToBounds = true
        subView.layer.cornerRadius = 10
        self.view.addSubview(subView)
        
        //eng
        let engLbl = UILabel()
        engLbl.text = "我是工程师"
        engLbl.font = UIFont.systemFont(ofSize: 14.0)
        engLbl.textColor = UIColor.lightGray
//        let engImgV = UIImageView()
//        engImgV.image = UIImage.init(named: "head_placeholder")
        let engBtn = UIButton.init(type: .custom)
        engBtn.setTitle("找工作", for: .normal)
        engBtn.backgroundColor = Normal_Color
        engBtn.clipsToBounds = true
        engBtn.layer.cornerRadius = 5
        engBtn.addTarget(self, action: #selector(ExpatriatesViewController.toFindJob), for: .touchUpInside)
        subView.addSubview(engLbl)
//        subView.addSubview(engImgV)
        subView.addSubview(engBtn)
        
        //招聘方
        let cusLbl = UILabel()
        cusLbl.text = "我是需求方"
        cusLbl.font = UIFont.systemFont(ofSize: 14.0)
        cusLbl.textColor = UIColor.lightGray
//        let cusImgV = UIImageView()
//        cusImgV.image = UIImage.init(named: "head_placeholder")
        let cusBtn = UIButton.init(type: .custom)
        cusBtn.setTitle("找工程师", for: .normal)
        cusBtn.backgroundColor = Normal_Color
        cusBtn.clipsToBounds = true
        cusBtn.layer.cornerRadius = 5
        cusBtn.addTarget(self, action: #selector(ExpatriatesViewController.toFindEng), for: .touchUpInside)
        subView.addSubview(cusLbl)
//        subView.addSubview(cusImgV)
        subView.addSubview(cusBtn)
        
        //snp
        subView.snp.makeConstraints { (make) in
            make.center.equalTo(self.view.snp.center)
            make.width.equalTo(200)
            make.height.equalTo(250)
        }
        
        engLbl.snp.makeConstraints { (make) in
            make.top.equalTo(40)
            make.leading.equalTo(20)
            make.width.equalTo(120)
            make.height.equalTo(20)
        }
//        engImgV.snp.makeConstraints { (make) in
//            make.width.height.equalTo(30)
//            make.leading.equalTo(engLbl.snp.trailing).offset(5)
//            make.centerY.equalTo(engLbl.snp.centerY)
//        }
        engBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.top.equalTo(engLbl.snp.bottom).offset(10)
            make.height.equalTo(30)
        }
        
        cusLbl.snp.makeConstraints { (make) in
            make.leading.equalTo(20)
            make.width.equalTo(120)
            make.top.equalTo(engBtn.snp.bottom).offset(40)
        }
//        cusImgV.snp.makeConstraints { (make) in
//            make.width.height.equalTo(30)
//            make.centerY.equalTo(cusLbl.snp.centerY)
//            make.leading.equalTo(cusLbl.snp.trailing).offset(5)
//        }
        cusBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.top.equalTo(cusLbl.snp.bottom).offset(10)
            make.height.equalTo(30)
        }
        
        
    }
    
    
    @objc func toFindEng(){
        
        
    }
    
    @objc func toFindJob(){
        
    }

}
