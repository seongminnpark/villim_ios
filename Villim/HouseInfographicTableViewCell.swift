//
//  HouseInfographicTableViewCell.swift
//  Villim
//
//  Created by Seongmin Park on 7/26/17.
//  Copyright © 2017 Villim. All rights reserved.
//

import UIKit
import Nuke

class HouseInfographicTableViewCell: UITableViewCell {

    let CONTAINER_WIDTH      = 80.0
    let CONTAINER_HEIGHT     = 100.0
    let CONTAINER_SEPARATION = 10.0
    let ICON_HEIGHT          = 30
    
    var guestContainer     : UIView!
    var guestCountLabel    : UILabel!
    var guestCountImage    : UIImageView!
    
    var roomContainer      : UIView!
    var roomCountLabel     : UILabel!
    var roomCountImage     : UIImageView!
    
    var bedContainer       : UIView!
    var bedCountLabel      : UILabel!
    var bedCountImage      : UIImageView!
    
    var bathroomContainer  : UIView!
    var bathroomCountLabel : UILabel!
    var bathroomCountImage : UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: UITableViewCellStyle.value1, reuseIdentifier: reuseIdentifier)
        
        self.contentView.backgroundColor = VillimValues.backgroundColor
        
        /* Number of guests */
        guestContainer = UIView()
        self.contentView.addSubview(guestContainer)
        
        guestCountLabel = UILabel()
        guestCountLabel.font = UIFont(name: "NotoSansCJKkr-Regular", size: 14)
        guestCountLabel.textColor = UIColor(red:0.35, green:0.34, blue:0.34, alpha:1.0)
        guestContainer.addSubview(guestCountLabel)
        
        guestCountImage = UIImageView()
        guestContainer.addSubview(guestCountImage)
        
        /* Number of rooms */
        roomContainer = UIView()
        self.contentView.addSubview(roomContainer)
        
        roomCountLabel = UILabel()
        roomCountLabel.font = UIFont(name: "NotoSansCJKkr-Regular", size: 14)
        roomCountLabel.textColor = UIColor(red:0.35, green:0.34, blue:0.34, alpha:1.0)
        roomContainer.addSubview(roomCountLabel)
        
        roomCountImage = UIImageView()
        roomContainer.addSubview(roomCountImage)
        
        /* Number of beds */
        bedContainer = UIView()
        self.contentView.addSubview(bedContainer)
        
        bedCountLabel = UILabel()
        bedCountLabel.font = UIFont(name: "NotoSansCJKkr-Regular", size: 14)
        bedCountLabel.textColor = UIColor(red:0.35, green:0.34, blue:0.34, alpha:1.0)
        bedContainer.addSubview(bedCountLabel)
        
        bedCountImage = UIImageView()
        bedContainer.addSubview(bedCountImage)
        
        /* Number of bathrooms */
        bathroomContainer = UIView()
        self.contentView.addSubview(bathroomContainer)
        
        bathroomCountLabel = UILabel()
        bathroomCountLabel.font = UIFont(name: "NotoSansCJKkr-Regular", size: 14)
        bathroomCountLabel.textColor = UIColor(red:0.35, green:0.34, blue:0.34, alpha:1.0)
        bathroomContainer.addSubview(bathroomCountLabel)
        
        bathroomCountImage = UIImageView()
        bathroomContainer.addSubview(bathroomCountImage)
        
        populateViews()
        makeConstraints()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func makeConstraints() {
        
        /* Number of guests */
        guestContainer?.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(CONTAINER_WIDTH)
            make.centerY.equalToSuperview()
            make.left.equalTo(self.contentView.snp.centerX).offset(-(CONTAINER_SEPARATION * 1.5 + CONTAINER_WIDTH * 2))
        }
        guestCountImage?.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        guestCountLabel?.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.top.equalTo(guestCountImage.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
        }
        
        /* Number of rooms */
        roomContainer?.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(CONTAINER_WIDTH)
            make.centerY.equalToSuperview()
            make.left.equalTo(self.contentView.snp.centerX).offset(-(CONTAINER_SEPARATION * 0.5 + CONTAINER_WIDTH))
        }
        roomCountImage?.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        roomCountLabel?.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.top.equalTo(roomCountImage.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
        }
        
        /* Number of beds */
        bedContainer?.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(CONTAINER_WIDTH)
            make.centerY.equalToSuperview()
            make.left.equalTo(self.contentView.snp.centerX).offset(CONTAINER_SEPARATION * 0.5)
        }
        bedCountImage?.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        bedCountLabel?.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.top.equalTo(bedCountImage.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
        }
        
        /* Number of bathrooms */
        bathroomContainer?.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(CONTAINER_WIDTH)
            make.centerY.equalToSuperview()
            make.left.equalTo(self.contentView.snp.centerX).offset(CONTAINER_SEPARATION * 1.5 + CONTAINER_WIDTH)
        }
        bathroomCountImage?.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        bathroomCountLabel?.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.top.equalTo(bathroomCountImage.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
        }
    }
    
    func populateViews() {
        /* Number of guests */
        guestCountImage.image = #imageLiteral(resourceName: "icon_guest")
        
        /* Number of rooms */
        roomCountImage.image = #imageLiteral(resourceName: "icon_door")
        
        /* Number of beds */
        bedCountImage.image = #imageLiteral(resourceName: "icon_bed")
        
        /* Number of bathrooms */
        bathroomCountImage.image = #imageLiteral(resourceName: "icon_bath")
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
