//
//  TaskView.swift
//  ProTasker
//
//  Created by ARTEM on 04.06.2023.
//

import SwiftUI

struct TaskView: View {
    @ObservedObject var projectManager: ProjectManager
    
    //MARK: - Timer for updating firebase
    @State var currentDate = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var proj_index: Int
    @State var taskIndex: Int
    @State var cardIndex: Int
    
    var body: some View {
        HStack{
            Text(projectManager.projectList[proj_index].taskList[taskIndex].cards[cardIndex].name)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.top, 15)
                .padding(.bottom, 15)
            Spacer()
        }
        .border(Color(hex: projectManager.projectList[proj_index].taskList[taskIndex].cards[cardIndex].color) ?? Color.white, width: 3)
        .background(.white)
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        @State var test = Card(assignedTo: [],color: "#43C86F", createdBy: "h", name: "Task")
        TaskView(projectManager: ProjectManager(), proj_index: 0, taskIndex: 0, cardIndex: 0)
    }
}

extension Color{
    static let backTask = Color(red: 245/255, green: 245/255, blue: 245/255)
    static let backListTask = Color(red: 235/255, green: 235/255, blue: 235/255)
}
