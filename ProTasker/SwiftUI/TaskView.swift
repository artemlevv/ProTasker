//
//  TaskView.swift
//  ProTasker
//
//  Created by ARTEM on 04.06.2023.
//

import SwiftUI

struct TaskView: View {
    @ObservedObject var projectManager: ProjectManager
    @EnvironmentObject var firestoreManger: FirestoreManager
    
    @State var proj_index: Int
    @State var taskIndex: Int
    @State var cardIndex: Int
    
    let dateFormatter = DateFormatter()
    
    @State var cur_card: Card = Card(assignedTo: [], color: "", createdBy: "", name: "", date: 0)
    

    var body: some View {
        if taskIndex < projectManager.projectList[proj_index].taskList.count{
            VStack{
                    HStack{
                        Text(cur_card.name)
                            .padding(.leading, 20)
                            .padding(.top, 15)
                            .padding(.bottom, 8)
                        Spacer()
                        if cur_card.date != 0{
                            VStack{
                                Text( Date(timeIntervalSince1970: TimeInterval(cur_card.date)), style: .date)
                                    .padding(4)
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .background(Color.backListTask)
                            .padding(.trailing, 10)
                        }
                    }
                    HStack{
                        ScrollView(.horizontal){
                            LazyHStack{
                                ForEach(cur_card.assignedTo, id: \.self) { user_id in
                                    let us =  firestoreManger.userList.filter({$0.id == user_id})
                                    if !us.isEmpty{
                                        AsyncImage(url: URL(string: us[0].image)){ image in
                                            image.image?
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        }
                                        .frame(width: 25, height: 25)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                        .shadow(radius: 4)
                                        .padding(.trailing, 2)
                                        .padding(.leading, 2)
                                    }
                                }
                            }
                            .padding(.leading, 5)
                        }
                    }
                    .frame(height: 35)
                    .padding(.leading, 15)
                    
                    
                    Spacer()
            }
            .border(Color(hex: cur_card.color) ?? Color.white, width: 3)
            .background(.white)
            .onAppear(){
                self.firestoreManger.getAllUsersdata()
                self.projectManager.getProjectdata()
                self.cur_card = projectManager.projectList[proj_index].taskList[taskIndex].cards[cardIndex]
                dateFormatter.dateStyle = .long
                dateFormatter.timeStyle = .none
            }
        }
    }
}


extension Color{
    static let backTask = Color(red: 245/255, green: 245/255, blue: 245/255)
    static let backListTask = Color(red: 235/255, green: 235/255, blue: 235/255)
}

extension NSLocale {
    @objc
    static let currentLocale = NSLocale(localeIdentifier: "en")
}
