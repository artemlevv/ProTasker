//
//  ProjectScreen.swift
//  ProTasker
//
//  Created by ARTEM on 04.06.2023.
//

import SwiftUI
import Firebase

struct ProjectScreen: View {
    @ObservedObject var projectManager: ProjectManager
    @EnvironmentObject var firestoreManger: FirestoreManager
    @Environment(\.dismiss) var dismiss
    

    @State var proj_index: Int
    @State var addingList = false
    @State var showdeleteProjectAlert = false
    @State var listNameAdded = ""
    let screenWidth = UIScreen.main.bounds.size.width
    
    @State var taskList: [TaskT] = []
    
    //MARK: - Bool
    @State var emptyAddedTask = false
    

    
    var body: some View {
        NavigationStack{
            VStack{
                ScrollView(.horizontal, showsIndicators: false){
                    LazyHStack{
                        ForEach(self.taskList.indices, id: \.self) { list_index in
                            TaskList(taskIndex: list_index, proj_index: proj_index, taskList: $taskList, projectManager: projectManager)
                                    .environmentObject(firestoreManger)
                                    .frame(width: screenWidth * 0.8)
                            
                        }
                        addingListProcess()
                            .padding(.top, 15)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                    }
                }
            }
        }
        .padding(.top, 18)
        .toolbar{
               ToolbarItem(placement: .principal) {
                        
                        Text("\(projectManager.projectList[proj_index].name)")
                            .font(.custom("Apple SD Gothic Neo", size: 21))
                            .bold()
                            .foregroundColor(.white)
                    }
                ToolbarItem(placement: .navigationBarTrailing){
                    Menu {
                            NavigationLink(destination: PeopleAddingView(projectManager: projectManager, proj_index: proj_index)
                                .environmentObject(firestoreManger)) {
                                   Text("People")
                                    PeopleAddingView(projectManager: projectManager, proj_index: proj_index)
                                        .environmentObject(firestoreManger)
                            }
                            .buttonStyle(.plain)
                            Button(role: .destructive, action: {
                                showdeleteProjectAlert.toggle()
                            }, label: {
                                Text("Delete project")
                            })
                    
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .imageScale(.large)
                            .foregroundColor(.white)
                    }
                }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: CustomBackButton())
        .alert(isPresented: $showdeleteProjectAlert) {
                Alert(
                    title: Text("Delete Project"),
                    message: Text("Are you sure to delete this project?"),
                    primaryButton: .default(Text("Yes")) {
                        dismiss()
                        projectManager.deleteProject(project: projectManager.projectList[proj_index])
                        projectManager.getProjectdata()
                },
                    secondaryButton: .cancel(Text("No")) {}
                )
            }
        .onAppear(){
            self.projectManager.getProjectdata()
            self.taskList = self.projectManager.projectList[proj_index].taskList
        }
    }
    
    @ViewBuilder
    func addingListProcess() -> some View{
        VStack{
            if !addingList{
                Button(action: {
                    addingList = true
                }, label: {
                    HStack{
                        Spacer()
                        HStack{
                            Image(systemName: "plus")
                            Text("Add list")
                                .padding(.top, 15)
                                .padding(.bottom, 15)
                        }
                        Spacer()
                    }
                    Spacer()
                })
                .background(Color.backTask)
                .frame(width: screenWidth * 0.7)
            } else {
                HStack{
                    Button(action: {
                        addingList = false
                    }, label: {
                        Image(systemName: "xmark.square")
                            .font(.system(size: 30))
                            .padding(.leading, 10)
                    })
                    TextField("Enter list name", text: $listNameAdded)
                        .padding()
                    Button(action: {
                        if !emptyAddedTask{
                            guard let userUid = Auth.auth().currentUser?.uid else {return}
                            self.projectManager.projectList[proj_index].taskList.append(TaskT(cards: [], createdBy: userUid, title: listNameAdded))
                            self.projectManager.updateProject(project: projectManager.projectList[self.proj_index])
                            self.projectManager.getProjectdata()
                            self.taskList = self.projectManager.projectList[proj_index].taskList
                            addingList = false
                            listNameAdded = ""
                        }
                        else{
                            emptyAddedTask.toggle()
                        }
                    }, label: {
                        Image(systemName: "checkmark.square.fill")
                            .font(.system(size: 30))
                            .padding(.trailing, 10)
                    })
                    .alert(isPresented: $emptyAddedTask){
                        Alert(
                            title: Text("Empty Name"),
                            message: Text("Please fill the list name"),
                            dismissButton: .default(Text("Ok"))
                        )
                    }
                    Spacer()
                }
            }
            Spacer()
        }
    }
}

struct ListTask: Hashable{
    var headername: String
    var cards: [Card]
}
