//
//  Test.swift
//  ProTasker
//
//  Created by ARTEM on 04.06.2023.
//

import SwiftUI

struct Test: View {
    var projectList: [String] = []
    @State var listTitleInEditMode = false
    @State var taskNameEditing = ""
    var body: some View {
        HStack{
            if !listTitleInEditMode{
                Text("hello")
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
                listTitleInEditMode.toggle()
                   }) {
                Image(systemName: listTitleInEditMode ? "checkmark" : "pencil")
                    .font(.system(size: 26))
                    .fontWeight(.semibold)
                    .padding(.trailing, 20)
                    .foregroundColor(Color.blue)
            }
            Button(action: {
                listTitleInEditMode.toggle()
                   }) {
                Image(systemName: "trash")
                    .font(.system(size: 25))
                    .fontWeight(.semibold)
                    .padding(.trailing, 20)
                    .foregroundColor(Color.blue)
            }
            //Spacer()
        }
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
