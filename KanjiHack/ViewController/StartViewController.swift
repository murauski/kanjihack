//
//  ViewController.swift
//  KanjiHack
//
//  Created by Anthony Marchenko on 4/28/18.
//  Copyright © 2018 Anthony Marchenko. All rights reserved.
//

import UIKit
import CoreData

class StartViewController: UIViewController {
    
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    var currentLevel = 0
    var currentPercentage = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        continueButton.layer.cornerRadius = 5
        continueButton.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
        updateProgressValues()
    }
    
    //MARK : IBActions
    
    @IBAction func startButtonDidPressed(_ sender: UIButton) {
        let mainViewController = storyboard?.instantiateViewController(withIdentifier: "mainViewControllerKey") as! MainViewController
        navigationController?.pushViewController(mainViewController,
                                                 animated: true)
    }
    
    @IBAction func didPressedSettingButton(_ sender: UIBarButtonItem) {
        let settingViewControler = storyboard?.instantiateViewController(withIdentifier: "SettingViewControllerKey") as! SettingsViewController
        self.present(settingViewControler, animated: true, completion: nil)
    }
    
    func updateProgressValues() {
        let currentLevel = CoreDataManager.sharedManager.getCurrentLevel()
        levelLabel.text = "Level \(abs(currentLevel))"
        
        let questionWithCurrentScoreCount = CoreDataManager.sharedManager.getQuestionsCountForLevel(level: currentLevel)
        let totalQuestonsCount = CoreDataManager.sharedManager.getTotalQuestionsCount()
        
        guard totalQuestonsCount != 0 else {
            levelLabel.text = "Load Data"
            percentageLabel.text = "from Setting"
            return
        }
        
        percentageLabel.text = "\(Int((Double(questionWithCurrentScoreCount)/Double(totalQuestonsCount)*100)))%"
        
        if currentLevel == 0 {
            levelLabel.text = "Let's play!"
            percentageLabel.text = ""
        }
        
        //New level special case
        if questionWithCurrentScoreCount == 0 {
           levelLabel.text = "Level \(abs(currentLevel) + 1)"
           percentageLabel.text = "0%"
        }
        
    }
}

