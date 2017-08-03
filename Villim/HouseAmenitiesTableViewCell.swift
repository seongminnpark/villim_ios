//
//  HouseAmenitiesTableViewCell.swift
//  Villim
//
//  Created by Seongmin Park on 7/26/17.
//  Copyright © 2017 Villim. All rights reserved.
//

import UIKit

protocol AmenityDelegate {
    func onAmenitySeeMore()
}

class HouseAmenitiesTableViewCell: UITableViewCell {

    static let AMENITY_ICON_SIZE = 30.0
    
    var amenityDelegate : AmenityDelegate! = nil
    
    var amenities : [Int] = []
    
    var title     : UILabel!
    var stackView : UIStackView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: UITableViewCellStyle.value1, reuseIdentifier: reuseIdentifier)
        
        title = UILabel()
        title.text = NSLocalizedString("amenities", comment: "")
        self.contentView.addSubview(title)
        
        stackView = UIStackView()
        stackView.axis = UILayoutConstraintAxis.horizontal
        stackView.distribution = UIStackViewDistribution.equalSpacing
        stackView.alignment = UIStackViewAlignment.center
        self.contentView.addSubview(stackView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func populateViews() {
        let numIcons = amenities.count > HouseDetailViewController.MAX_AMENITY_ICONS ?
        HouseDetailViewController.MAX_AMENITY_ICONS - 1 : amenities.count
    
        if numIcons == 0 {
    
            let noAmenityLabel = UILabel()
            noAmenityLabel.text = NSLocalizedString("no_amenity", comment: "")
            stackView.addArrangedSubview(noAmenityLabel)
    
        } else if amenities.count <= HouseDetailViewController.MAX_AMENITY_ICONS {
    
            for index in 0 ..< amenities.count {
                let icon = UIImageView()
                icon.image = VillimAmenity.getAmenityImage(amenityId: amenities[index])
                stackView.addArrangedSubview(icon)
            }
    
        } else { /* amenities.count > MAX_AMENITY_ICONS */
    
            for index in 0 ..< numIcons {
                let icon = UIImageView()
                icon.image = VillimAmenity.getAmenityImage(amenityId: amenities[index])
                stackView.addArrangedSubview(icon)
            }
    
            let seeMoreButton = UIButton()
            seeMoreButton.setTitle(String(format: NSLocalizedString("amenity_see_more_format", comment: ""), amenities.count - numIcons), for: .normal)
            seeMoreButton.setTitleColor(VillimValues.themeColor, for: .normal)
            seeMoreButton.addTarget(self, action: #selector(self.seeMore), for: .touchUpInside)
            stackView.addArrangedSubview(seeMoreButton)
        }
    }
    
    func makeConstraints() {
        
        title?.snp.makeConstraints { (make) -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(50)
            make.top.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        stackView?.snp.makeConstraints{ (make) -> Void in
            make.width.equalToSuperview()
            make.top.equalTo(title.snp.bottom)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
        }
    }
    
    func seeMore() {
        if amenityDelegate != nil {
            amenityDelegate.onAmenitySeeMore()
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
