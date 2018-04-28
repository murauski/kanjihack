//
//  SettingsViewController.swift
//  KanjiHack
//
//  Created by Anthony Marchenko on 4/28/18.
//  Copyright © 2018 Anthony Marchenko. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController {

    @IBOutlet weak var updateButton: UIButton!
    
    var dataTask: URLSessionDataTask? = nil
    var questions = [QuestionDTO]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateButton.layer.cornerRadius = 5
        updateButton.layer.masksToBounds = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET on /todos/1")
                print(error!)
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
                        //TODO: Add Score
                    }
                    
                }

                self.saveQuestionsToDb()
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
       
    }
    
    func saveQuestionsToDb() {
        
        DispatchQueue.main.async {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.persistentContainer.viewContext
            let userEntity = NSEntityDescription.entity(forEntityName: "Question", in: managedContext)
            
            for item in self.questions {
                let newQuestion = NSManagedObject(entity: userEntity!, insertInto: managedContext)
                newQuestion.setValue(item.hint1, forKey: "hint1")
                newQuestion.setValue(item.hint2, forKey: "hint2")
                newQuestion.setValue(item.value, forKey: "value")
                newQuestion.setValue(0, forKey: "score")
                
            }
            
            do {
                try managedContext.save()
                
                let alertController = UIAlertController(title: "Everyting is good", message:
                    "Added: Updated \n TODO", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
                
            } catch {
                print("Failed saving")
            }
        }
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
