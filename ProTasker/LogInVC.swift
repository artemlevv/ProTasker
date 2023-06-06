//
//  LogIn.swift
//  ProTasker
//
//  Created by ARTEM on 23.05.2023.
//

import UIKit
import Firebase

class LogInVC: UIViewController{
    
    //MARK: - IBOutlet
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //MARK: - IBActions
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func confirmLogIn(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
           if error == nil{
             self.performSegue(withIdentifier: "logInHomeSegue", sender: self)
                          }
            else{
             let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
             let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            
              alertController.addAction(defaultAction)
              self.present(alertController, animated: true, completion: nil)
                 }
        }
    }
    @IBAction func showGetStarted(_ sender: Any) {
        if let presentingViewController = self.presentingViewController {
            self.dismiss(animated: true) {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with the name of your storyboard
                        let nextViewController = storyboard.instantiateViewController(withIdentifier: "GetStartedVC") // Replace "NextViewControllerIdentifier" with the actual identifier of your view controller
                        presentingViewController.present(nextViewController, animated: true, completion: nil)
                    }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}

