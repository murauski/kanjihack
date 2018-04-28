//
//  MainViewController.swift
//  KanjiHack
//
//  Created by Anthony Marchenko on 4/28/18.
//  Copyright © 2018 Anthony Marchenko. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var answerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //create a new button
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        questionView.addGestureRecognizer(tap)
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {

        answerView.alpha = 0
        UIView.animate(withDuration: 0.15, animations: {
            self.questionView.alpha = 0
        }, completion: {
            finished in
            //self.myView.isHidden = false
            self.showAnswerViewWithAnimation()
        })
    }
    
    func showAnswerViewWithAnimation() {
        UIView.animate(withDuration: 0.15, animations: {
            self.answerView.alpha = 1
        }, completion: {
            finished in
            //self.myView.isHidden = false
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didPressedSettingButton(_ sender: UIBarButtonItem) {
        let settingViewControler = storyboard?.instantiateViewController(withIdentifier: "SettingViewControllerKey") as! SettingsViewController
       // navigationController.pre
        self.present(settingViewControler, animated: true, completion: nil)
      //  navigationController?.pushViewController(mainViewController,
                                             //    animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
