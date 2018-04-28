//
//  MainViewController.swift
//  KanjiHack
//
//  Created by Anthony Marchenko on 4/28/18.
//  Copyright © 2018 Anthony Marchenko. All rights reserved.
//

import UIKit

enum removeAnimation {
    case top
    case down
}

class MainViewController: UIViewController {

    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var answerView: UIView!
    
    @IBOutlet weak var rightEmojiLabel: UILabel!
    @IBOutlet weak var wrongEmojiLabel: UILabel!
    
    var panGesture = UIPanGestureRecognizer()
    var defaultCenter = CGPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addTapGestureRecognizerForQuestionView()
        addPanGestureForAnswerView()
        defaultCenter = answerView.center
        
        resetViews();
    }
    
    func addTapGestureRecognizerForQuestionView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        questionView.addGestureRecognizer(tap)
    }
    
    func addPanGestureForAnswerView() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        answerView.addGestureRecognizer(panGesture)
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
                removeAnswerCardWithAnimation(animationType: removeAnimation.down)
            } else if answerView.center.y < 100 {
                removeAnswerCardWithAnimation(animationType: removeAnimation.top)
            } else {
                
                UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.answerView.center = self.defaultCenter
                    self.wrongEmojiLabel.alpha = 0
                    self.rightEmojiLabel.alpha = 0
                }, completion: nil)
            }
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
       
        if animationType == removeAnimation.down {
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
        
        UIView.animate(withDuration: 2, animations: {
            self.questionView.alpha = 1
        }, completion: {
            finished in
        })
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
