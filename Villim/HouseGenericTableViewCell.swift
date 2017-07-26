//
//  HouseItemTableViewCell.swift
//  Villim
//
//  Created by Seongmin Park on 7/26/17.
//  Copyright © 2017 Villim. All rights reserved.
//

import UIKit

class HouseGenericTableViewCell: UITableViewCell {

    var title   : UILabel!
    var content : UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: UITableViewCellStyle.value1, reuseIdentifier: reuseIdentifier)
        
        title = UILabel()
        self.contentView.addSubview(title)
        
        content = UILabel()
        self.contentView.addSubview(content)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func makeConstraints() {
        
        title?.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(100)
            make.height.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        content?.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(100)
            make.top.equalToSuperview()
            make.right.equalToSuperview()
        }
        
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
