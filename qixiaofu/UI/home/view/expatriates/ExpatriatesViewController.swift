//
//  ExpatriatesViewController.swift
//  qixiaofu
//   _
//  |.|      /\   /\
//  |.|      \ \_/ /
//  |.|       \_~_/
//  |.|        /.\
//  |.|__/\    [.]
//  |_|__,/    \_/
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
        subView.backgroundColor = UIColor.clear
        subView.clipsToBounds = true
        subView.layer.cornerRadius = 10
        self.view.addSubview(subView)
        
        //eng
        let engLbl = UILabel()
        engLbl.text = "我是工程师"
        engLbl.font = UIFont.systemFont(ofSize: 14.0)
        engLbl.textColor = UIColor.lightGray
        let engImgV = UIImageView()
        engImgV.image = UIImage.init(named: "job_icon_1")
        let engBtn = UIButton.init(type: .custom)
        engBtn.setTitle("找工作", for: .normal)
        engBtn.backgroundColor = UIColor.RGB(r: 247, g: 141, b: 63)
        engBtn.clipsToBounds = true
        engBtn.layer.cornerRadius = 20
        engBtn.addTarget(self, action: #selector(ExpatriatesViewController.toFindJob), for: .touchUpInside)
        subView.addSubview(engLbl)
        subView.addSubview(engImgV)
        subView.addSubview(engBtn)
        
        //招聘方
        let cusLbl = UILabel()
        cusLbl.text = "我是需求方"
        cusLbl.font = UIFont.systemFont(ofSize: 14.0)
        cusLbl.textColor = UIColor.lightGray
        let cusImgV = UIImageView()
        cusImgV.image = UIImage.init(named: "job_icon_2")
        let cusBtn = UIButton.init(type: .custom)
        cusBtn.setTitle("找工程师", for: .normal)
        cusBtn.backgroundColor = Normal_Color
        cusBtn.clipsToBounds = true
        cusBtn.layer.cornerRadius = 20
        cusBtn.addTarget(self, action: #selector(ExpatriatesViewController.toFindEng), for: .touchUpInside)
        subView.addSubview(cusLbl)
        subView.addSubview(cusImgV)
        subView.addSubview(cusBtn)
        
        //snp
        subView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.view.snp.centerY).offset(-80)
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(250)
            make.height.equalTo(350)
        }
        
        engImgV.snp.makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.top.equalTo(40)
            make.centerX.equalTo(subView.snp.centerX)
        }
        engLbl.snp.makeConstraints { (make) in
            make.top.equalTo(engImgV.snp.bottom).offset(5)
            make.centerX.equalTo(subView.snp.centerX)
            make.height.equalTo(20)
        }
        engBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.top.equalTo(engLbl.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        
        cusImgV.snp.makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.top.equalTo(engBtn.snp.bottom).offset(40)
            make.centerX.equalTo(subView.snp.centerX)
        }
        cusLbl.snp.makeConstraints { (make) in
            make.centerX.equalTo(subView.snp.centerX)
            make.top.equalTo(cusImgV.snp.bottom).offset(5)
        }
        cusBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.top.equalTo(cusLbl.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        
        
    }
    
    
    @objc func toFindEng(){
        let jobList = JobListViewController.spwan()
        jobList.isEng = false
        self.navigationController?.pushViewController(jobList, animated: true)
    }
    
    @objc func toFindJob(){
        let jobList = JobListViewController.spwan()
        jobList.isEng = true
        self.navigationController?.pushViewController(jobList, animated: true)
    }

}
