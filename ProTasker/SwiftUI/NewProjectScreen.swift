//
//  NewProjectScreen.swift
//  ProTasker
//
//  Created by ARTEM on 29.05.2023.
//

import PhotosUI
import SwiftUI
import Combine
import Firebase
import FirebaseStorage

struct NewProjectScreen: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.dismiss) var dismissWhileCreating
    
    @EnvironmentObject var projectManager: ProjectManager
    @EnvironmentObject var firestoreManger: FirestoreManager
    
    @State private var projectItem: PhotosPickerItem?
    @State private var projectImage: Image = Image("default_project")
    @State private var cancellable: AnyCancellable?
    @State private var projectName: String = ""
    
    @State private var showEmptyCreating = false
    @State private var isDownloading = false
    
    var body: some View {
        ZStack{
            NavigationStack{
                VStack{
                    projectImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(radius: 8)
                    
                    PhotosPicker("Select avatar", selection: $projectItem, matching: .images)
                    TextField("Project name",
                              text: $projectName)
                    //.textFieldStyle(.roundedBorder)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.custom("Apple SD Gothic Neo", size: 21))
                    .padding(10)
                    
                    Button(action: {
                        if !projectName.isEmpty{
                            self.isDownloading = true
                            uploadMedia(userIm:projectImage.asUIImage()) { url in
                                if let checked_url = url {
                                    projectManager.addProject(image_url: checked_url, nameProject: projectName, user_name: firestoreManger.username)
                                    self.isDownloading = false
                                    dismissWhileCreating()
                                }
                            }
                        }
                        else{
                            self.showEmptyCreating.toggle()
                        }
                    }, label: {
                        Text("Create project")
                            .font(.custom("Apple SD Gothic Neo", size: 20))
                            .bold()
                            .padding(10)
                    })
                    .buttonStyle(.borderedProminent)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    .alert(isPresented: $showEmptyCreating){
                        Alert(
                            title: Text("Empty Name"),
                            message: Text("Please fill the name of project"),
                            dismissButton: .default(Text("Ok"))
                        )
                    }
                }
                .onChange(of: projectItem) { _ in
                    Task {
                        if let data = try? await projectItem?.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data) {
                                projectImage = Image(uiImage: uiImage)
                                return
                            }
                        }
                        
                        print("Failed")
                    }
                }
                .toolbar{
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Image(systemName: "multiply")
                                .font(.system(size: 25))
                                .foregroundColor(.black)
                        })
                    }
                }
            }
            if isDownloading {
                // Add a blur effect to the background
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .blur(radius: 10)
                
                // Center the downloading view
                VStack {
                    Spacer()
                    
                    DownloadView()
                    
                    Spacer()
                }
                .padding()
            }
        }
        
    }
    
    func uploadMedia(userIm: UIImage,completion: @escaping (_ url: String?) -> Void) {
        let storage = Storage.storage()
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
        func currentTimeInMilliSeconds()-> Int{
                let currentDate = Date()
                let since1970 = currentDate.timeIntervalSince1970
                return Int(since1970 * 1000)
        }
}

struct NewProjectScreen_Previews: PreviewProvider {
    static var previews: some View {
        NewProjectScreen()
    }
}
