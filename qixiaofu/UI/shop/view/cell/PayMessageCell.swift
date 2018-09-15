//
//  PayMessageCell.swift
//  qixiaofu
//
//  Created by ly on 2018/4/4.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class PayMessageCell: UITableViewCell {
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var placeholderLbl: UILabel!
    
    var payMessageBlock : ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension PayMessageCell : UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.placeholderLbl.isHidden = true
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty{
            self.placeholderLbl.isHidden = false
        }
        if self.payMessageBlock != nil{
            self.payMessageBlock!(textView.text)
        }
    }
}
