//
//  ToPresentAsPopupViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 6/3/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS
protocol  ToPresentAsPopupViewControllerDelegate {
    func dismissMySelfClicked()
    func changeHeightClicked()
    func changeHeight(to newHeight:CGFloat)
    func updateStackViews(with views:[UIView])
}
class ToPresentAsPopupViewController: UIViewController {

    var delegate:ToPresentAsPopupViewControllerDelegate?
    @IBOutlet weak var tapVerticalView: TapVerticalView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tapVerticalView.delegate = self
        // Do any additional setup after loading the view.
        
        // Setting up the number of lines and doing a word wrapping
        UILabel.appearance(whenContainedInInstancesOf:[UIAlertController.self]).numberOfLines = 2
        UILabel.appearance(whenContainedInInstancesOf:[UIAlertController.self]).lineBreakMode = .byWordWrapping
    }
    
    @IBAction func dismissMySelfClicked(_ sender: Any) {
        //self.dismissTheController()
        guard let delegate = delegate else { return }
        delegate.dismissMySelfClicked()
    }
    
    @IBAction func changeHeightClicked(_ sender: Any) {
        guard let delegate = delegate else { return }
        delegate.changeHeightClicked()
        //self.changeHeight(to: CGFloat(Int.random(in: 50 ..< 600)))
    }
    
    
    @IBAction func changeTheViewsDynamically(_ sender: Any) {
        
        
        let alertController:UIAlertController = .init(title: "Update the list", message: "Which type of updates you want to try?", preferredStyle: .alert)
        let random:UIAlertAction = .init(title: "Random additions and removals", style: .default) { _ in
            var views:[UIView] = []
            for _ in 0..<Int.random(in: 1 ..< 10) {
                let newView:UIView = .init()
                newView.backgroundColor =  UIColor(red: .random(in: 0...1),
                                                   green: .random(in: 0...1),
                                                   blue: .random(in: 0...1),
                                                   alpha: 1.0)
                newView.translatesAutoresizingMaskIntoConstraints = false
                newView.heightAnchor.constraint(equalToConstant: CGFloat.random(in: 50 ..< 100)).isActive = true
                views.append(newView)
            }
            
            self.tapVerticalView.updateSubViews(with: views)
        }
        
        let replaceLastSlideIn:UIAlertAction = .init(title: "Slide in replacing last item of 3 views. Will add three views, then the replacement", style: .default) { _ in
            self.addRandomViews(count: 3)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500)) {
                let newView:UIView = .init()
                newView.backgroundColor =  UIColor(red: .random(in: 0...1),
                                                   green: .random(in: 0...1),
                                                   blue: .random(in: 0...1),
                                                   alpha: 1.0)
                newView.translatesAutoresizingMaskIntoConstraints = false
                newView.heightAnchor.constraint(equalToConstant: CGFloat.random(in: 50 ..< 100)).isActive = true
                self.tapVerticalView.remove(at: 2, with: .init(for: .fadeOut))
                self.tapVerticalView.add(view: newView,at: 2, with: [.init(for: .bounceIn)])
            }
        }
        
        let replaceLastFadeIn:UIAlertAction = .init(title: "Fade in replacing last item of 3 views. Will add three views, then the replacement", style: .default) { _ in
            self.addRandomViews(count: 3)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500)) {
                let newView:UIView = .init()
                newView.backgroundColor =  UIColor(red: .random(in: 0...1),
                                                   green: .random(in: 0...1),
                                                   blue: .random(in: 0...1),
                                                   alpha: 1.0)
                newView.translatesAutoresizingMaskIntoConstraints = false
                newView.heightAnchor.constraint(equalToConstant: CGFloat.random(in: 50 ..< 100)).isActive = true
                self.tapVerticalView.remove(at: 2, with: .init(for: .fadeOut))
                self.tapVerticalView.add(view: newView,at: 2, with: [.init(for: .fadeIn)])
            }
        }
        
        let addFirstSlideIn:UIAlertAction = .init(title: "Slide item at the top. Will add 3 views, then animate an insertion", style: .default) { _ in
            self.addRandomViews(count: 3)
            let newView:UIView = .init()
            newView.backgroundColor =  UIColor(red: .random(in: 0...1),
                                               green: .random(in: 0...1),
                                               blue: .random(in: 0...1),
                                               alpha: 1.0)
            newView.translatesAutoresizingMaskIntoConstraints = false
            newView.heightAnchor.constraint(equalToConstant: CGFloat.random(in: 50 ..< 100)).isActive = true
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500)) {
                self.tapVerticalView.add(view: newView, at: 0, with: [.init(for: .bounceIn)])
            }
        }
        
        let addFirstFadeIn:UIAlertAction = .init(title: "Fade in item at the top. Will add 3 views, then animate an insertion", style: .default) { _ in
            self.addRandomViews(count: 3)
            let newView:UIView = .init()
            newView.backgroundColor =  UIColor(red: .random(in: 0...1),
                                               green: .random(in: 0...1),
                                               blue: .random(in: 0...1),
                                               alpha: 1.0)
            newView.translatesAutoresizingMaskIntoConstraints = false
            newView.heightAnchor.constraint(equalToConstant: CGFloat.random(in: 50 ..< 100)).isActive = true
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500)) {
                self.tapVerticalView.add(view: newView, at: 0, with: [.init(for: .fadeIn)])
            }
        }
        
        alertController.addAction(random)
        alertController.addAction(replaceLastSlideIn)
        alertController.addAction(replaceLastFadeIn)
        alertController.addAction(addFirstSlideIn)
        alertController.addAction(addFirstFadeIn)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func addRandomViews(count:Int) {
        var views:[UIView] = []
        for _ in 0..<count {
            let newView:UIView = .init()
            newView.backgroundColor =  UIColor(red: .random(in: 0...1),
                                               green: .random(in: 0...1),
                                               blue: .random(in: 0...1),
                                               alpha: 1.0)
            newView.translatesAutoresizingMaskIntoConstraints = false
            newView.heightAnchor.constraint(equalToConstant: CGFloat.random(in: 50 ..< 100)).isActive = true
            views.append(newView)
        }
        
        self.tapVerticalView.updateSubViews(with: views,and: .none)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension ToPresentAsPopupViewController: TapVerticalViewDelegate {
    
    func innerSizeChanged(to newSize: CGSize, with frame: CGRect) {
        //print("DELEGATE CALL BACK WITH SIZE \(newSize) and Frame of :\(frame)")
        guard let delegate = delegate else { return }
        delegate.changeHeight(to: newSize.height + frame.origin.y)
    }
    
}
