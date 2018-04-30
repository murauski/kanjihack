//
//  SettingsViewController.swift
//  KanjiHack
//
//  Created by Anthony Marchenko on 4/28/18.
//  Copyright © 2018 Anthony Marchenko. All rights reserved.
//

import UIKit
import SVProgressHUD

class SettingsViewController: UIViewController {

    @IBOutlet weak var updateButton: UIButton!
    
    var dataTask: URLSessionDataTask? = nil
    var questions = [QuestionDTO]()
    
    @IBOutlet weak var updatedTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateButton.layer.cornerRadius = 5
        updateButton.layer.masksToBounds = true
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLastSynchronizationLabel()
    }
    
    func updateLastSynchronizationLabel() {
        
            if Settings.sharedManager.getUpdatedTime() == nil {
                self.updatedTimeLabel.text = "Updated: Never"
            } else {
                
                let dateFormatterGet = DateFormatter()
                dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                
                if let date = Settings.sharedManager.getUpdatedTime(){
                     self.updatedTimeLabel.text = "Updated: \(dateFormatterGet.string(from: date))"
                } else {
                    print("There was an error decoding the string")
                }
            }
    }
    
    // MARK: - IBActions
    
    @IBAction func closeButtonDidPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func updateButtonDidPressed(_ sender: UIButton) {
        
        guard let url = URL(string: "https://script.google.com/macros/s/AKfycbz9OoDJYQxYRjzfmqzV_BnXc3BLkZxMN3MKNTWMU6mw8iIVHT0G/exec") else {
            print("Error: cannot create URL")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        SVProgressHUD.show(withStatus: "Updating...")
        
        questions = [QuestionDTO]()
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            SVProgressHUD.dismiss()
            // check for any errors
            guard error == nil else {
                print("error calling GET")
                print(error!)
                
                let alertController = UIAlertController(title: "error calling GET", message:
                    "Not so good", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {

                
                guard let todo = try JSONSerialization.jsonObject(with: responseData, options: []) as? [AnyObject] else {
                        print("error trying to convert data to JSON")
                        return
                }
                
                for item in todo {
                    
                    if let jsonResult = item as? Dictionary<String, String> {
                        // do whatever with jsonResult
                        
                        let hint1 = String(describing: jsonResult["hint1"]!)
                        let hint2 = String(describing: jsonResult["hint2"]!)
                        let value = String(describing: jsonResult["value"]!)
                        let question = QuestionDTO(hint1: hint1, hint2: hint2, value: value)
                        
                        self.questions.append(question)
                    }
                    
                }

                DispatchQueue.main.sync {
                    self.saveQuestionsToDb()
                    self.updateLastSynchronizationLabel()
                }
                
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
       
    }
    
    @IBAction func resetButtonDidPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Reset all data", message:
            "This will delete all your data from DB", preferredStyle: UIAlertControllerStyle.alert)

        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive, handler: { (action) in
            SVProgressHUD.show(withStatus: "Reseting...")
            CoreDataManager.sharedManager.resetDB()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                SVProgressHUD.dismiss()
                Settings.sharedManager.resetUpdatedTime()
                self.updateLastSynchronizationLabel()
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    func saveQuestionsToDb() {
        let statusDTO = CoreDataManager.sharedManager.saveNewQuestions(questions: questions)
        
        let alertController = UIAlertController(title: "Success", message:
            "Added: \(statusDTO.added)\nUpdated:\(statusDTO.updated)\nDeleted:\(statusDTO.deleted)\n\nTotal:\(statusDTO.total)", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
        Settings.sharedManager.setUpdatedTime()
    }
}
