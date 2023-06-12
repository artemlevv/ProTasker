//
//  FirestoreManager.swift
//  ProTasker
//
//  Created by ARTEM on 01.06.2023.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

class FirestoreManager: ObservableObject{
    @Published var username: String = ""
    @Published var userEmail: String = ""
    @Published var userPhone: String = ""
    @Published var userPhoto: String = ""
    
    @Published var userList: [User] = []
    
    private var db = Firestore.firestore()
    
    func getUserdata() {
        guard let userUid = Auth.auth().currentUser?.uid else {return}
        
        db.collection("users").document(userUid).addSnapshotListener{ (querySnapshot, error) in
            if let querySnapshot = querySnapshot, querySnapshot.exists{
                let data = querySnapshot.data()
                if let data = data {
                    print("data", data)
                    self.username = data["name"] as? String ?? ""
                    self.userEmail = data["email"] as? String ?? ""
                    self.userPhone = data["mobile"] as? String ?? ""
                    self.userPhoto = data["image"] as? String ?? ""
                }
            }
            
        }
    }
    func getAllUsersdata(){
            
            db.collection("users").addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                self.userList = documents.compactMap { queryDocumentSnapshot -> User? in
                    let data = queryDocumentSnapshot.data()
                    let email = data["email"] as? String ?? ""
                    let fcmToken = data["fcmToken"] as? String ?? ""
                    let id = data["id"] as? String ?? ""
                    let image = data["image"] as? String ?? ""
                    let mobile = data["mobile"] as? String ?? ""
                    let name = data["name"] as? String ?? ""
                    return User(email: email, fcmToken: fcmToken, id: id, image: image, mobile: mobile, name: name)
                }
            }
    }

}




struct User{
    var email: String
    var fcmToken: String
    var id: String
    var image: String
    var mobile: String
    var name: String
}
