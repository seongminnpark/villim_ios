//
//  DiscoverTableViewController.swift
//  Villim
//
//  Created by Seongmin Park on 7/21/17.
//  Copyright © 2017 Villim. All rights reserved.
//

import UIKit
import Nuke

protocol DiscoverTableViewDelegate {
    func discoverItemSelected(position:Int)
    func onScroll(contentOffset:CGPoint)
    func onEndDrag(contentOffset:CGPoint)
    func onStopDecelerate(contentOffset:CGPoint)
}

class DiscoverTableViewController: UITableViewController {

    var discoverDelegate : DiscoverTableViewDelegate!
    var houses   : [VillimHouse] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Initialize tableview */
        self.tableView = UITableView()
        self.tableView.register(HouseTableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.backgroundColor = VillimValues.backgroundColor
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRect.zero) // Get rid of unnecessary cells stretching to the bottom.
        self.tableView.rowHeight = 330
        self.tableView.bounces = true
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.showsVerticalScrollIndicator = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return houses.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let house = houses[indexPath.row]
        
        let cell : DiscoverTableViewCell = DiscoverTableViewCell(style:UITableViewCellStyle.default, reuseIdentifier:"discover")
        
        let url = URL(string: house.houseThumbnailUrl)
        if url != nil {
            Nuke.loadImage(with: url!, into: cell.houseThumbnail)
        }
        cell.houseName.text = house.houseName
        cell.houseRating.rating = Double(house.houseRating)
        cell.monthlyRent.text = VillimUtils.getRentString(rent: house.ratePerMonth, month: true)
        cell.dailyRent.text = VillimUtils.getRentString(rent: house.ratePerNight, month: false)
        cell.makeConstraints()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        discoverDelegate.discoverItemSelected(position: indexPath.row)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        discoverDelegate.onScroll(contentOffset: scrollView.contentOffset)
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        discoverDelegate.onStopDecelerate(contentOffset: scrollView.contentOffset)
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            discoverDelegate.onEndDrag(contentOffset: scrollView.contentOffset)
        }
    }

}
