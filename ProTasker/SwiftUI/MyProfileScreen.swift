//
//  MyProfileScreen.swift
//  ProTasker
//
//  Created by ARTEM on 30.05.2023.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import Firebase
import PhotosUI
import Combine

struct MyProfileScreen: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    
    @State private var userItem: PhotosPickerItem?
    @State private var userImage: Image? = Image("default_project")
    @State private var cancellable: AnyCancellable?
    
    @State private var userName: String = ""
    @State private var userEmail: String = ""
    @State private var userPhone: String = ""
    @State private var userPhoto: String = ""
    
    @State private var showChangeUserDataAlert = false
    @State private var successUpdate = false
    @State private var errorUserDataChange = ""
    
    
    
    
    var body: some View {
        NavigationStack{
            VStack{
                //Image("default_user")
                userImage?
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 4)
                    .padding(20)
                
                PhotosPicker("Select avatar", selection: $userItem, matching: .images)
                
                HStack{
                    Text("Name")
                        .font(.system(size: 18))
                        .bold()
                    Spacer()
                }
                .padding(.leading, 20)
                
                TextField("Enter username", text: $userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                HStack{
                    Text("Email")
                        .font(.system(size: 18))
                        .bold()
                    Spacer()
                }
                .padding(.leading, 20)
                
                TextField("Enter email", text: $userEmail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                HStack{
                    Text("Phone")
                        .font(.system(size: 18))
                        .bold()
                    Spacer()
                }
                .padding(.leading, 20)
                
                TextField("Enter phone", text: $userPhone)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                
                Button(action: {
                    // updateUserInfo()
                    updateUser(userName: self.userName, userEmail: self.userEmail, userPhone: self.userPhone)
                }) {
                    Text("Update")
                        .foregroundColor(.white)
                        .font(.title2)
                        .bold()
                        .padding()
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                .alert(isPresented: $showChangeUserDataAlert){
                    Alert(
                        title: Text("Error"),
                        message: Text(errorUserDataChange),
                        dismissButton: .default(Text("Ok"))
                    )
                }
                .alert(isPresented: $successUpdate){
                    Alert(
                        title: Text("Succes Update"),
                        message: Text("Your data has been successfully updated"),
                        dismissButton: .default(Text("Ok"))
                    )
                }
                
                
                
                Spacer()
            }
            .padding(.top, 18)
            .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("My Profile")
                                .font(.system(size: 26))
                                .bold()
                                .foregroundColor(.white)
                        }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.blue, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: CustomBackButton())
        }
        .onAppear(){
            self.firestoreManager.getUserdata()
            loadImageFromURL()
            userName = firestoreManager.username
            userPhone = firestoreManager.userPhone
            userEmail = firestoreManager.userEmail
            userPhoto = firestoreManager.userPhoto
        }
        .onChange(of: userItem) { _ in
            Task{
                if let data = try? await userItem?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        userImage = Image(uiImage: uiImage)
                        return
                    }
                }
                
                print("Failed")
            }
        }
    }
    
    
    func updateUser(userName: String, userEmail: String, userPhone: String) {
        let db = Firestore.firestore()
        guard let userUid = Auth.auth().currentUser?.uid else {return}
        var image_url = ""

        Auth.auth().currentUser?.updateEmail(to: userEmail){ error in
            
            if let error = error {
                        print("Error updating email: \(error)")
                        self.showChangeUserDataAlert.toggle()
                        self.errorUserDataChange = error.localizedDescription
                        return // Exit the function if there's an error updating the email
                    }
            uploadMedia(userIm:userImage.asUIImage()) { url in
                        // Handle the completion of the upload
                if let checked_url = url {
                    image_url = checked_url
                    let docRef = db.collection("users").document(userUid)
                    
                    docRef.updateData(["email": userEmail, "name": userName, "mobile": userPhone, "image": image_url]) { error in
                        if let error = error {
                            print("Error updating document: \(error)")
                        } else {
                            print("Document successfully updated!")
                            self.successUpdate.toggle()
                        }
                    }
                } else {
                    print("Update user image failed")
                }
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
        func currentTimeInMilliSeconds()-> Int{
                let currentDate = Date()
                let since1970 = currentDate.timeIntervalSince1970
                return Int(since1970 * 1000)
        }
    }
    
    func loadImageFromURL() {
        guard let url = URL(string: firestoreManager.userPhoto) else {
               return // Invalid URL
           }
           
           cancellable = URLSession.shared.dataTaskPublisher(for: url)
               .map { UIImage(data: $0.data) }
               .compactMap { $0 }
               .map { Image(uiImage: $0) }
               .replaceError(with: nil)
               .receive(on: DispatchQueue.main)
               .assign(to: \.userImage, on: self)
    }
}

struct MyProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        MyProfileScreen()
    }
}




/*
 *** Simple function for updating user info ***

 .onAppear {
             configureFirebase()
             fetchUserInfo()
         }
 
 func fetchUserInfo() {
       let db = Firestore.firestore()
       let userRef = db.collection("users").document("userID")

       userRef.getDocument { document, error in
           if let document = document, document.exists {
               let data = document.data()
               if let name = data?["name"] as? String {
                   userName = name
               }
               if let email = data?["email"] as? String {
                   userEmail = email
               }
               if let phone = data?["phone"] as? String {
                   userPhone = phone
               }
           }
       }
   }

   func updateUserInfo() {
       let db = Firestore.firestore()
       let userRef = db.collection("users").document("userID")

       userRef.updateData([
           "name": userName,
           "email": userEmail,
           "phone": userPhone
       ]) { error in
           if let error = error {
               print("Error updating user information: \(error.localizedDescription)")
           } else {
               print("User information updated successfully!")
           }
       }
   }
 
 
 
 
 
 
 */
extension View {
// This function changes our View to UIView, then calls another function
// to convert the newly-made UIView to a UIImage.
    public func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        
 // Set the background to be transparent incase the image is a PNG, WebP or (Static) GIF
        controller.view.backgroundColor = .clear
        
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
        
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        
// here is the call to the function that converts UIView to UIImage: `.asUIImage()`
        let image = controller.view.asUIImage()
        controller.view.removeFromSuperview()
        return image
    }
}

extension UIView {
// This is the function to convert UIView to UIImage
    public func asUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
