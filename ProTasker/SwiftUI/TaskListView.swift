//
//  TaskListView.swift
//  ProTasker
//
//  Created by ARTEM on 04.06.2023.
//

import SwiftUI
import Firebase

struct TaskListView: View {
    @ObservedObject var projectManager: ProjectManager
    @EnvironmentObject var firestoreManger: FirestoreManager
    
    @State var addingTask = false
    @State var emptyAddedTask = false
    @State var listTitleInEditMode = false
    
    @State var taskNameEditing = ""
    @State var taskNameAdded = ""
    @State var taskIndex: Int
    @State var proj_index: Int
    
    @State var currentDate = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    var body: some View {
        VStack{
            HStack{
                if !listTitleInEditMode{
                    Text(projectManager.projectList[proj_index].taskList[taskIndex].title)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .padding(.top, 15)
                        .padding(.bottom, 15)
                }
                else{
                    TextField("Edit task list title", text: $taskNameEditing)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .padding(.top, 15)
                        .padding(.bottom, 15)
                }
                Spacer()
                Button(action: {
                            self.listTitleInEditMode.toggle()
                    if !listTitleInEditMode{
                        self.projectManager.projectList[proj_index].taskList[taskIndex].title = taskNameEditing
                        self.projectManager.updateProject(project: projectManager.projectList[proj_index])
                    }
                        }) {
                            Image(systemName: listTitleInEditMode ? "checkmark" : "pencil")
                                .font(.system(size: 25))
                                .fontWeight(.semibold)
                                .padding(.trailing, 15)
                                .foregroundColor(Color.blue)
                }
                if(!listTitleInEditMode){
                    Button(action: {
                        self.projectManager.projectList[proj_index].taskList.remove(at: taskIndex)
                        self.projectManager.updateProject(project: projectManager.projectList[proj_index])
                           }) {
                    Image(systemName: "trash")
                            .font(.system(size: 25))
                            .fontWeight(.semibold)
                            .padding(.trailing, 20)
                            .foregroundColor(Color.blue)
                               
                    }
                }
            }
            .background(Color.backTask)
            .padding(.top, 15)
                ScrollView{
                    LazyVStack {
                        ForEach(projectManager.projectList[proj_index].taskList[taskIndex].cards.indices, id: \.self) { card_index in
                            
                            NavigationLink(
                                destination: CardDetailScreen(projectManager: projectManager, proj_index: proj_index, taskIndex: taskIndex, cardIndex: card_index)
                                                .environmentObject(firestoreManger)
                            ) {
                                TaskView(projectManager: projectManager, proj_index: proj_index, taskIndex: taskIndex, cardIndex: card_index)
                                    .padding(8)
                                }
                        }
                    }
                    .padding(5)
                    .background(Color.backListTask)
                    addingProcess()
                        .padding(.bottom, 15)
                    HStack { Spacer() }
                }
                .clipped()
                .padding(.top, -8)
        }
        .padding(.leading, 20)
        .padding(.trailing, 20)
        .onAppear(){
            self.projectManager.getProjectdata()
        }
        .onReceive(timer) { input in
            if !listTitleInEditMode{
                self.taskNameEditing = projectManager.projectList[proj_index].taskList[taskIndex].title
            }
        }
    }
    @ViewBuilder
    func addingProcess() -> some View{
        if !addingTask{
            Button(action: {
                addingTask = true
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
            })
            .background(Color.backTask)
        }
        else{
            HStack{
                Button(action: {
                    addingTask = false
                }, label: {
                    Image(systemName: "xmark.square")
                        .font(.system(size: 30))
                        .padding(.leading, 10)
                })
                TextField("Enter name", text: $taskNameAdded)
                    .padding()
                Button(action: {
                    if !taskNameAdded.isEmpty{
                        guard let userUid = Auth.auth().currentUser?.uid else {return}
                        self.projectManager.projectList[self.proj_index].taskList[self.taskIndex].cards
                            .append(Card(assignedTo: projectManager.projectList[self.proj_index].asignedTo, color: "", createdBy: userUid, name: taskNameAdded))
                        self.projectManager.updateProject(project: projectManager.projectList[self.proj_index])
                        self.projectManager.getProjectdata()
                        addingTask = false
                        taskNameAdded = ""
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
                        message: Text("Please fill the card name"),
                        dismissButton: .default(Text("Ok"))
                    )
                }
                Spacer()
            }
        }
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView(projectManager: ProjectManager(), taskIndex: 0, proj_index: 0)
    }
}
