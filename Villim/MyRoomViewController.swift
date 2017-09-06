//
//  MyRoomViewController.swift
//  Villim
//
//  Created by Seongmin Park on 8/17/17.
//  Copyright © 2017 Villim. All rights reserved.
//

import UIKit
import Alamofire
import SnapKit
import SwiftyJSON
import Nuke
import Toaster
import AudioToolbox
import SwiftDate

class MyRoomViewController: UIViewController {

    let STATE_PAY = 0
    let STATE_PASSCODE = 1
    let STATE_SERVICE = 2
    
    let CHANGE_PASSCODE   = 0
    let REQUEST_CLEANING  = 1
    let LOCAL_AMUSEMENTS  = 2
    let LEAVE_REVIEW      = 3
    
    let houseImageSize       : CGFloat = 200.0
    let CONTAINER_WIDTH      = 80.0
    let ICON_HEIGHT          = 30
    let MENU_HEIGHT          = 100
    let BUTTON_HEIGHT        = 80.0
    
    var houseId              : Int!    = 0
    var houseName            : String! = ""
    var checkIn              : DateInRegion!
    var checkOut             : DateInRegion!
    var houseThumbnailUrl    : String! = ""
    
    let slideButtonWidth     : CGFloat = 300.0
    let slideButtonHeight    : CGFloat = 60.0
    
    /* When room info exists */
    var scrollView           : UIScrollView!
    var headerView           : MyRoomHeaderView!
    var myRoomTableViewController : MyRoomTableViewController!
    var menu                 : UIView!
    var payContainer         : UIView!
    var payLabel             : UILabel!
    var payImage             : UIImageView!
    var passcodeContainer    : UIView!
    var passcodeLabel        : UILabel!
    var passcodeImage        : UIImageView!
    var serviceContainer     : UIView!
    var serviceLabel         : UILabel!
    var serviceImage         : UIImageView!
    var menuContent          : UIView!
    var cleaningButton       : UIButton!
    var localButton          : UIButton!
    var reviewButton         : UIButton!
    
    /* When there is no room to display */
    var container            : UIView!
    var houseImage           : UIImageView!
    var noRoomLabel          : UILabel!
    
    var findRoomButton       : UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /* Set back button */
        let backItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem
        self.navigationController?.navigationBar.tintColor = VillimValues.darkBackButtonColor
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.extendedLayoutIncludesOpaqueBars = true
        
        self.view.backgroundColor = VillimValues.backgroundColor
        self.title = NSLocalizedString("my_room", comment: "")
        
    }
    
    @objc private func sendMyHouseRequest() {
        
        VillimUtils.showLoadingIndicator()
        
        let parameters = [String : Any]()
        
        let url = VillimUtils.buildURL(endpoint: VillimKeys.MY_HOUSE_URL)
        
        Alamofire.request(url, method:.get, parameters:parameters,encoding: URLEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                let responseData = JSON(data: response.data!)
                
                if responseData[VillimKeys.KEY_QUERY_SUCCESS].boolValue {
                    self.houseId           = responseData[VillimKeys.KEY_HOUSE_ID].exists() ? responseData[VillimKeys.KEY_HOUSE_ID].intValue : 0
                    self.houseName         = responseData[VillimKeys.KEY_HOUSE_NAME].exists() ? responseData[VillimKeys.KEY_HOUSE_NAME].stringValue : ""
                    let checkInString      = responseData[VillimKeys.KEY_CHECKIN].exists() ? responseData[VillimKeys.KEY_CHECKIN].stringValue : ""
                    self.checkIn           = VillimUtils.dateFromString(dateString: checkInString)
                    let checkOutString     = responseData[VillimKeys.KEY_CHECKOUT].exists() ? responseData[VillimKeys.KEY_CHECKOUT].stringValue : ""
                    self.checkOut          = VillimUtils.dateFromString(dateString: checkOutString)
                    self.houseThumbnailUrl = responseData[VillimKeys.KEY_HOUSE_THUMBNAIL_URL].exists() ? responseData[VillimKeys.KEY_HOUSE_THUMBNAIL_URL].stringValue : ""
                    
                    self.setUpRoomLayout()
                    
                    //                    self.populateViews()
                } else {
                    self.setUpNoRoomLayout()
                    self.showErrorMessage(message: responseData[VillimKeys.KEY_MESSAGE].stringValue)
                }
            case .failure(let error):
                self.showErrorMessage(message: NSLocalizedString("server_unavailable", comment: ""))
            }
            VillimUtils.hideLoadingIndicator()
        }
    }
    
    @objc private func sendOpenDoorlockRequest() {
        
        VillimUtils.showLoadingIndicator()
        
        let parameters = [String : Any]()
        
        let url = VillimUtils.buildURL(endpoint: VillimKeys.OPEN_DOORLOCK_URL)
        
        Alamofire.request(url, method:.get, parameters:parameters,encoding: URLEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                let responseData = JSON(data: response.data!)
                if responseData[VillimKeys.KEY_OPEN_AUTHORIZED].boolValue && responseData[VillimKeys.KEY_SUCCESS].boolValue {
                    self.showErrorMessage(message: NSLocalizedString("doorlock_open_success", comment: ""))
                    if VillimSession.getVibrationOnUnlock() {
                        if #available(iOS 10, *) {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                        } else {
                            // use another api
                        }
                    }
                    
                } else {
                    self.showErrorMessage(message: responseData[VillimKeys.KEY_MESSAGE].stringValue)
                }
            case .failure(let error):
                self.showErrorMessage(message: NSLocalizedString("server_unavailable", comment: ""))
            }
            VillimUtils.hideLoadingIndicator()
        }
    }
    
    func setUpRoomLayout() {
        
        if container != nil {
            container.removeFromSuperview()
        }
        
        if findRoomButton != nil {
            findRoomButton.removeFromSuperview()
        }
        
        scrollView = UIScrollView()
        self.view.addSubview(scrollView)
        
        /* Set up headerview */
        headerView = MyRoomHeaderView()
        if houseThumbnailUrl.isEmpty {
            headerView.houseImage.image = #imageLiteral(resourceName: "img_default")
        } else {
            let url = URL(string:houseThumbnailUrl)
            Nuke.loadImage(with: url!, into: headerView.houseImage)
        }
        headerView.houseName.text = houseName
        headerView.clipsToBounds = true
        scrollView.addSubview(headerView)
        
        /* Menu */
        menu = UIView()
        scrollView.addSubview(menu)
        
        /* Pay button */
        payContainer = UIView()
        let payGestureRecognizer = UITapGestureRecognizer(target: self, action:  #selector (self.selectPay))
        payContainer.addGestureRecognizer(payGestureRecognizer)
        menu.addSubview(payContainer)
        
        payLabel = UILabel()
        payLabel.text = NSLocalizedString("pay_rent", comment: "")
        payLabel.font = UIFont(name: "NotoSansCJKkr-Regular", size: 14)
        payLabel.textColor = UIColor(red:0.35, green:0.34, blue:0.34, alpha:1.0)
        payContainer.addSubview(payLabel)
        
        payImage = UIImageView()
        payImage.image = #imageLiteral(resourceName: "creditcard_black")
        payContainer.addSubview(payImage)
        
        /* Passcode button */
        passcodeContainer = UIView()
        let passcodeGestureRecognizer = UITapGestureRecognizer(target: self, action:  #selector (self.selectPasscode))
        passcodeContainer.addGestureRecognizer(passcodeGestureRecognizer)
        menu.addSubview(passcodeContainer)
        
        passcodeLabel = UILabel()
        passcodeLabel.text = NSLocalizedString("doorlock_passcode", comment: "")
        passcodeLabel.font = UIFont(name: "NotoSansCJKkr-Regular", size: 14)
        passcodeLabel.textColor = UIColor(red:0.35, green:0.34, blue:0.34, alpha:1.0)
        passcodeContainer.addSubview(passcodeLabel)
        
        passcodeImage = UIImageView()
        passcodeImage.image = #imageLiteral(resourceName: "doorlock_black")
        passcodeContainer.addSubview(passcodeImage)
        
        /* Service button */
        serviceContainer = UIView()
        let serviceGestureRecognizer = UITapGestureRecognizer(target: self, action:  #selector (self.selectService))
        serviceContainer.addGestureRecognizer(serviceGestureRecognizer)
        menu.addSubview(serviceContainer)
        
        serviceLabel = UILabel()
        serviceLabel.text = NSLocalizedString("services", comment: "")
        serviceLabel.font = UIFont(name: "NotoSansCJKkr-Regular", size: 14)
        serviceLabel.textColor = UIColor(red:0.35, green:0.34, blue:0.34, alpha:1.0)
        serviceContainer.addSubview(serviceLabel)
        
        serviceImage = UIImageView()
        serviceImage.image = #imageLiteral(resourceName: "service_black")
        serviceContainer.addSubview(serviceImage)
        
        menuContent = UIView()
        scrollView.addSubview(menuContent)
        
        makeRoomConstraints()
        
        selectPay()
    }
    
    func makeRoomConstraints() {
        
        /* Prevent overlap with navigation controller */
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let screenWidth = UIScreen.main.bounds.width
        
        scrollView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(statusBarHeight)
            make.right.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        headerView.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        menu?.snp.makeConstraints { (make) -> Void in
            make.width.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
            make.height.equalTo(MENU_HEIGHT)
        }
        
        payContainer?.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(CONTAINER_WIDTH)
            make.centerY.equalToSuperview()
            make.centerX.equalTo(screenWidth / 6.0)
        }
        payImage?.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        payLabel?.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.top.equalTo(payImage.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
        }
        
        passcodeContainer?.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(CONTAINER_WIDTH)
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        passcodeImage?.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        passcodeLabel?.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.top.equalTo(passcodeImage.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
        }
        
        serviceContainer?.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(CONTAINER_WIDTH)
            make.centerY.equalToSuperview()
            make.centerX.equalTo(screenWidth * 5 / 6.0)
        }
        serviceImage?.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        serviceLabel?.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.top.equalTo(serviceImage.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
        }
    
        menuContent.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(menu.snp.bottom)
            make.right.equalToSuperview()
            make.left.equalToSuperview()
            make.height.equalTo(BUTTON_HEIGHT * 3)
        }
    }
    
    func setUpNoRoomLayout() {
        
        if myRoomTableViewController != nil {
            myRoomTableViewController.tableView.removeFromSuperview()
        }
        
        if headerView != nil {
            headerView.removeFromSuperview()
        }
        
        if menu != nil {
            menu.removeFromSuperview()
        }
        
        if menuContent != nil {
            menuContent.removeFromSuperview()
        }
        
        /* Info container */
        container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = true
        self.view.addSubview(container)
        
        /* House picture */
        houseImage = UIImageView()
        houseImage.layer.cornerRadius = houseImageSize / 2
        houseImage.layer.masksToBounds = true
        container.addSubview(houseImage)
        
        houseImage?.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(houseImageSize)
            make.height.equalTo(houseImageSize)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        /* Labels */
        noRoomLabel = UILabel()
        noRoomLabel.textAlignment = .center
        noRoomLabel.font = UIFont(name: "NotoSansCJKkr-Regular", size: 17)
        noRoomLabel.textColor = UIColor(red:0.02, green:0.02, blue:0.04, alpha:1.0)
        container.addSubview(noRoomLabel)
        
        noRoomLabel?.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(houseImage.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        
        /* Find room button */
        let buttonLeft = UIScreen.main.bounds.width/2 - slideButtonWidth/2
        let buttonTop = UIScreen.main.bounds.height - tabBarController!.tabBar.bounds.height - slideButtonHeight * 2
        findRoomButton = UIButton(frame:CGRect(x:buttonLeft,y:buttonTop, width:slideButtonWidth, height:slideButtonHeight))
        findRoomButton.backgroundColor = VillimValues.themeColor
        findRoomButton.setTitle(NSLocalizedString("find_house", comment: ""), for: .normal)
        findRoomButton.setTitleColor(UIColor.white, for: .normal)
        findRoomButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        findRoomButton.layer.cornerRadius  = 30
        findRoomButton.layer.masksToBounds = true
        findRoomButton.addTarget(self, action:#selector(self.showDiscoverTab), for: .touchUpInside)
        self.view.addSubview(findRoomButton)
        
        /* Room Info */
        houseImage.image = #imageLiteral(resourceName: "img_default")
        noRoomLabel.text = NSLocalizedString("no_rented_house", comment: "")
        
        container?.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(houseImage)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-slideButtonHeight)
        }
    }
    
    /* Menu items callback */
    func selectPay() {
       updateMenuState(state:STATE_PAY)
    }
    
    func selectPasscode() {
        updateMenuState(state:STATE_PASSCODE)
    }
    
    func selectService() {
        
        /* Set up buttons */
        cleaningButton = UIButton()
        cleaningButton.titleLabel?.font = UIFont(name: "NotoSansCJKkr-Regular", size: 20)
        cleaningButton.setTitleColor(UIColor.black, for: .normal)
        cleaningButton.setTitle(NSLocalizedString("request_cleaning_service", comment: ""), for: .normal)
        menuContent.addSubview(cleaningButton)
        
        localButton = UIButton()
        localButton.titleLabel?.font = UIFont(name: "NotoSansCJKkr-Regular", size: 20)
        localButton.setTitleColor(UIColor.black, for: .normal)
        localButton.setTitle(NSLocalizedString("local_amusements", comment: ""), for: .normal)
        menuContent.addSubview(localButton)
        
        reviewButton = UIButton()
        reviewButton.titleLabel?.font = UIFont(name: "NotoSansCJKkr-Regular", size: 20)
        reviewButton.setTitleColor(UIColor.black, for: .normal)
        reviewButton.setTitle(NSLocalizedString("review_house", comment: ""), for: .normal)
        menuContent.addSubview(reviewButton)
        
        cleaningButton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(BUTTON_HEIGHT)
            make.top.left.right.equalToSuperview()
        }
        
        localButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(cleaningButton.snp.bottom)
            make.height.equalTo(BUTTON_HEIGHT)
            make.left.right.equalToSuperview()
        }
        reviewButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(localButton.snp.bottom)
            make.height.equalTo(BUTTON_HEIGHT)
            make.left.right.equalToSuperview()
        }
        
        updateMenuState(state:STATE_SERVICE)
    }
    
    func updateMenuState(state:Int) {
        switch state {
        case STATE_PAY:
             /* Set image color */
            payImage.image = #imageLiteral(resourceName: "creditcard_red")
            passcodeImage.image = #imageLiteral(resourceName: "doorlock_black")
            serviceImage.image = #imageLiteral(resourceName: "service_black")
            /* Set text color */
            payLabel.textColor = VillimValues.themeColor
            passcodeLabel.textColor = UIColor.black
            serviceLabel.textColor = UIColor.black
            break
            
        case STATE_PASSCODE:
            /* Set image color */
            payImage.image = #imageLiteral(resourceName: "creditcard_black")
            passcodeImage.image = #imageLiteral(resourceName: "doorlock_red")
            serviceImage.image = #imageLiteral(resourceName: "service_black")
            /* Set text color */
            payLabel.textColor = UIColor.black
            passcodeLabel.textColor = VillimValues.themeColor
            serviceLabel.textColor = UIColor.black
            break
            
        case STATE_SERVICE:
            /* Set image color */
            payImage.image = #imageLiteral(resourceName: "creditcard_black")
            passcodeImage.image = #imageLiteral(resourceName: "doorlock_black")
            serviceImage.image = #imageLiteral(resourceName: "service_red")
            /* Set text color */
            payLabel.textColor = UIColor.black
            passcodeLabel.textColor = UIColor.black
            serviceLabel.textColor = VillimValues.themeColor
            break
            
        default:
            break
        }
        
        /* Adjust content size of scrollview */
        print("menu content height:", menuContent.bounds.height)
        print("menu content origin y:",menuContent.frame.origin.y)
        print("scrollview content size height:", scrollView.contentSize.height)
        let contentOrigin = menuContent.frame.origin.y
        let contentHeight = menuContent.frame.size.height
        scrollView.contentSize = CGSize(width:scrollView.frame.size.width, height: contentOrigin + contentHeight)
        print("operated")
        print("menu content height:", menuContent.bounds.height)
        print("scrollview content size height:", scrollView.contentSize.height)
        print("------")
    }

    
    func serviceItemSelected(item:Int) {
        switch item {
        case MyRoomTableViewController.CHANGE_PASSCODE:
            launcChangePasscodeViewController()
            break
        case MyRoomTableViewController.REQUEST_CLEANING:
            break
        case MyRoomTableViewController.LOCAL_AMUSEMENTS:
            break
        case MyRoomTableViewController.LEAVE_REVIEW:
            launchReviewHouseViewController()
            break
        default:
            break
        }
    }

    func launchReviewHouseViewController() {
        self.tabBarController?.tabBar.isHidden = true
        let reviewHouseViewController = ReviewHouseViewController()
        reviewHouseViewController.houseId = houseId
        self.navigationController?.pushViewController(reviewHouseViewController, animated: true)
    }
    
    func launcChangePasscodeViewController() {
        self.tabBarController?.tabBar.isHidden = true
        let changePasscodeViewController = ChangePasscodeViewController()
        self.navigationController?.pushViewController(changePasscodeViewController, animated: true)
    }
    
    func showDiscoverTab() {
        self.tabBarController?.selectedIndex = 0;
    }
    
    private func showErrorMessage(message:String) {
        let toast = Toast(text: message, duration: Delay.long)
        
        ToastView.appearance().bottomOffsetPortrait = (tabBarController?.tabBar.frame.size.height)! + 30
        ToastView.appearance().bottomOffsetLandscape = (tabBarController?.tabBar.frame.size.height)! + 30
        ToastView.appearance().font = UIFont.systemFont(ofSize: 17.0)
        
        toast.show()
    }
    
    private func hideErrorMessage() {
        ToastCenter.default.cancelAll()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        hideErrorMessage()
        VillimUtils.hideLoadingIndicator()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = true
        
        if VillimSession.getLoggedIn() {
            sendMyHouseRequest()
        } else {
            setUpNoRoomLayout()
        }
    }

}
