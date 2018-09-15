//
//  ToDoEmptyViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/5/21.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class ToDoEmptyViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "EMPTY"
        self.view.backgroundColor = BG_Color
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let lbl = UILabel()
        self.view.addSubview(lbl)
        lbl.numberOfLines = 0
        lbl.font = UIFont.systemFont(ofSize: 14.0)
        lbl.textColor = Text_Color
        lbl.text = "当前版本不支持此功能，尝试去App Store下载最新版本，如果还出现此页面则表示此功能开发中！"
        
        lbl.snp.makeConstraints { (make) in
            make.center.equalTo(self.view.snp.center)
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
