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
      
        getCurrentLevel()
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
    
    func getCurrentLevel() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Question")
        request.returnsObjectsAsFaults = false
        let sectionSortDescriptor = NSSortDescriptor(key: "score", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        request.sortDescriptors = sortDescriptors
        request.fetchLimit = 1
        
        do {
            let result = try managedContext.fetch(request)
            let questions = (result as? [Question])!

            guard questions.first != nil else {
                currentLevel = 0
                levelLabel.text = "Level \(currentLevel)"
                return
            }
            currentLevel =  Int(abs((questions.first?.score)!))
            levelLabel.text = "Level \(currentLevel)"

            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Question")
            fetchRequest.predicate = NSPredicate(format: "score == %i", currentLevel)

            do {

                let questionWithMinScoreCount = try managedContext.count(for: fetchRequest)

                
                let totalQuestionsCount = NSFetchRequest<NSFetchRequestResult>(entityName: "Question")
                do {
                    let totalScoreCount = try managedContext.count(for: totalQuestionsCount)
                    
                     percentageLabel.text = "\(100*questionWithMinScoreCount/totalScoreCount)%"
                } catch {
                    print("hello world")
                }

            } catch {
                print("Failed 2 ")
            }

        } catch {
            print("Failed")
        }
        
    }
}

