//
//  ViewController.swift
//  ProTasker
//
//  Created by ARTEM on 23.05.2023.
//

import UIKit
import Firebase

class RegistrationVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool){
             super.viewDidAppear(animated)
             if Auth.auth().currentUser != nil {
               self.performSegue(withIdentifier: "alreadyLogInSegue", sender: nil)
            }
    }


}

