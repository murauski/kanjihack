//
//  ViewController.swift
//  KanjiHack
//
//  Created by Anthony Marchenko on 4/28/18.
//  Copyright © 2018 Anthony Marchenko. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startButtonDidPressed(_ sender: UIButton) {
        let mainViewController = storyboard?.instantiateViewController(withIdentifier: "mainViewControllerKey") as! MainViewController
        navigationController?.pushViewController(mainViewController,
                                                 animated: true)
    }
    
    
}

