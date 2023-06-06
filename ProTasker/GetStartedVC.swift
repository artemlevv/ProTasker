//
//  GetStartedVC.swift
//  ProTasker
//
//  Created by ARTEM on 23.05.2023.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class GetStartedVC: UIViewController{
    
    //MARK: - IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //MARK: - IBActions
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showLogInVC(_ sender: Any) {
        if let presentingViewController = self.presentingViewController {
            self.dismiss(animated: true) {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let nextViewController = storyboard.instantiateViewController(withIdentifier: "LogInVC")
                        presentingViewController.present(nextViewController, animated: true, completion: nil)
                    }
        }
    }
    @IBAction func createAccount(_ sender: Any) {
        if let userDisplayName = nameTextField.text, !userDisplayName.isEmpty {
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!){ (user, error) in
                if error == nil{
                    self.createUser(userName: userDisplayName)
                    self.performSegue(withIdentifier: "signUpHomeSegue", sender: self)
                }
                else{
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        else{
            let alertController = UIAlertController(title: "Empty name", message: "Please fill name field", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    
    func createUser(userName: String) {
        let db = Firestore.firestore()
        guard let userUid = Auth.auth().currentUser?.uid else{ return }
        guard let userEmail = Auth.auth().currentUser?.email else {return}
        
        var image_url: String = ""
        
        uploadMedia(userIm: UIImage(imageLiteralResourceName: "default_user")) { url in
                    // Handle the completion of the upload
                if let checked_url = url {
                    image_url = checked_url
                    let docRef = db.collection("users").document(userUid)
                    docRef.setData(["name": userName,
                                    "mobile": "",
                                    "image": image_url,
                                    "id": userUid,
                                    "fcmToken": "",
                                    "email": userEmail]) { error in
                        
                        if let error = error {
                            print("Error writing document: \(error)")
                        } else {
                            print("User successfully written!")
                        }
                    }
                    } else {
                        print("Upload default image failed")
                    }
                }
    }
    func uploadMedia(userIm: UIImage,completion: @escaping (_ url: String?) -> Void) {
        let storage = Storage.storage()
        guard let userUid = Auth.auth().currentUser?.uid else {return}
        let storageRef = storage.reference().child("User\(currentTimeInMilliSeconds()).jpg")

        // Convert the image into JPEG and compress the quality to reduce its size
        let data = userIm.jpegData(compressionQuality: 0.2)

        // Change the content type to jpg. If you don't, it'll be saved as application/octet-stream type
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"

        // Upload the image
        if let data = data {
        storageRef.putData(data, metadata: metadata) { (metadata, error) in
        if let error = error {
            print("Error while uploading file: ", error)
        }

        if let metadata = metadata {
            print("Metadata: ", metadata)
            storageRef.downloadURL { url, error in
                                if let error = error {
                                    print("Error while retrieving download URL: ", error)
                                    completion(nil)
                                } else {
                                    completion(url?.absoluteString)
                                }
                            }
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func currentTimeInMilliSeconds()-> Int{
            let currentDate = Date()
            let since1970 = currentDate.timeIntervalSince1970
            return Int(since1970 * 1000)
    }
}
