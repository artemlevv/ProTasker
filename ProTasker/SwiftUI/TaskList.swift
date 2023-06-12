//
//  TestView.swift
//  ProTasker
//
//  Created by ARTEM on 09.06.2023.
//

import SwiftUI
import Firebase

struct TaskList: View {
    @State var taskIndex: Int
    @State var proj_index: Int
    @State var addingTask = false
    @State var emptyAddedTask = false
    @State var listTitleInEditMode = false
    @State var cards: [Card] = []
    @State var deleteCard: Bool = false
    
    @State var taskNameEditing = ""
    @State var taskNameAdded = ""
    
    @Binding var taskList: [TaskT]

    
    @ObservedObject var projectManager: ProjectManager
    @EnvironmentObject var firestoreManger: FirestoreManager
    
    var body: some View {
        VStack{
            header()
            listCards()
        }
        .padding(.leading, 20)
        .padding(.trailing, 20)
        .onAppear(){
            self.projectManager.getProjectdata()
            self.taskNameEditing = projectManager.projectList[proj_index].taskList[taskIndex].title
            if !deleteCard{
                self.cards = projectManager.projectList[proj_index].taskList[taskIndex].cards
            }
            deleteCard = false
            print(cards)
            print("CARDS in TASLIST UPDATED")
        }
    }
    
    @ViewBuilder
    func header() -> some View{
        HStack{
            if !listTitleInEditMode{
                Text(taskNameEditing)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.top, 15)
                    .padding(.bottom, 15)
                    .foregroundColor(.black)
            }
            else{
                TextField("Edit task list title", text: $taskNameEditing)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.top, 15)
                    .padding(.bottom, 15)
                    .foregroundColor(.black)
            }
            Spacer()
            Button(action: {
                self.listTitleInEditMode.toggle()
                if !listTitleInEditMode{
                    self.projectManager.projectList[proj_index].taskList[taskIndex].title = taskNameEditing
                    self.projectManager.updateProject(project: projectManager.projectList[proj_index])
                    self.taskNameEditing = projectManager.projectList[proj_index].taskList[taskIndex].title
                }
                else{
                    self.taskNameEditing = projectManager.projectList[proj_index].taskList[taskIndex].title
                }
                    }) {
                        Image(systemName: listTitleInEditMode ? "checkmark" : "pencil")
                            .font(.system(size: 25))
                            .fontWeight(.semibold)
                            .padding(.trailing, 15)
                            .foregroundColor(Color.blue)
            }
            if !listTitleInEditMode{
                Button(action: {
                    let deleteTask = projectManager.projectList[self.proj_index].taskList[taskIndex]
                    self.projectManager.projectList[self.proj_index].taskList.removeAll(where: { a in a.uuid == deleteTask.uuid })
                    self.projectManager.updateProject(project: projectManager.projectList[proj_index])
                    taskList = projectManager.projectList[self.proj_index].taskList
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
    }
    @ViewBuilder
    func listCards() -> some View{
        NavigationView{
            ScrollView{
                LazyVStack {
                    ForEach(cards.indices, id: \.self) { card_index in
                        NavigationLink(
                            destination: CardDetailScreen(projectManager: self.projectManager, proj_index: self.proj_index, taskIndex: self.taskIndex, cardIndex: card_index, cards: $cards, deleteCard: $deleteCard)
                                .environmentObject(self.firestoreManger)
                        ) {
                            TaskView(projectManager: self.projectManager, proj_index: self.proj_index, taskIndex: self.taskIndex, cardIndex: card_index)
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
                            .append(Card(assignedTo: projectManager.projectList[self.proj_index].asignedTo, color: "", createdBy: userUid, name: taskNameAdded, date: 0))
                        self.projectManager.updateProject(project: projectManager.projectList[self.proj_index])
                        self.projectManager.getProjectdata()
                        self.cards = projectManager.projectList[proj_index].taskList[taskIndex].cards
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

