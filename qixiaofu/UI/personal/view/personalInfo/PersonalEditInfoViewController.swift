//
//  PersonalEditInfoViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/2/2.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class PersonalEditInfoViewController: BaseViewController {

    var textView = UITextView()
    
    var editDoneBlock : ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "擅长品牌"
        self.view.backgroundColor = BG_Color
        self.setUpTextView()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "确定", target: self, action: #selector(PersonalEditInfoViewController.makeSure))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpTextView() {
        self.view.addSubview(self.textView)
        self.textView.snp.makeConstraints { (make) in
            make.top.equalTo(15)
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
            make.height.equalTo(100)
        }
    }
    
    @objc func makeSure(){
        if self.editDoneBlock != nil && !self.textView.text.isEmpty{
            self.editDoneBlock!(self.textView.text)
            self.navigationController?.popViewController(animated: true)
        }else{
            LYProgressHUD.showError("不可为空！")
        }
    }

}
