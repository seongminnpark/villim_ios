//
//  ReviewHouseViewController.swift
//  Villim
//
//  Created by Seongmin Park on 7/29/17.
//  Copyright © 2017 Villim. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire
import SwiftyJSON
import Cosmos

class ReviewHouseViewController: UIViewController, RatingSubmitListener, UITextFieldDelegate {

    var houseId              : Int! = 0
    
    var ratingOverall        : Double = 0.0
    var ratingAccuracy       : Double = 0.0
    var ratingLocation       : Double = 0.0
    var ratingCommunication  : Double = 0.0
    var ratingCheckin        : Double = 0.0
    var ratingCleanliness    : Double = 0.0
    var ratingValue          : Double = 0.0
    
    var ratingContainer      : UIView!
    var ratingLabel          : UILabel!
    var ratingBar            : CosmosView!
    var rateButton           : UIButton!
    var reviewLabel          : UILabel!
    var reviewContentField   : UITextField!
    var nextButton           : UIButton!
    
    var errorMessage         : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = VillimValues.backgroundColor
        self.title = NSLocalizedString("review_house", comment: "")
        
        /* Set back button */
        let backItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem
        self.navigationController?.navigationBar.tintColor = VillimValues.darkBackButtonColor
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.extendedLayoutIncludesOpaqueBars = true
        
        /* Rating container */
        ratingContainer = UIView()
        self.view.addSubview(ratingContainer)
        
        /* Rating Label */
        ratingLabel = UILabel()
        ratingLabel.font = UIFont(name: "NotoSansCJKkr-Regular", size: 16)
        ratingLabel.textColor = UIColor(red:0.02, green:0.02, blue:0.04, alpha:1.0)
        ratingLabel.text = NSLocalizedString("rating", comment: "")
        ratingContainer.addSubview(ratingLabel)
        
        /* Rating bar */
        ratingBar = CosmosView()
        ratingBar.settings.updateOnTouch = false
        ratingBar.settings.fillMode = .precise
        ratingBar.settings.starSize = 15
        ratingBar.settings.starMargin = 5
        ratingBar.rating = self.ratingOverall
        ratingBar.settings.filledImage = UIImage(named: "icon_star_on")
        ratingBar.settings.emptyImage = UIImage(named: "icon_star_off")
        ratingContainer.addSubview(ratingBar)
        
        /* Rate button */
        rateButton = UIButton()
        rateButton.titleLabel?.font = UIFont(name: "NotoSansCJKkr-Medium", size: 16)
        rateButton.setTitleColor(VillimValues.themeColor, for: .normal)
        rateButton.setTitleColor(VillimValues.themeColorHighlighted, for: .highlighted)
        rateButton.setTitle(NSLocalizedString("rate", comment: ""), for: .normal)
        rateButton.addTarget(self, action:#selector(self.launchRateHouseViewController), for: .touchUpInside)
        ratingContainer.addSubview(rateButton)
        
        /* Review Label */
        reviewLabel = UILabel()
        reviewLabel.font = UIFont(name: "NotoSansCJKkr-Regular", size: 16)
        reviewLabel.textColor = UIColor(red:0.02, green:0.02, blue:0.04, alpha:1.0)
        reviewLabel.text = NSLocalizedString("review", comment: "")
        self.view.addSubview(reviewLabel)
        
        /* Review content field */
        reviewContentField = UITextField()
        reviewContentField.font = UIFont(name: "NotoSansCJKkr-DemiLight", size: 16)
        reviewContentField.placeholder = NSLocalizedString("review_content_placeholder", comment: "")
        reviewContentField.autocapitalizationType = .none
        reviewContentField.returnKeyType = .done
        reviewContentField.delegate = self
        self.view.addSubview(reviewContentField)
        
        /* Next button */
        nextButton = UIButton()
        nextButton.setBackgroundColor(color: VillimValues.themeColor, forState: .normal)
        nextButton.setBackgroundColor(color: VillimValues.themeColorHighlighted, forState: .highlighted)
        nextButton.adjustsImageWhenHighlighted = true
        nextButton.titleLabel?.font = VillimValues.bottomButtonFont
        nextButton.setTitleColor(UIColor.white, for: .normal)
        nextButton.setTitleColor(VillimValues.whiteHighlightedColor, for: .highlighted)
        nextButton.setTitle(NSLocalizedString("submit", comment: ""), for: .normal)
        nextButton.addTarget(self, action: #selector(self.sendReviewHouseRequest), for: .touchUpInside)
        self.view.addSubview(nextButton)
        
        /* Error message */
        errorMessage = UILabel()
        errorMessage.textAlignment = .center
        errorMessage.textColor = VillimValues.themeColor
        errorMessage.font = UIFont(name: "NotoSansCJKkr-Regular", size: 15)
        self.view.addSubview(errorMessage)
        
        makeConstraints()
    }
    
    func makeConstraints() {
        /* Prevent overlap with navigation controller */
        let navControllerHeight = self.navigationController!.navigationBar.frame.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let topOffset = navControllerHeight + statusBarHeight
        
        /* Rating Container */
        ratingContainer?.snp.makeConstraints { (make) -> Void in
            make.width.equalToSuperview()
            make.top.equalTo(topOffset)
            make.height.equalTo(80)
        }
        
        /* Rating label */
        ratingLabel?.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(VillimValues.sideMargin)
            make.centerY.equalToSuperview()
        }

        /* Rating bar */
        ratingBar?.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(ratingLabel.snp.right).offset(VillimValues.sideMargin)
            make.centerY.equalToSuperview()
        }
        
        /* Rate button */
        rateButton?.snp.makeConstraints { (make) -> Void in
            make.right.equalToSuperview().offset(-VillimValues.sideMargin)
            make.centerY.equalToSuperview()
        }
        
        /* Review label */
        reviewLabel?.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(VillimValues.sideMargin)
            make.top.equalTo(ratingContainer.snp.bottom).offset(VillimValues.sideMargin)
        }
        
        /* Review content field */
        reviewContentField?.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(VillimValues.sideMargin)
            make.top.equalTo(reviewLabel.snp.bottom).offset(VillimValues.sideMargin * 2)
        }
        
        /* Next button */
        nextButton?.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(self.view)
            make.height.equalTo(VillimValues.BOTTOM_BUTTON_HEIGHT)
            make.bottom.equalTo(self.view)
        }
        
        /* Error message */
        errorMessage?.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(self.view)
            make.height.equalTo(30)
            make.bottom.equalTo(nextButton.snp.top)
        }
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor(red:0.66, green:0.66, blue:0.66, alpha:1.0).cgColor
        border.frame = CGRect(x: 0, y: ratingContainer.frame.size.height - width, width:  ratingContainer.frame.size.width, height: ratingContainer.frame.size.height)
        border.backgroundColor = UIColor.clear.cgColor
        border.borderWidth = width
        ratingContainer.layer.addSublayer(border)
        ratingContainer.layer.masksToBounds = true
    }

    @objc private func sendReviewHouseRequest() {
        
        VillimUtils.showLoadingIndicator()
        
        let parameters = [
            VillimKeys.KEY_HOUSE_ID             : houseId,
            VillimKeys.KEY_REVIEW_CONTENT       : (reviewContentField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!,
            VillimKeys.KEY_RATING_OVERALL       : 0.0,
            VillimKeys.KEY_RATING_ACCURACY      : 0.0,
            VillimKeys.KEY_RATING_LOCATION      : 0.0,
            VillimKeys.KEY_RATING_COMMUNICATION : 0.0,
            VillimKeys.KEY_RATING_CHECKIN       : 0.0,
            VillimKeys.KEY_RATING_CLEANLINESS   : 0.0,
            VillimKeys.KEY_RATING_VALUE         : 0.0,
            ] as [String : Any]
        
        let url = VillimUtils.buildURL(endpoint: VillimKeys.HOUSE_REVIEW_URL)
        
        Alamofire.request(url, method:.post, parameters:parameters,encoding: URLEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                let responseData = JSON(data: response.data!)
                
                if responseData[VillimKeys.KEY_CHANGE_SUCCESS].boolValue {
                    
                    
                    
                } else {
                    self.showErrorMessage(message: responseData[VillimKeys.KEY_MESSAGE].stringValue)
                }
            case .failure(let error):
                self.showErrorMessage(message: NSLocalizedString("server_unavailable", comment: ""))
            }
            VillimUtils.hideLoadingIndicator()
        }
    }

    
    func launchRateHouseViewController() {
        let rateHouseViewController = RateHouseViewController()
        rateHouseViewController.listener            = self
        rateHouseViewController.ratingAccuracy      = self.ratingAccuracy
        rateHouseViewController.ratingLocation      = self.ratingLocation
        rateHouseViewController.ratingCommunication = self.ratingCommunication
        rateHouseViewController.ratingCheckin       = self.ratingCheckin
        rateHouseViewController.ratingCleanliness   = self.ratingCleanliness
        rateHouseViewController.ratingValue         = self.ratingValue
        self.navigationController?.pushViewController(rateHouseViewController, animated: true)
    }
    
    func onRatingSubmit(ratingAccuracy      : Double,
                     ratingLocation      : Double,
                     ratingCommunication : Double,
                     ratingCheckin       : Double,
                     ratingCleanliness   : Double,
                     ratingValue         : Double ){
        
        self.ratingAccuracy      = ratingAccuracy
        self.ratingLocation      = ratingLocation
        self.ratingCommunication = ratingCommunication
        self.ratingCheckin       = ratingCheckin
        self.ratingCleanliness   = ratingCleanliness
        self.ratingValue         = ratingValue
        
        self.recalculateOverallRating()
    }
    
    func recalculateOverallRating() {
        self.ratingOverall =
            (self.ratingAccuracy + self.ratingLocation + self.ratingCommunication +
                self.ratingCheckin + self.ratingCleanliness + self.ratingValue) / 6.0
       
        self.ratingBar.rating = ratingOverall
        
    }
    
    /* Text field listeners */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func showErrorMessage(message:String) {
        errorMessage.isHidden = false
        errorMessage.text = message
    }
    
    private func hideErrorMessage() {
        errorMessage.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        hideErrorMessage()
        VillimUtils.hideLoadingIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

}
