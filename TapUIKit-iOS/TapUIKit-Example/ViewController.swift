//
//  ViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 27/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import MOLH
import TapThemeManager2020

class ViewController: UIViewController {
    
    lazy var dataSource:[[String:String]] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dataSource.append(["title":"Tap Chip","subtitle":"Shows a custom view for a dynamic chip view","navigationID":"TapChipExampleViewController","lang":"0"])
        dataSource.append(["title":"Tap Recent Cards","subtitle":"Shows a custom view for recent cards collection view","navigationID":"TapRecentCardsExampleViewController","lang":"1"])
        dataSource.append(["title":"Full Tap Recent Cards","subtitle":"Shows a the full view with action buttons and scrolling cards","navigationID":"TapRecentCardsViewExampleViewController","lang":"1"])
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MOLH.setLanguageTo("en")
        MOLH.reset()
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
            if dataSource[indexPath.row]["lang"] == "1" {
                showLanguageSelection { (selectedLanguage) in
                    MOLH.setLanguageTo(selectedLanguage)
                    TapThemeManager.setDefaultTapTheme()
                    self.navigationController?.pushViewController(destnationVC, animated: true)
                }
            }else {
                TapThemeManager.setDefaultTapTheme()
                self.navigationController?.pushViewController(destnationVC, animated: true)
            }
        }
        
    }
    
    func showLanguageSelection(completion:@escaping (String)->()) {
        
        let alert:UIAlertController = UIAlertController(title: "Language", message: "Choose a language", preferredStyle: .actionSheet)
        let englishAction:UIAlertAction = UIAlertAction(title: "English", style: .default) { (_) in
            completion("en")
        }
        let arabicAction:UIAlertAction = UIAlertAction(title: "Arabic", style: .default) { (_) in
            completion("ar")
        }
        let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(englishAction)
        alert.addAction(arabicAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
}

