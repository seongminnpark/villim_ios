//
//  ReservationHeaderTableViewCell.swift
//  Villim
//
//  Created by Seongmin Park on 8/3/17.
//  Copyright © 2017 Villim. All rights reserved.
//

import UIKit

class ReservationHeaderTableViewCell: UITableViewCell {

    let sideMargin : CGFloat = 20.0
    
    var houseName : UILabel!
    var houseAddr : UILabel!
    var houseInfo : UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: UITableViewCellStyle.value1, reuseIdentifier: reuseIdentifier)
        
        self.contentView.backgroundColor = VillimValues.backgroundColor
        
        houseName = UILabel()
        houseName.font = UIFont(name: "NotoSansCJKkr-Regular", size: 20)
        houseName.textColor = UIColor(red:0.02, green:0.05, blue:0.08, alpha:1.0)
        self.contentView.addSubview(houseName)
        
        houseAddr = UILabel()
        houseAddr.font = UIFont(name: "NotoSansCJKkr-Regular", size: 15)
        houseAddr.textColor = UIColor(red:0.02, green:0.02, blue:0.04, alpha:1.0)
        self.contentView.addSubview(houseAddr)
        
        houseInfo = UILabel()
        houseInfo.font = UIFont(name: "NotoSansCJKkr-DemiLight", size: 13)
        houseInfo.textColor = UIColor(red:0.35, green:0.34, blue:0.34, alpha:1.0)
        self.contentView.addSubview(houseInfo)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func makeConstraints() {
        
        houseName?.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(ReservationTableViewController.SIDE_MARGIN)
            make.right.equalToSuperview().offset(-ReservationTableViewController.SIDE_MARGIN)
            make.top.equalToSuperview().offset(ReservationTableViewController.SIDE_MARGIN)
        }
        
        houseAddr?.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(ReservationTableViewController.SIDE_MARGIN)
            make.right.equalToSuperview().offset(-ReservationTableViewController.SIDE_MARGIN)
            make.top.equalTo(houseName.snp.bottom).offset(ReservationTableViewController.SIDE_MARGIN)
        }
        
        houseInfo?.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(ReservationTableViewController.SIDE_MARGIN)
            make.right.equalToSuperview().offset(-ReservationTableViewController.SIDE_MARGIN)
            make.top.equalTo(houseAddr.snp.bottom).offset(ReservationTableViewController.SIDE_MARGIN * 0.5)
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
