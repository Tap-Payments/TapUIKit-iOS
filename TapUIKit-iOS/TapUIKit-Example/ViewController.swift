//
//  ViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 27/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    lazy var dataSource:[[String:String]] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dataSource.append(["title":"Tap Chip","subtitle":"Shows a custom view for a dynamic chip view","navigationID":"TapChipExampleViewController"])
        dataSource.append(["title":"Tap Recent Cards","subtitle":"Shows a custom view for recent cards collection view","navigationID":"TapRecentCardsExampleViewController"])
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension ViewController:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tapUIKitCell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]["title"]
        cell.detailTextLabel?.text = dataSource[indexPath.row]["subtitle"]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let destnationVC:UIViewController = storyboard?.instantiateViewController(withIdentifier: dataSource[indexPath.row]["navigationID"]!) {
            destnationVC.title = dataSource[indexPath.row]["title"]
            self.navigationController?.pushViewController(destnationVC, animated: true)
        }
        
    }
    
    
    
}

