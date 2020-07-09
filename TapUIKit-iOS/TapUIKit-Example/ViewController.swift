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
import LocalisationManagerKit_iOS

class ViewController: UIViewController {
    
    lazy var dataSource:[[String:String]] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dataSource.append(["title":"Tap Bottom Sheet Dialog","subtitle":"Displays the Tap bottom popup modal contoller","navigationID":"TapBottomSheetExampleViewController","lang":"0","push":"1"])
        dataSource.append(["title":"Tap Separator View","subtitle":"Displays the separator view used in the UX","navigationID":"TapSeparatorViewController","lang":"0","push":"0"])
        dataSource.append(["title":"Tap Drag Handler View","subtitle":"Displays the drag handler view used in the UX","navigationID":"TapDragHandlerViewController","lang":"0","push":"0"])
        dataSource.append(["title":"Tap Merchant Header View","subtitle":"Displays the Tap Merchant head section view","navigationID":"TapMerchantHeaderViewController","lang":"1","push":"0"])
        dataSource.append(["title":"Tap Amount Section View","subtitle":"Displays the Tap Amount section view","navigationID":"TapAmountSectionViewController","lang":"1","push":"0"])
        dataSource.append(["title":"Chips","subtitle":"Displays the Tap Amount section view","navigationID":"ChipsTestingViewController","lang":"1","push":"0"])
        dataSource.append(["title":"Item Cell","subtitle":"Displays the Tap Item Cell view","navigationID":"ItemCellViewController","lang":"1","push":"0"])
        dataSource.append(["title":"CardPhone Icon","subtitle":"Displays the Icon in the cards and telecom icons bar","navigationID":"TapCardPhoneIconViewController","lang":"0","push":"0"])
        dataSource.append(["title":"CardPhone List","subtitle":"Displays the Card Phone List component","navigationID":"TapCardPhoneBarListViewController","lang":"0","push":"0"])
        dataSource.append(["title":"Card Input View","subtitle":"Displays the Card Input component","navigationID":"TapCardInputViewController","lang":"0","push":"0"])
        
        dataSource.append(["title":"Wall Of Glory","subtitle":"Shows all ui components from Checkout SDK done in action. NOTE: TRY CLICKING ANYWHERE TO SEE THE FIRED EVENTS","navigationID":"TapBottomSheetExampleViewController","lang":"0","push":"1"])
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MOLH.setLanguageTo("en")
        MOLH.reset()
//        applyTheme()
    }
    
//    /// Apply  the theme values from the theme file to the matching outlets
//    private func applyTheme()
//    {
//        TapThemeManager.setTapTheme()
//        self.setNeedsStatusBarAppearanceUpdate()
//    }
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
                    TapLocalisationManager.shared.localisationLocale = selectedLanguage
                    MOLH.setLanguageTo(selectedLanguage)
                    TapThemeManager.setDefaultTapTheme()
                    self.showController(contoller: destnationVC, push: self.dataSource[indexPath.row]["push"] == "1")
                }
            }else {
//                TapThemeManager.setDefaultTapTheme()
                TapThemeManager.setTapTheme()
                if let gloryExample:TapBottomSheetExampleViewController = destnationVC as? TapBottomSheetExampleViewController, indexPath.row == (dataSource.count - 1) {
                    MOLH.setLanguageTo("en")
                    gloryExample.showWallOfGlory = true
                }
                showController(contoller: destnationVC, push: dataSource[indexPath.row]["push"] == "1")
            }
        }
    }
    
    func showController(contoller:UIViewController, push:Bool) {
        if push {
            navigationController?.pushViewController(contoller, animated: true)
        }else {
            present(contoller, animated: true, completion: nil)
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

