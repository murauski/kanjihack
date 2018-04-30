//
//  MainViewController.swift
//  KanjiHack
//
//  Created by Anthony Marchenko on 4/28/18.
//  Copyright © 2018 Anthony Marchenko. All rights reserved.
//

import UIKit
import CoreData

var kDeckSizeLimit = 3

enum removeAnimation {
    case correct
    case wrong
}

class MainViewController: UIViewController {

    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var answerView: UIView!
    
    @IBOutlet weak var rightEmojiLabel: UILabel!
    @IBOutlet weak var wrongEmojiLabel: UILabel!
    
    @IBOutlet weak var hint1: UILabel!
    @IBOutlet weak var hint2: UILabel!
    @IBOutlet weak var value: UILabel!
    
    @IBOutlet weak var pagerLabel: UILabel!
    
    var panGesture = UIPanGestureRecognizer()
    var defaultCenter = CGPoint()
    var currentQuestion = Question()
    var currentDeck = [Question]()

    override func viewDidLoad() {
        super.viewDidLoad()

        addTapGestureRecognizerForQuestionView()
        addPanGestureForAnswerView()
        addTapGestureRecognizerForAnswerView()
        
        defaultCenter = answerView.center
        
        resetViews();
        generateDeck()
        mapLabelsWithCurrentQuestion()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if CoreDataManager.sharedManager.getTotalQuestionsCount() == 0 {
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func addTapGestureRecognizerForQuestionView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapOnQuestionView(_:)))
        questionView.addGestureRecognizer(tap)
    }
    
    func addPanGestureForAnswerView() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        answerView.addGestureRecognizer(panGesture)
    }
    
    func addTapGestureRecognizerForAnswerView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapOnAnswerView(_:)))
        answerView.addGestureRecognizer(tap)
    }

    @objc func draggedView(_ sender: UIPanGestureRecognizer){
        self.view.bringSubview(toFront: answerView)
        let translation = sender.translation(in: self.view)

        answerView.center = CGPoint(x: answerView.center.x, y: answerView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
        
        print("x - \(answerView.center.x) y - \(answerView.center.y)")
        handleWrongAnswerLogic()
        handleRightAnswerLogic()
        
        if sender.state == UIGestureRecognizerState.ended {
            if answerView.center.y - defaultCenter.y > 132 {
                removeAnswerCardWithAnimation(animationType: removeAnimation.correct)
                currentQuestion.score = currentQuestion.score - 1
            } else if answerView.center.y < 100 {
                removeAnswerCardWithAnimation(animationType: removeAnimation.wrong)
                currentQuestion.score = currentQuestion.score + 1
            } else {
                UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.answerView.center = self.defaultCenter
                    self.wrongEmojiLabel.alpha = 0
                    self.rightEmojiLabel.alpha = 0
                }, completion: nil)
            }
            
            
           CoreDataManager.sharedManager.saveContext()
            
        }
    }
    
    func handleWrongAnswerLogic() {
        let wrongAnswerAlpha = defaultCenter.y - answerView.center.y
        switch wrongAnswerAlpha {
        case 100... :
            wrongEmojiLabel.alpha = 1
        case 0 ..< 100:
            wrongEmojiLabel.alpha = wrongAnswerAlpha/100
        default:
            wrongEmojiLabel.alpha = 0
        }
    }
    
    func handleRightAnswerLogic() {
        let rightAnswerAlpha = answerView.center.y - defaultCenter.y
        switch rightAnswerAlpha {
        case 100... :
            rightEmojiLabel.alpha = 1
        case 0 ..< 100:
            rightEmojiLabel.alpha = rightAnswerAlpha/100
        default:
            rightEmojiLabel.alpha = 0
        }
    }
    
    func removeAnswerCardWithAnimation(animationType: removeAnimation) {
       
        var yCoordinate = -300
       
        if animationType == removeAnimation.correct {
            yCoordinate = Int(self.view.frame.size.height + 300)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.answerView.center = CGPoint(x: self.answerView.center.x, y: CGFloat(yCoordinate))
        }, completion: {
            finished in
            self.resetViewWithAnimation()
        })
    }
    
    func resetViews() {
        
        self.answerView.alpha = 0
        self.questionView.alpha = 1
        
        rightEmojiLabel.alpha = 0
        wrongEmojiLabel.alpha = 0
        
        self.view.bringSubview(toFront: answerView)
        self.view.bringSubview(toFront: questionView)
        
        self.questionView.center = defaultCenter
        self.answerView.center = defaultCenter
        
    }
    
    func resetViewWithAnimation() {
        resetViews()
        
        self.answerView.alpha = 0
        self.questionView.alpha = 0
        
        self.pushNext()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.questionView.alpha = 1
        }, completion: {
            finished in
        })
    }
    
    @objc func handleTapOnQuestionView(_ sender: UITapGestureRecognizer) {

        answerView.alpha = 0
        UIView.animate(withDuration: 0.15, animations: {
            self.questionView.alpha = 0
        }, completion: {
            finished in
            //self.myView.isHidden = false
            self.showAnswerViewWithAnimation()
        })
    }
    
    @objc func handleTapOnAnswerView(_ sender: UITapGestureRecognizer) {
        
        answerView.alpha = 0
        questionView.alpha = 0
        
        UIView.animate(withDuration: 0.15, animations: {
            self.questionView.alpha = 1
        }, completion: {
            finished in
        })
    }
    
    func showAnswerViewWithAnimation() {
        UIView.animate(withDuration: 0.15, animations: {
            self.answerView.alpha = 1
        }, completion: {
            finished in
        })
    }
    

    @IBAction func didPressedSettingButton(_ sender: UIBarButtonItem) {
        let settingViewControler = storyboard?.instantiateViewController(withIdentifier: "SettingViewControllerKey") as! SettingsViewController
        self.present(settingViewControler, animated: true, completion: nil)
    }
    
    //MARK : Model helper
    
    func generateDeck() {
        
        currentDeck = CoreDataManager.sharedManager.getCurrentDeckWithLimit(limit: kDeckSizeLimit)
        mapLabelsWithCurrentQuestion()
    }
    
    func pushNext() {
        currentDeck.removeFirst()
        mapLabelsWithCurrentQuestion()
    }
    
    func mapLabelsWithCurrentQuestion() {
        let question = currentDeck.first
        
        guard question != nil else {
            self.navigationController!.popToRootViewController(animated: true)
            return
        }
        
        hint1.text = question?.hint1 ?? ""
        hint2.text = question?.hint2 ?? ""
        value.text = question?.value ?? ""
        currentQuestion = question!
        
        pagerLabel.text = "\(kDeckSizeLimit - currentDeck.count + 1) of \(kDeckSizeLimit)"
    }
}
