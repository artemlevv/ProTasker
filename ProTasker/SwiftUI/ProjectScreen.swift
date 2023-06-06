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

    @State var proj_index: Int
    @State var addingList = false
    @State var listNameAdded = ""
    let screenWidth = UIScreen.main.bounds.size.width
    
    //MARK: - Bool
    @State var emptyAddedTask = false
    
    //MARK: - Timer for updating firebase
    @State var currentDate = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    var body: some View {
        VStack{
            ScrollView(.horizontal, showsIndicators: false){
                LazyHStack{
                    ForEach(projectManager.projectList[proj_index].taskList.indices, id: \.self) { list_index in
                        TaskListView(projectManager: projectManager, taskIndex: list_index, proj_index: proj_index)
                            .frame(width: screenWidth * 0.8)
                            .environmentObject(firestoreManger)
                    }
                    addingListProcess()
                        .padding(.top, 15)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
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
                    
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .imageScale(.large)
                            .foregroundColor(.white)
                    }
                }
        }
        .onReceive(timer) { input in
            self.projectManager.getProjectdata()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: CustomBackButton())
        
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
                            Text("Add card")
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
                            addingList = false
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

struct ProjectScreen_Previews: PreviewProvider {
    static var previews: some View {
        var test = Project(id: "", asignedTo: ["hh"], createdBy: "name", image: "im", name: "Project", taskList: [])
        ProjectScreen(projectManager: ProjectManager(), proj_index: 0)
    }
}

struct ListTask: Hashable{
    var headername: String
    var cards: [Card]
}
