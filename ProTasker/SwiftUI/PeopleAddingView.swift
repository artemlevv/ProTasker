//
//  PeopleAddingView.swift
//  ProTasker
//
//  Created by ARTEM on 05.06.2023.
//

import SwiftUI
import Firebase

struct PeopleAddingView: View {
    @ObservedObject var projectManager: ProjectManager
    @EnvironmentObject var firestoreManger: FirestoreManager

    @State var proj_index: Int
    @State var addingPeopleMod = false
    @State var errorAddingUser = false
    @State var userEmail: String = ""
    
    let userUid = Auth.auth().currentUser?.uid ?? ""
    
    var body: some View {
        VStack{
            ScrollView {
                LazyVStack {
                    if projectManager.projectList.count > proj_index{
                        ForEach(projectManager.projectList[proj_index].asignedTo, id: \.self) { id_user in
                            let us = firestoreManger.userList.filter({$0.id == id_user})
                            peopleRow(id_user: id_user, imageUrl: us[0].image, personName: us[0].name, personEmail: us[0].email)

                            
                        }
                    }
                }
            }
        }
        .onAppear(){
            self.firestoreManger.getAllUsersdata()
        }
        .toolbar{
                ToolbarItem(placement: .principal) {
                        
                        Text("People")
                            .font(.custom("Apple SD Gothic Neo", size: 21))
                            .bold()
                            .foregroundColor(.white)
                    }
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action: {
                        addingPeopleMod.toggle()
                    }, label: {
                        Image(systemName: "plus")
                            .imageScale(.large)
                            .foregroundColor(.white)
                    })
                }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: CustomBackButton())
        .alert("Add User", isPresented: $addingPeopleMod) {
                    TextField("Enter user email", text: $userEmail)
                        .textInputAutocapitalization(.never)
                    Button("OK", action: addUserByEmail)
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Enter user email")
                }
        .alert(isPresented: $errorAddingUser){
                    Alert(
                        title: Text("Error"),
                        message: Text("No user found with this email"),
                        dismissButton: .default(Text("Ok"))
                    )
                }
    }
    @ViewBuilder
    func peopleRow(id_user: String, imageUrl: String, personName: String, personEmail: String) -> some View{
        HStack{
            AsyncImage(url: URL(string: imageUrl)){ image in
                image.image?
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 4)
            VStack{
                HStack{
                    Text(personName)
                        .font(.custom("Apple SD Gothic Neo", size: 16))
                        .bold()
                        .foregroundColor(.black)
                    Spacer()
                }
                HStack{
                    Text("\(personEmail)")
                        .font(.custom("Apple SD Gothic Neo", size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            Spacer()
            if id_user != userUid{
                Button(action: {
                    projectManager.projectList[proj_index].asignedTo =  projectManager.projectList[proj_index].asignedTo.filter { $0 != id_user }
                    self.projectManager.updateProject(project: projectManager.projectList[proj_index])
                    self.projectManager.getProjectdata()
                }, label: {
                    Image(systemName: "xmark.bin.fill")
                })
            }
        }
        .padding(15)
    }
    func addUserByEmail(){
        let us = firestoreManger.userList.filter({$0.email == userEmail})
        if !us.isEmpty{
            self.projectManager.projectList[proj_index].asignedTo.append(us[0].id)
            self.projectManager.updateProject(project: projectManager.projectList[proj_index])
            firestoreManger.getAllUsersdata()
        }
        else{
            errorAddingUser.toggle()
        }
        self.userEmail = ""
    }
}

struct PeopleAddingView_Previews: PreviewProvider {
    static var previews: some View {
        PeopleAddingView(projectManager: ProjectManager(), proj_index: 0)
    }
}
